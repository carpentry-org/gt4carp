"
One definition in a project file: its qualified name, what defines it
(defn, deftype, …), its documentation, and the byte span it occupies in
that file. The span is what makes this editable later — writing a
definition back means replacing exactly those bytes.
"
Class {
	#name : #CarpSourceDefinition,
	#superclass : #Object,
	#instVars : [
		'name',
		'head',
		'start',
		'stop',
		'documentation',
		'file'
	],
	#category : #'Carp-Project'
}

{ #category : #'instance creation' }
CarpSourceDefinition class >> fromDictionary: aDictionary in: aFile [
	^ self new
		name: (aDictionary at: 'name' ifAbsent: [ '' ]);
		head: (aDictionary at: 'head' ifAbsent: [ '' ]);
		start: (aDictionary at: 'start' ifAbsent: [ 0 ]) asInteger;
		stop: (aDictionary at: 'end' ifAbsent: [ 0 ]) asInteger;
		documentation: (aDictionary at: 'doc' ifAbsent: [ '' ]);
		file: aFile;
		yourself
]

{ #category : #accessing }
CarpSourceDefinition >> documentation [
	^ documentation ifNil: [ '' ]
]

{ #category : #accessing }
CarpSourceDefinition >> documentation: aString [
	documentation := aString
]

{ #category : #accessing }
CarpSourceDefinition >> file [
	^ file
]

{ #category : #accessing }
CarpSourceDefinition >> file: aCarpProjectFile [
	file := aCarpProjectFile
]

{ #category : #accessing }
CarpSourceDefinition >> gtDocumentationFor: aView [
	<gtView>
	self documentation ifEmpty: [ ^ aView empty ].
	^ aView textEditor
		title: 'Documentation';
		priority: 2;
		text: [ self documentation ]
]

{ #category : #accessing }
CarpSourceDefinition >> gtSourceFor: aView [
	"Read-only for now: a coder here would annotate against a session that
	does not hold the project, and report every project binding as unknown."

	<gtView>
	^ aView textEditor
		title: 'Source';
		priority: 1;
		aptitude: [ BrGlamorousCodeEditorAptitude ];
		styler: [ CarpParser gtStyler ];
		text: [ self source ]
]

{ #category : #accessing }
CarpSourceDefinition >> head [
	^ head ifNil: [ '' ]
]

{ #category : #accessing }
CarpSourceDefinition >> head: aString [
	head := aString
]

{ #category : #accessing }
CarpSourceDefinition >> moduleName [
	"The module this belongs to: everything before the last dot of the
	qualified name, or empty at the top level."

	| index |
	index := self name lastIndexOf: $..
	^ index = 0
		ifTrue: [ '' ]
		ifFalse: [ self name first: index - 1 ]
]

{ #category : #accessing }
CarpSourceDefinition >> name [
	^ name ifNil: [ '' ]
]

{ #category : #accessing }
CarpSourceDefinition >> name: aString [
	name := aString
]

{ #category : #printing }
CarpSourceDefinition >> printOn: aStream [
	aStream
		nextPutAll: self head;
		nextPutAll: ' ';
		nextPutAll: self name
]

{ #category : #accessing }
CarpSourceDefinition >> shortName [
	"The name without its module prefix."

	| index |
	index := self name lastIndexOf: $..
	^ index = 0
		ifTrue: [ self name ]
		ifFalse: [ self name allButFirst: index ]
]

{ #category : #accessing }
CarpSourceDefinition >> source [
	"The definition's own text, sliced from its file by byte span."

	^ file
		ifNil: [ '' ]
		ifNotNil: [ :aFile | aFile byteSliceFrom: start to: stop ]
]

{ #category : #accessing }
CarpSourceDefinition >> start [
	^ start
]

{ #category : #accessing }
CarpSourceDefinition >> start: anInteger [
	start := anInteger
]

{ #category : #accessing }
CarpSourceDefinition >> stop [
	^ stop
]

{ #category : #accessing }
CarpSourceDefinition >> stop: anInteger [
	stop := anInteger
]
