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

{ #category : #actions }
CarpSourceDefinition >> gtActionDeleteFor: anAction [
	<gtAction>
	self isModule ifTrue: [ ^ anAction noAction ].
	^ anAction button
		priority: 10;
		icon: BrGlamorousVectorIcons trash;
		tooltip: 'Delete this definition from its file';
		action: [ :aButton | self delete ]
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
	"A coder once the project's session is warm, so the definition is typed,
	checked, completed and documented against the rest of the project.
	Before that a coder would annotate against a session that does not hold
	the project and call every project binding unknown, so the source is
	shown plainly instead."

	<gtView>
	self project isSessionLoaded
		ifFalse: [ ^ aView textEditor
				title: 'Source';
				priority: 1;
				aptitude: [ BrGlamorousCodeEditorAptitude ];
				styler: [ CarpParser gtStyler ];
				text: [ self source ] ].
	^ aView explicit
		title: 'Source';
		priority: 1;
		stencil: [ self newCoder asCoderViewModel asElement ]
]

{ #category : #saving }
CarpSourceDefinition >> delete [
	"Cut the definition out of its file, leaving one blank line where it
	was, and commit the file so the session drops it too."

	| shift boundary span |
	span := self file lineSpanAround: start to: stop.
	boundary := stop.
	shift := self file replaceBytesFrom: span key to: span value with: ''.
	self file shiftDefinitionsAfter: boundary by: shift.
	self file removeDefinition: self.
	self file commit.
	self project ifNotNil: [ :aProject | aProject changed ]
]

{ #category : #testing }
CarpSourceDefinition >> isModule [
	^ self head = 'defmodule'
]

{ #category : #saving }
CarpSourceDefinition >> save: aSourceString [
	"Write this definition back through its span and commit the file into the
	session. The file is the truth: the bytes are replaced in place, every
	span after this one shifts by the length change, and the session is told
	about the file as a whole so a rename or a deletion reconciles."

	| shift boundary |
	aSourceString = self source ifTrue: [ ^ self ].
	boundary := stop.
	shift := self file replaceBytesFrom: start to: stop with: aSourceString.
	"shift the definitions below BEFORE moving this one's own end, or the
	boundary they are compared against has already moved"
	self file shiftDefinitionsAfter: boundary by: shift.
	stop := stop + shift.
	self file commit.
	self project ifNotNil: [ :aProject | aProject changed ]
]

{ #category : #accessing }
CarpSourceDefinition >> newCoder [
	"The definition's own text in a coder bound to the project's session,
	which writes back through this definition's span when saved."

	^ GtCarpDefinitionCoderModel on: self
]

{ #category : #accessing }
CarpSourceDefinition >> project [
	^ file ifNil: [ nil ] ifNotNil: [ :aFile | aFile project ]
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
