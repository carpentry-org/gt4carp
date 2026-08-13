"
A Carp project: a git repository whose entry file loads the rest. The
server walks that load graph and answers the files in load order, which of
them are the repository's own and which are dependencies from the library
cache, and every definition with its span.

Browsing goes project → module → definition. Modules are recovered from the
qualified names rather than from the file layout, so a file holding several
modules — or a module spread over several files — still browses by module.
"
Class {
	#name : #CarpProject,
	#superclass : #Object,
	#instVars : [
		'root',
		'entry',
		'files',
		'sessionState',
		'sessionMillis',
		'announcer'
	],
	#category : #'Carp-Project'
}

{ #category : #'instance creation' }
CarpProject class >> fromDictionary: aDictionary [
	| project |
	project := self new
		root: (aDictionary at: 'root' ifAbsent: [ '' ]);
		entry: (aDictionary at: 'entry' ifAbsent: [ '' ]);
		yourself.
	project
		files: ((aDictionary at: 'files' ifAbsent: [ #() ])
				collect: [ :each |
					(CarpProjectFile fromDictionary: each)
						project: project;
						yourself ]).
	^ project
]

{ #category : #'instance creation' }
CarpProject class >> onRoot: aPathString [
	^ CarpServerClient default projectAt: aPathString
]

{ #category : #accessing }
CarpProject >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
CarpProject >> changed [
	self announcer announce: CarpProjectChanged new
]

{ #category : #accessing }
CarpProject >> gtActionLoadSessionFor: anAction [
	"Loading is explicit: it runs a compiler front end over the whole
	repository, which takes tens of seconds. Until it has run, definitions
	show their source but cannot be typed or checked."

	<gtAction>
	self isSessionLoaded ifTrue: [ ^ anAction noAction ].
	^ anAction button
		priority: 1;
		icon: BrGlamorousVectorIcons load;
		tooltip: 'Load this project into a compiler session';
		action: [ :aButton | self loadSessionInBackground ]
]

{ #category : #accessing }
CarpProject >> isSessionLoaded [
	^ sessionState == #loaded
]

{ #category : #accessing }
CarpProject >> isSessionLoading [
	^ sessionState == #loading
]

{ #category : #accessing }
CarpProject >> loadSession [
	"Warm the project's session. Answers how long the server took, in
	milliseconds."

	| answer |
	sessionState := #loading.
	self changed.
	answer := [ CarpServerClient default loadProjectAt: self root session: self sessionId ]
			on: Error
			do: [ :e |
				sessionState := #failed.
				self changed.
				^ e return: nil ].
	sessionMillis := answer at: 'millis' ifAbsent: [ 0 ].
	sessionState := #loaded.
	self changed.
	^ sessionMillis
]

{ #category : #accessing }
CarpProject >> loadSessionInBackground [
	self isSessionLoading ifTrue: [ ^ self ].
	[ self loadSession ] forkNamed: 'carp-project-session'
]

{ #category : #accessing }
CarpProject >> sessionId [
	"One session per repository, stable across reloads."

	^ 'project:' , self root
]

{ #category : #accessing }
CarpProject >> sessionMillis [
	^ sessionMillis ifNil: [ 0 ]
]

{ #category : #accessing }
CarpProject >> sessionState [
	^ sessionState ifNil: [ #unloaded ]
]

{ #category : #accessing }
CarpProject >> reload [
	"Re-read the tree from disk. The session keeps whatever it holds: it is
	warmed from the files, so it goes stale the moment they change, and
	reloading it is the expensive part."

	| fresh |
	fresh := CarpServerClient default projectAt: self root.
	self files: fresh files.
	self entry: fresh entry.
	self changed
]

{ #category : #accessing }
CarpProject >> definitions [
	"Every definition of the repository's own files, in load order."

	^ self projectFiles flatCollect: [ :each | each definitions ]
]

{ #category : #accessing }
CarpProject >> dependencyFiles [
	^ self files select: [ :each | each isDependency ]
]

{ #category : #accessing }
CarpProject >> entry [
	^ entry ifNil: [ '' ]
]

{ #category : #accessing }
CarpProject >> entry: aString [
	entry := aString
]

{ #category : #accessing }
CarpProject >> files [
	^ files ifNil: [ #() ]
]

{ #category : #accessing }
CarpProject >> files: aCollection [
	files := aCollection
]

{ #category : #accessing }
CarpProject >> gtDependenciesFor: aView [
	<gtView>
	self dependencyFiles ifEmpty: [ ^ aView empty ].
	^ aView columnedList
		title: 'Dependencies';
		priority: 4;
		items: [ self dependencyFiles ];
		column: 'Library' text: [ :each | each basename ] width: 200;
		column: 'Definitions' text: [ :each | each definitions size ] width: 90;
		column: 'Path' text: [ :each | each path ];
		send: [ :each | each ]
]

{ #category : #accessing }
CarpProject >> gtFilesFor: aView [
	"Load order is the order the compiler sees, dependencies first."

	<gtView>
	^ aView columnedList
		title: 'Load order';
		priority: 2;
		items: [ self files ];
		column: '#' text: [ :each :index | index ] width: 40;
		column: 'File' text: [ :each | self relativePathOf: each ];
		column: 'Kind' text: [ :each | each kind ] width: 80;
		column: 'Definitions' text: [ :each | each definitions size ] width: 90;
		send: [ :each | each ];
		actionUpdateButton;
		updateWhen: CarpProjectChanged in: [ self announcer ]
]

{ #category : #accessing }
CarpProject >> gtModulesFor: aView [
	<gtView>
	^ aView columnedTree
		title: 'Modules';
		priority: 1;
		items: [ self modules ];
		children: [ :each | each isString ifTrue: [ self definitionsOfModule: each ] ifFalse: [ #() ] ];
		column: 'Name'
			text: [ :each | each isString ifTrue: [ each ifEmpty: [ '(top level)' ] ] ifFalse: [ each shortName ] ];
		column: 'Kind' text: [ :each | each isString ifTrue: [ '' ] ifFalse: [ each head ] ] width: 110;
		send: [ :each | each isString ifTrue: [ self definitionsOfModule: each ] ifFalse: [ each ] ];
		updateWhen: CarpProjectChanged in: [ self announcer ]
]

{ #category : #accessing }
CarpProject >> definitionsOfModule: aModuleName [
	^ self definitions select: [ :each | each moduleName = aModuleName ]
]

{ #category : #accessing }
CarpProject >> modules [
	"The module names of the repository's own definitions, in load order of
	first appearance."

	| seen |
	seen := OrderedCollection new.
	self definitions
		do: [ :each | (seen includes: each moduleName) ifFalse: [ seen add: each moduleName ] ].
	^ seen
]

{ #category : #printing }
CarpProject >> printOn: aStream [
	aStream
		nextPutAll: self rootName;
		nextPutAll: ' (';
		print: self projectFiles size;
		nextPutAll: ' files, ';
		print: self definitions size;
		nextPutAll: ' definitions';
		nextPutAll: (self sessionState = #loaded
				ifTrue: [ ', session loaded' ]
				ifFalse: [ self sessionState = #loading
						ifTrue: [ ', loading session…' ]
						ifFalse: [ '' ] ]);
		nextPutAll: ')'
]

{ #category : #accessing }
CarpProject >> projectFiles [
	^ self files reject: [ :each | each isDependency ]
]

{ #category : #accessing }
CarpProject >> relativePathOf: aFile [
	aFile ifNil: [ ^ '' ].
	^ (aFile path beginsWith: self root)
		ifTrue: [ aFile path allButFirst: self root size + 1 ]
		ifFalse: [ aFile path ]
]

{ #category : #accessing }
CarpProject >> root [
	^ root ifNil: [ '' ]
]

{ #category : #accessing }
CarpProject >> root: aString [
	root := aString
]

{ #category : #accessing }
CarpProject >> rootName [
	| index |
	index := self root lastIndexOf: $/.
	^ index = 0
		ifTrue: [ self root ]
		ifFalse: [ self root allButFirst: index ]
]
