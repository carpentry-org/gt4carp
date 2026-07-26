"
Holds the state of a stepped macro expansion: the original form, plus an
ordered collection of successive expansions. Each `step` asks the server
for `expand-1` of the current form and appends the result; `back` pops the
last step; `runToFixpoint` keeps stepping until the result no longer changes.

A view model is normally constructed with a CarpLLClient, but for tests you
can plug in any object responding to `expand1:`.
"
Class {
	#name : #CarpMacroExpansionViewModel,
	#superclass : #Object,
	#instVars : [
		'client',
		'steps',
		'announcer'
	],
	#category : #'Carp-MacroStepper'
}

{ #category : #'instance creation' }
CarpMacroExpansionViewModel class >> source: aString client: aClient [
	^ self new client: aClient; source: aString; yourself
]

{ #category : #accessing }
CarpMacroExpansionViewModel >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
CarpMacroExpansionViewModel >> client [ ^ client ]

{ #category : #accessing }
CarpMacroExpansionViewModel >> client: aClient [ client := aClient ]

{ #category : #accessing }
CarpMacroExpansionViewModel >> current [
	^ steps last
]

{ #category : #testing }
CarpMacroExpansionViewModel >> hasHistory [
	^ steps size > 1
]

{ #category : #initialization }
CarpMacroExpansionViewModel >> initialize [
	super initialize.
	steps := OrderedCollection new
]

{ #category : #testing }
CarpMacroExpansionViewModel >> isAtFixpoint [
	"True if the last step produced no further change. We compare the last
	two strings; for the initial state we return false (we haven't tried)."
	steps size < 2 ifTrue: [ ^ false ].
	^ (steps last: 2) first = (steps last: 2) last
]

{ #category : #stepping }
CarpMacroExpansionViewModel >> reset [
	steps := OrderedCollection with: steps first.
	self announcer announce: CarpMacroExpansionChanged new
]

{ #category : #stepping }
CarpMacroExpansionViewModel >> runToFixpoint [
	"Step until isAtFixpoint, with a safety bound."
	| maxSteps |
	maxSteps := 200.
	[ maxSteps > 0 and: [ self isAtFixpoint not ] ] whileTrue: [
		self step.
		maxSteps := maxSteps - 1 ]
]

{ #category : #accessing }
CarpMacroExpansionViewModel >> source: aString [
	"Replace state with a single initial step. Existing history is dropped."
	steps := OrderedCollection with: aString.
	self announcer announce: CarpMacroExpansionChanged new
]

{ #category : #stepping }
CarpMacroExpansionViewModel >> step [
	"Send expand-1 for the current form, append the result."
	| next |
	self isAtFixpoint ifTrue: [ ^ self ].
	next := client expand1: self current.
	steps addLast: next.
	self announcer announce: CarpMacroExpansionChanged new
]

{ #category : #stepping }
CarpMacroExpansionViewModel >> stepBack [
	self hasHistory ifFalse: [ ^ self ].
	steps removeLast.
	self announcer announce: CarpMacroExpansionChanged new
]

{ #category : #accessing }
CarpMacroExpansionViewModel >> steps [
	"Return the immutable list of expansion steps so far."
	^ steps asArray
]
