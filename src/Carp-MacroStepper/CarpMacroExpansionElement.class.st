"
A BlElement that visualizes a CarpMacroExpansionViewModel.

Top row: a label showing the current step index and how many remain.
Body: a styled editor displaying the current expansion's source.
Footer: buttons for Step / Back / Reset / Run-to-fixpoint.

The element subscribes to the view model's announcer so external changes
(or stepping triggered by other UIs sharing the same view model) refresh
the display automatically.

Usage:
	(CarpMacroExpansionElement onViewModel:
		(CarpMacroExpansionViewModel source: '(when true 1)'
			client: (CarpLLClient host: '127.0.0.1' port: 8765))) openInSpace.
"
Class {
	#name : #CarpMacroExpansionElement,
	#superclass : #BlElement,
	#traits : 'TBrLayoutResizable',
	#classTraits : 'TBrLayoutResizable classTrait',
	#instVars : [
		'viewModel',
		'headerLabel',
		'editor',
		'statusLabel'
	],
	#category : #'Carp-MacroStepper'
}

{ #category : #'instance creation' }
CarpMacroExpansionElement class >> onViewModel: aViewModel [
	^ self new viewModel: aViewModel; yourself
]

{ #category : #building }
CarpMacroExpansionElement >> buildBody [
	editor := BrEditor new
		aptitude: (BrGlamorousCodeEditorAptitude new
			glamorousCodeFont;
			fontSize: 14);
		margin: (BlInsets all: 6);
		hMatchParent;
		vMatchParent;
		text: '' asRopedText.
	^ editor
]

{ #category : #building }
CarpMacroExpansionElement >> buildButtonBar [
	| bar mkButton |
	bar := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		alignCenterLeft;
		padding: (BlInsets all: 6);
		cellSpacing: 6.
	mkButton := [ :aLabel :anAction |
		BrButton new
			aptitude: BrGlamorousButtonWithLabelAptitude;
			label: aLabel;
			action: anAction;
			yourself ].
	bar
		addChild: (mkButton value: 'Step' value: [ self stepSafely ]);
		addChild: (mkButton value: 'Back' value: [ viewModel stepBack ]);
		addChild: (mkButton value: 'Reset' value: [ viewModel reset ]);
		addChild: (mkButton value: 'Run to fixpoint' value: [ self runToFixpointSafely ]);
		addChild: (BrFrame new hMatchParent vFitContent);
		addChild: self buildStatusLabel.
	^ bar
]

{ #category : #building }
CarpMacroExpansionElement >> buildHeader [
	headerLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFont;
			fontSize: 13);
		padding: (BlInsets all: 6);
		text: 'Step 1 of 1'.
	^ headerLabel
]

{ #category : #building }
CarpMacroExpansionElement >> buildStatusLabel [
	statusLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFont;
			fontSize: 12);
		text: ''.
	^ statusLabel
]

{ #category : #initialization }
CarpMacroExpansionElement >> initialize [
	super initialize.
	self
		layout: BlLinearLayout vertical;
		hMatchParent;
		vMatchParent.
	self addChild: self buildHeader.
	self addChild: self buildBody.
	self addChild: self buildButtonBar
]

{ #category : #updating }
CarpMacroExpansionElement >> refresh [
	| steps current text |
	steps := viewModel steps.
	current := viewModel current.
	headerLabel text: ('Step {1} of {2}' format: { steps size. steps size }).
	text := current asRopedText.
	"Style as Carp source if the SmaCC styler is available; otherwise plain text."
	(Smalltalk classNamed: #CarpParser) ifNotNil: [ :parserClass |
		[ text := (GtCoderAstSmaCCParserStyler new smaccStyler: parserClass gtStyler)
				style: current asRopedText ]
			on: Error do: [ "fall back to plain" ] ].
	editor text: text.
	viewModel isAtFixpoint
		ifTrue: [ statusLabel text: 'at fixpoint' ]
		ifFalse: [ statusLabel text: '' ]
]

{ #category : #stepping }
CarpMacroExpansionElement >> runToFixpointSafely [
	[ viewModel runToFixpoint ]
		on: CarpLLError do: [ :e | statusLabel text: e messageText ]
]

{ #category : #stepping }
CarpMacroExpansionElement >> stepSafely [
	[ viewModel step ]
		on: CarpLLError do: [ :e | statusLabel text: e messageText ]
]

{ #category : #accessing }
CarpMacroExpansionElement >> viewModel [ ^ viewModel ]

{ #category : #accessing }
CarpMacroExpansionElement >> viewModel: aViewModel [
	viewModel := aViewModel.
	viewModel announcer
		when: CarpMacroExpansionChanged
		send: #refresh
		to: self.
	self refresh
]
