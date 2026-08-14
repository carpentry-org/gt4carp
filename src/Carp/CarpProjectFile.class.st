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

{ #category : #saving }
CarpProjectFile >> commit [
	"Commit the file into the project's session, so everything it defines is
	current. Answers the committed definitions, or nil when there is no
	session to commit into."

	self project ifNil: [ ^ nil ].
	self project isSessionLoaded ifFalse: [ ^ nil ].
	^ [ CarpServerClient default
		upsertFile: self path
		session: self project sessionId ]
		on: Error
		do: [ :e | nil ]
]

{ #category : #saving }
CarpProjectFile >> addDefinition: aSourceString toModule: aModuleDefinition [
	"Insert a definition at the end of a module's body, just before its
	closing paren, and commit the file. A module definition is the module
	form itself, so its span ends at that paren."

	| insertAt shift |
	insertAt := aModuleDefinition stop - 1.
	"lf, not cr: Pharo's String cr is a carriage return, and these are Unix
	source files"
	shift := self
			replaceBytesFrom: insertAt
			to: insertAt
			with: String lf , '  ' , aSourceString , String lf.
	self shiftDefinitionsAfter: insertAt by: shift.
	aModuleDefinition stop: aModuleDefinition stop + shift.
	self reloadDefinitions.
	^ self commit
]

{ #category : #saving }
CarpProjectFile >> addDefinition: aSourceString [
	"Append a definition at the top level of the file."

	| size shift |
	size := self contentsBytes size.
	shift := self replaceBytesFrom: size to: size with: String lf , aSourceString , String lf.
	self reloadDefinitions.
	^ self commit
]

{ #category : #saving }
CarpProjectFile >> reloadDefinitions [
	"Re-read this file's definitions from the server, so spans and names
	match the bytes on disk after an edit that added or removed one."

	self project ifNil: [ ^ self ].
	[ | fresh |
	fresh := CarpServerClient default projectAt: self project root.
	(fresh files detect: [ :each | each path = self path ] ifNone: [ nil ])
		ifNotNil: [ :aFile |
			self
				definitions: (aFile definitions
						collect: [ :each |
							each file: self.
							each ]) ] ]
		on: Error
		do: [ :e |  ]
]

{ #category : #saving }
CarpProjectFile >> lineOnly: aStart to: aStop [
	"The span of the line a form sits on, from its indentation through its
	own newline. Unlike lineSpanAround:to: this keeps the blank line above
	it: an annotation sits directly on top of what it talks about, and
	taking its line should not also close the gap to whatever came before."

	| bytes from to space tab newline |
	bytes := self contentsBytes.
	space := 32.
	tab := 9.
	newline := 10.
	from := aStart.
	[ from > 0 and: [ | b | b := bytes at: from. b = space or: [ b = tab ] ] ]
		whileTrue: [ from := from - 1 ].
	to := aStop.
	(to < bytes size and: [ (bytes at: to + 1) = newline ]) ifTrue: [ to := to + 1 ].
	^ from -> to
]

{ #category : #editing }
CarpProjectFile >> lineSpanAround: aStart to: aStop [
	"Widen a span to the whole line it sits on: the indentation before it and
	the newline after it. Cutting only the text would leave a blank line and
	a stray indent where the definition used to be."

	| bytes from to space tab newline |
	bytes := self contentsBytes.
	space := 32.
	tab := 9.
	newline := 10.
	from := aStart.
	[ from > 0 and: [ | b | b := bytes at: from. b = space or: [ b = tab ] ] ]
		whileTrue: [ from := from - 1 ].
	(from > 0 and: [ (bytes at: from) = newline ]) ifTrue: [ from := from - 1 ].
	to := aStop.
	(to < bytes size and: [ (bytes at: to + 1) = newline ]) ifTrue: [ to := to + 1 ].
	^ from -> to
]

{ #category : #saving }
CarpProjectFile >> removeDefinition: aDefinition [
	definitions := self definitions copyWithout: aDefinition
]

{ #category : #saving }
CarpProjectFile >> shiftDefinitionsAfter: aByteOffset by: aNumber [
	"Editing one definition moves every definition below it in the file."

	aNumber = 0 ifTrue: [ ^ self ].
	self definitions
		do: [ :each |
			each start >= aByteOffset
				ifTrue: [ each start: each start + aNumber.
					each stop: each stop + aNumber ] ]
]

{ #category : #saving }
CarpProjectFile >> replaceBytesFrom: aStart to: aStop with: aString [
	"Write over exactly those bytes and leave the rest of the file alone:
	comments, formatting and neighbouring definitions are none of our
	business. Answers the length change, so spans after it can follow."

	| bytes replacement updated |
	bytes := self contentsBytes.
	replacement := aString utf8Encoded.
	updated := (bytes first: aStart) , replacement
			, (bytes allButFirst: (aStop min: bytes size)).
	"truncate: writing over an existing file leaves whatever was longer than
	the new content behind, which turns a deletion into corruption"
	self path asFileReference
		binaryWriteStreamDo: [ :stream |
			stream truncate.
			stream nextPutAll: updated ].
	contents := nil.
	^ replacement size - (aStop - aStart)
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
