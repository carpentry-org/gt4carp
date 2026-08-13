"
A stepped macro expansion: the form as written, plus every expansion step
taken from it. `step` asks the session for one expansion of the current
form and appends the result; `stepBack` drops the last one; `expandFully`
answers the form with every macro expanded, which is what the compiler
actually goes on to compile.

Nothing here commits to the session — expansion runs against a private copy
of the compile-time environment.

Note on stepping: the session's single-step expansion only fires when the
OUTERMOST form is itself a macro call, so a definition whose body contains
macros reports no change even though expanding fully rewrites it. Until
that is a full one-reduction-anywhere step, `isAtFixpoint` can be true
while `expandFully` still differs — hence both are shown.
"
Class {
	#name : #CarpMacroExpansion,
	#superclass : #Object,
	#instVars : [
		'session',
		'steps'
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
	^ self steps last
]

{ #category : #accessing }
CarpMacroExpansion >> expandFully [
	"The form with every macro expanded, or the current form when the
	session cannot expand it."

	^ [ (CarpServerClient default
		expandSource: self current
		session: session
		once: false) at: 'expansion' ifAbsent: [ self current ] ]
		on: Error
		do: [ :e | self current ]
]

{ #category : #accessing }
CarpMacroExpansion >> gtFullyExpandedFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Fully expanded';
		priority: 2;
		aptitude: [ BrGlamorousCodeEditorAptitude ];
		styler: [ CarpParser gtStyler ];
		text: [ self expandFully ]
]

{ #category : #accessing }
CarpMacroExpansion >> gtStepsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Steps';
		priority: 1;
		items: [ self steps withIndexCollect: [ :each :index | index -> each ] ];
		column: '#' text: [ :each | each key ] width: 40;
		column: 'Form' text: [ :each | each value ];
		send: [ :each | each value ]
]

{ #category : #testing }
CarpMacroExpansion >> isAtFixpoint [
	"Whether the last step expanded nothing further."

	^ self steps size > 1 and: [ self steps last = (self steps at: self steps size - 1) ]
]

{ #category : #printing }
CarpMacroExpansion >> printOn: aStream [
	aStream
		nextPutAll: 'expansion: ';
		print: self steps size - 1;
		nextPutAll: (self steps size = 2
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
	steps := OrderedCollection with: aString
]

{ #category : #stepping }
CarpMacroExpansion >> step [
	"Take one expansion step from the current form. Answers whether it
	changed anything; at the fixpoint nothing is appended."

	| answer |
	answer := [ CarpServerClient default
			expandSource: self current
			session: session
			once: true ]
			on: Error
			do: [ :e | nil ].
	answer ifNil: [ ^ false ].
	(answer at: 'changed' ifAbsent: [ false ])
		ifFalse: [ ^ false ].
	steps add: (answer at: 'expansion').
	^ true
]

{ #category : #stepping }
CarpMacroExpansion >> stepBack [
	self steps size > 1 ifTrue: [ steps removeLast ]
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
