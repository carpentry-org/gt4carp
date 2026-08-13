"
A stepped macro expansion: the form as written, plus every expansion step
taken from it. `step` asks the session for one expansion of the current
form and appends the result; `stepBack` drops the last one; `expandFully`
answers the form with every macro expanded, which is what the compiler
actually goes on to compile.

Nothing here commits to the session — expansion runs against a private copy
of the compile-time environment.

A step is one reduction ANYWHERE in the form. The session's single-step
expansion only fires when the outermost head is a macro, so stepping walks
the tree here — outermost first, then each subform in source order — and
splices the one expansion it finds back into the surrounding text. Each
step therefore costs a few round trips; a native one-reduction-anywhere
step in the session would replace this walk entirely.
"
Class {
	#name : #CarpMacroExpansion,
	#superclass : #Object,
	#instVars : [
		'session',
		'steps',
		'position',
		'exhausted',
		'expander',
		'announcer'
	],
	#category : #'Carp-Tools'
}

{ #category : #'instance creation' }
CarpMacroExpansion class >> onSource: aSourceString session: aSessionString [
	^ self new
		session: aSessionString;
		source: aSourceString;
		yourself
]

{ #category : #accessing }
CarpMacroExpansion >> current [
	^ self steps at: self position
]

{ #category : #accessing }
CarpMacroExpansion >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
CarpMacroExpansion >> changed [
	self announcer announce: CarpMacroExpansionChanged new
]

{ #category : #accessing }
CarpMacroExpansion >> expander [
	"Whoever answers expansions — the server client by default. A stand-in
	responding to expandSource:session:once: lets the stepper be exercised
	with no server at all."

	^ expander ifNil: [ expander := CarpServerClient default ]
]

{ #category : #accessing }
CarpMacroExpansion >> expander: anObject [
	expander := anObject
]

{ #category : #accessing }
CarpMacroExpansion >> position [
	"Where we are in the history: 1 is the form as written."

	^ position ifNil: [ position := 1 ]
]

{ #category : #accessing }
CarpMacroExpansion >> stepCount [
	"How many expansions have been discovered."

	^ self steps size - 1
]

{ #category : #accessing }
CarpMacroExpansion >> expandFully [
	"The form with every macro expanded, or the current form when the
	session cannot expand it."

	^ [ (self expander
		expandSource: self current
		session: session
		once: false) at: 'expansion' ifAbsent: [ self current ] ]
		on: Error
		do: [ :e | self current ]
]

{ #category : #actions }
CarpMacroExpansion >> gtActionBackFor: anAction [
	"Navigation belongs to the whole inspector: stepping while reading the
	diff is the point, and every view follows the model."

	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons left;
		tooltip: 'Back one expansion';
		action: [ :aButton | self stepBack ]
]

{ #category : #actions }
CarpMacroExpansion >> gtActionStepFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons right;
		tooltip: 'Expand one step';
		action: [ :aButton | self step ]
]

{ #category : #actions }
CarpMacroExpansion >> gtActionFixpointFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons rightSide;
		tooltip: 'Expand to the fixpoint';
		action: [ :aButton | self stepToFixpoint ]
]

{ #category : #actions }
CarpMacroExpansion >> gtActionResetFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons restart;
		tooltip: 'Back to the form as written';
		action: [ :aButton | self reset ]
]

{ #category : #accessing }
CarpMacroExpansion >> gtDiffFor: aView [
	"What the current step actually rewrote. Two long forms differ in one
	subform and finding it by eye is the whole difficulty, so the tokens are
	split with Carp's own scanner rather than by line."

	<gtView>
	^ aView diff
		title: 'Diff';
		priority: 2;
		fromLabel: [ self position = 1 ifTrue: [ 'as written' ] ifFalse: [ 'step ' , (self position - 2 max: 0) printString ] ];
		toLabel: [ self position = 1 ifTrue: [ 'as written (nothing expanded yet)' ] ifFalse: [ 'step ' , (self position - 1) printString ] ];
		from: [ self previous ];
		to: [ self current ];
		splitter: [ GtSmaCCDiffSplitter new scannerClass: CarpScanner ];
		updateWhen: CarpMacroExpansionChanged in: [ self announcer ]
]

{ #category : #accessing }
CarpMacroExpansion >> previous [
	"The form this step expanded, or the current one at the beginning."

	^ self position > 1
		ifTrue: [ self steps at: self position - 1 ]
		ifFalse: [ self current ]
]

{ #category : #accessing }
CarpMacroExpansion >> gtFullyExpandedFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Fully expanded';
		priority: 4;
		aptitude: [ BrGlamorousCodeEditorAptitude ];
		styler: [ CarpParser gtStyler ];
		text: [ self expandFully ];
		updateWhen: CarpMacroExpansionChanged in: [ self announcer ]
]

{ #category : #accessing }
CarpMacroExpansion >> gtStepperFor: aView [
	"The stepper proper: the current form, and buttons that walk it. The UI
	lives on the model as a view — there is no separate widget to keep in
	sync."

	<gtView>
	^ aView explicit
		title: 'Stepper';
		priority: 1;
		stencil: [ self newStepperElement ];
		updateWhen: CarpMacroExpansionChanged in: [ self announcer ]
]

{ #category : #ui }
CarpMacroExpansion >> newStepperElement [
	"The form at the current position, with where we are underneath. The
	buttons that move it are the inspector's own actions."

	| editor status |
	editor := BrEditor new
			aptitude: BrGlamorousCodeEditorAptitude new;
			styler: CarpParser gtStyler;
			beReadOnlyWithSelection;
			padding: (BlInsets all: 6);
			text: self current asRopedText;
			hMatchParent;
			vMatchParent.
	status := BrLabel new
			aptitude: (BrGlamorousLabelAptitude new foreground: BrGlamorousColors disabledButtonTextColor);
			padding: (BlInsets all: 6);
			text: (String
					streamContents: [ :aStream |
						self position = 1
							ifTrue: [ aStream nextPutAll: 'as written' ]
							ifFalse: [ aStream
									nextPutAll: 'step ';
									print: self position - 1;
									nextPutAll: ' of ';
									print: self stepCount ].
						self isAtFixpoint ifTrue: [ aStream nextPutAll: ' · fully expanded' ] ]).
	^ BrVerticalPane new
		hMatchParent;
		vMatchParent;
		addChild: editor;
		addChild: status;
		yourself
]

{ #category : #stepping }
CarpMacroExpansion >> reset [
	"Back to the form as written, keeping what we already expanded."

	position := 1.
	self changed
]

{ #category : #accessing }
CarpMacroExpansion >> gtStepsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Steps';
		priority: 3;
		items: [ self steps withIndexCollect: [ :each :index | index -> each ] ];
		column: '#' text: [ :each | each key = self position ifTrue: [ '▶ ' , each key printString ] ifFalse: [ each key printString ] ] width: 50;
		column: 'Form' text: [ :each | each value ];
		send: [ :each | each value ];
		actionUpdateButton;
		updateWhen: CarpMacroExpansionChanged in: [ self announcer ]
]

{ #category : #testing }
CarpMacroExpansion >> isAtFixpoint [
	"Whether we are at the end of the history AND a step there found nothing
	more to expand. Unknown until a step has actually been attempted."

	^ exhausted == true and: [ self position = self steps size ]
]

{ #category : #printing }
CarpMacroExpansion >> printOn: aStream [
	aStream
		nextPutAll: 'expansion: ';
		print: self stepCount;
		nextPutAll: (self stepCount = 1
				ifTrue: [ ' step' ]
				ifFalse: [ ' steps' ])
]

{ #category : #accessing }
CarpMacroExpansion >> session [
	^ session
]

{ #category : #accessing }
CarpMacroExpansion >> session: aString [
	session := aString
]

{ #category : #accessing }
CarpMacroExpansion >> source: aString [
	steps := OrderedCollection with: aString.
	position := 1.
	exhausted := false
]

{ #category : #stepping }
CarpMacroExpansion >> expandOnce: aFormString [
	"One expansion of a form, or nil when it expands to itself."

	| answer |
	answer := [ self expander
			expandSource: aFormString
			session: session
			once: true ]
			on: Error
			do: [ :e | nil ].
	answer ifNil: [ ^ nil ].
	^ (answer at: 'changed' ifAbsent: [ false ])
		ifTrue: [ answer at: 'expansion' ]
		ifFalse: [ nil ]
]

{ #category : #stepping }
CarpMacroExpansion >> reduceOnce: aFormString [
	"One reduction anywhere in the form: the session only expands a form
	whose OUTERMOST head is a macro, so a definition whose body contains
	macros reports no change. Walking the tree here — outermost first, then
	each subform in order — makes a step mean what a stepper needs it to
	mean. Answers the whole form with that one reduction spliced in, or nil
	at the real fixpoint."

	| ast |
	(self expandOnce: aFormString) ifNotNil: [ :expanded | ^ expanded ].
	ast := [ CarpParser parseWithErrors: aFormString ] on: Error do: [ :e | ^ nil ].
	^ self reduceWithin: ast of: aFormString
]

{ #category : #stepping }
CarpMacroExpansion >> reduceWithin: aNode of: aFormString [
	"Depth-first, in source order: the first subform that expands wins, and
	its expansion is spliced back into the text so everything around it is
	preserved exactly."

	aNode children
		do: [ :child |
			| subform expanded |
			(child isKindOf: CarpListNode)
				ifTrue: [ subform := [ aFormString copyFrom: child startPosition to: child stopPosition ]
							on: Error
							do: [ :e | nil ].
					subform
						ifNotNil: [ expanded := self expandOnce: subform.
							expanded
								ifNotNil: [ ^ aFormString
										copyReplaceFrom: child startPosition
										to: child stopPosition
										with: expanded ] ] ].
			(self reduceWithin: child of: aFormString) ifNotNil: [ :reduced | ^ reduced ] ].
	^ nil
]

{ #category : #stepping }
CarpMacroExpansion >> step [
	"Move one expansion forward. Stepping back and forward again replays the
	history rather than recomputing it; only past the end is a new reduction
	asked for. Answers whether anything moved."

	self position < self steps size
		ifTrue: [ position := self position + 1.
			self changed.
			^ true ].
	(self reduceOnce: self current)
		ifNil: [ exhausted := true.
			self changed.
			^ false ]
		ifNotNil: [ :reduced |
			steps add: reduced.
			position := steps size.
			self changed.
			^ true ]
]

{ #category : #stepping }
CarpMacroExpansion >> stepBack [
	"Back one expansion, keeping the history so Step can go forward again."

	self position > 1
		ifTrue: [ position := self position - 1.
			self changed ]
]

{ #category : #accessing }
CarpMacroExpansion >> steps [
	^ steps ifNil: [ steps := OrderedCollection new ]
]

{ #category : #stepping }
CarpMacroExpansion >> stepToFixpoint [
	"Keep stepping while the form keeps changing."

	[ self step ] whileTrue
]
