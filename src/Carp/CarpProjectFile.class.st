"
One file of a project, in load order: the repository's own code or a
dependency pulled in from the library cache, and the definitions it
contains.

The contents are read from disk on demand rather than shipped with the
project tree — the tree is a map, not a copy — and sliced by BYTE offsets,
because that is what the compiler reports.
"
Class {
	#name : #CarpProjectFile,
	#superclass : #Object,
	#instVars : [
		'path',
		'kind',
		'definitions',
		'contents',
		'project'
	],
	#category : #'Carp-Project'
}

{ #category : #'instance creation' }
CarpProjectFile class >> fromDictionary: aDictionary [
	| file |
	file := self new
			path: (aDictionary at: 'path' ifAbsent: [ '' ]);
			kind: (aDictionary at: 'kind' ifAbsent: [ 'project' ]);
			yourself.
	file
		definitions: ((aDictionary at: 'definitions' ifAbsent: [ #() ])
				collect: [ :each | CarpSourceDefinition fromDictionary: each in: file ]).
	^ file
]

{ #category : #accessing }
CarpProjectFile >> basename [
	| index |
	index := self path lastIndexOf: $/.
	^ index = 0
		ifTrue: [ self path ]
		ifFalse: [ self path allButFirst: index ]
]

{ #category : #accessing }
CarpProjectFile >> byteSliceFrom: aStart to: aStop [
	"Slice by byte offset, then decode: the compiler counts bytes and the
	image counts characters, so slicing the decoded string would shift on
	any file containing multi-byte text."

	| bytes |
	bytes := self contentsBytes.
	(aStart between: 0 and: bytes size) ifFalse: [ ^ '' ].
	^ [ (bytes copyFrom: aStart + 1 to: (aStop min: bytes size)) utf8Decoded ]
		on: Error
		do: [ :e | '' ]
]

{ #category : #accessing }
CarpProjectFile >> contents [
	^ contents ifNil: [ contents := [ self path asFileReference contents ] on: Error do: [ :e | '' ] ]
]

{ #category : #accessing }
CarpProjectFile >> contentsBytes [
	^ self contents utf8Encoded
]

{ #category : #accessing }
CarpProjectFile >> project [
	^ project
]

{ #category : #accessing }
CarpProjectFile >> project: aCarpProject [
	project := aCarpProject
]

{ #category : #accessing }
CarpProjectFile >> definitions [
	^ definitions ifNil: [ #() ]
]

{ #category : #accessing }
CarpProjectFile >> definitions: aCollection [
	definitions := aCollection
]

{ #category : #accessing }
CarpProjectFile >> gtDefinitionsFor: aView [
	<gtView>
	self definitions ifEmpty: [ ^ aView empty ].
	^ aView columnedList
		title: 'Definitions';
		priority: 1;
		items: [ self definitions ];
		column: 'Name' text: [ :each | each name ];
		column: 'Kind' text: [ :each | each head ] width: 110;
		send: [ :each | each ]
]

{ #category : #accessing }
CarpProjectFile >> gtSourceFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Source';
		priority: 2;
		aptitude: [ BrGlamorousCodeEditorAptitude ];
		styler: [ CarpParser gtStyler ];
		text: [ self contents ]
]

{ #category : #testing }
CarpProjectFile >> isDependency [
	^ self kind = 'dep'
]

{ #category : #accessing }
CarpProjectFile >> kind [
	^ kind ifNil: [ 'project' ]
]

{ #category : #accessing }
CarpProjectFile >> kind: aString [
	kind := aString
]

{ #category : #accessing }
CarpProjectFile >> path [
	^ path ifNil: [ '' ]
]

{ #category : #accessing }
CarpProjectFile >> path: aString [
	path := aString
]

{ #category : #printing }
CarpProjectFile >> printOn: aStream [
	aStream
		nextPutAll: self basename;
		nextPutAll: ' (';
		print: self definitions size;
		nextPutAll: ' definitions)'
]
