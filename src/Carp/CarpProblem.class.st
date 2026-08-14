"
One thing that does not compile: a compiler diagnostic together with the
file it came from, so the project can list its problems and each one can
take you to the source that caused it.
"
Class {
	#name : #CarpProblem,
	#superclass : #Object,
	#instVars : [
		'phase',
		'message',
		'start',
		'stop',
		'file'
	],
	#category : #'Carp-Project'
}

{ #category : #'instance creation' }
CarpProblem class >> onDiagnostic: aDictionary in: aFile [
	^ self new
		phase: (aDictionary at: 'phase' ifAbsent: [ '' ]);
		message: (aDictionary at: 'message' ifAbsent: [ '' ]);
		start: (aDictionary at: 'start' ifAbsent: [ nil ]);
		stop: (aDictionary at: 'end' ifAbsent: [ nil ]);
		file: aFile;
		yourself
]

{ #category : #accessing }
CarpProblem >> definition [
	"The definition the diagnostic falls inside, when it has a span. A module
	spans everything its definitions do, so the smallest span wins: you want
	the function that does not compile, not the module around it."

	| offset candidates |
	start ifNil: [ ^ nil ].
	offset := start asInteger.
	candidates := self file definitions
			select: [ :each | each start <= offset and: [ offset < each stop ] ].
	candidates ifEmpty: [ ^ nil ].
	^ candidates
		inject: candidates first
		into: [ :narrowest :each |
			each stop - each start < (narrowest stop - narrowest start)
				ifTrue: [ each ]
				ifFalse: [ narrowest ] ]
]

{ #category : #accessing }
CarpProblem >> file [
	^ file
]

{ #category : #accessing }
CarpProblem >> file: aFile [
	file := aFile
]

{ #category : #accessing }
CarpProblem >> gtSourceFor: aView [
	<gtView>
	self definition ifNil: [ ^ aView empty ].
	^ aView textEditor
		title: 'Source';
		priority: 1;
		aptitude: [ BrGlamorousCodeEditorAptitude ];
		styler: [ CarpParser gtStyler ];
		text: [ self definition source ]
]

{ #category : #accessing }
CarpProblem >> message [
	^ message ifNil: [ '' ]
]

{ #category : #accessing }
CarpProblem >> message: aString [
	message := aString
]

{ #category : #accessing }
CarpProblem >> phase [
	^ phase ifNil: [ '' ]
]

{ #category : #accessing }
CarpProblem >> phase: aString [
	phase := aString
]

{ #category : #printing }
CarpProblem >> printOn: aStream [
	aStream
		nextPutAll: self phase;
		nextPutAll: ': ';
		nextPutAll: self message
]

{ #category : #accessing }
CarpProblem >> start [
	^ start
]

{ #category : #accessing }
CarpProblem >> start: aNumber [
	start := aNumber
]

{ #category : #accessing }
CarpProblem >> stop [
	^ stop
]

{ #category : #accessing }
CarpProblem >> stop: aNumber [
	stop := aNumber
]
