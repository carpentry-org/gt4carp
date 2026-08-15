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
		'announcer',
		'modules',
		'annotations',
		'definitionIndex',
		'exampleIndex',
		'sessionStamps',
		'requestedEntry'
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
	"A refreshing session is a loaded one: it holds everything it held before,
	and is being told about the files that changed under it."

	^ sessionState == #loaded or: [ sessionState == #refreshing ]
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
	answer := [ CarpServerClient default
			loadProjectAt: self root
			entry: self requestedEntry
			session: self sessionId ]
			on: Error
			do: [ :e |
				sessionState := #failed.
				self changed.
				^ e return: nil ].
	sessionMillis := answer at: 'millis' ifAbsent: [ 0 ].
	sessionState := #loaded.
	annotations := nil.
	exampleIndex := nil.
	self changed.
	"Checking works the moment the session is loaded; running a cell needs one
	more piece of session-wide work, and it is worth doing now rather than
	inside the first thing the playground is asked to evaluate."
	CarpServerClient default prepareSession: self sessionId.
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
	self forgetIndexes.
	self changed
]

{ #category : #private }
CarpProject >> forgetIndexes [
	"Everything derived from the files: which definition has which name,
	which examples exemplify what, and what the session says their types
	are."

	definitionIndex := nil.
	exampleIndex := nil.
	annotations := nil
]

{ #category : #accessing }
CarpProject >> annotations [
	"What the session knows about every name in the project: the types it
	inferred, and the environment the browser resolves names against. Asked
	once and kept — it is a few thousand rows — and dropped whenever the
	project is re-read."

	self isSessionLoaded ifFalse: [ ^ nil ].
	^ annotations
		ifNil: [ annotations := [ CarpServerClient default
					annotateSource: ''
					session: self sessionId ]
					on: Error
					do: [ :e | nil ] ]
]

{ #category : #accessing }
CarpProject >> environmentRowNamed: aName [
	^ self annotations
		ifNil: [ nil ]
		ifNotNil: [ :them | them environmentRowNamed: aName ]
]

{ #category : #accessing }
CarpProject >> inferredTypeOf: aName [
	^ (self environmentRowNamed: aName)
		ifNil: [ nil ]
		ifNotNil: [ :row | row at: 'type' ifAbsent: [ nil ] ]
]

{ #category : #accessing }
CarpProject >> membersOf: aDefinition [
	"Everything the session knows whose name lives under this type: the
	fields' accessors, the copy, delete and str the compiler derived, and
	whatever the project itself defines in that module. The file does not
	spell these out — only the session knows them."

	| prefix |
	self annotations ifNil: [ ^ #() ].
	prefix := aDefinition name , '.'.
	^ (self annotations environment
		select: [ :each | (each at: 'name' ifAbsent: [ '' ]) beginsWith: prefix ])
		asSortedCollection: [ :a :b | (a at: 'name') <= (b at: 'name') ]
]

{ #category : #accessing }
CarpProject >> definitionsByName [
	^ definitionIndex
		ifNil: [ definitionIndex := Dictionary new.
			self definitions
				do: [ :each | definitionIndex at: each name ifAbsentPut: [ each ] ].
			definitionIndex ]
]

{ #category : #accessing }
CarpProject >> examples [
	^ self definitions select: [ :each | each isExample ]
]

{ #category : #accessing }
CarpProject >> examplesFor: aDefinition [
	"The examples that exemplify a definition — by returning it, or by
	calling it. Built once for the whole project, because asking each
	example what it exemplifies means parsing it."

	exampleIndex
		ifNil: [ exampleIndex := Dictionary new.
			self examples
				do: [ :anExample |
					anExample exemplifiedNames
						do: [ :aName |
							(exampleIndex at: aName ifAbsentPut: [ OrderedCollection new ])
								add: anExample ] ] ].
	^ (exampleIndex at: aDefinition name ifAbsent: [ #() ]) asArray
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
CarpProject >> requestedEntry [
	"The entry this project was opened through, empty when the server was
	left to find the repository's own. It is asked for again on every reload
	and every session load, so the project stays the one that was opened."

	^ requestedEntry ifNil: [ '' ]
]

{ #category : #accessing }
CarpProject >> requestedEntry: aString [
	requestedEntry := aString
]

{ #category : #accessing }
CarpProject >> files [
	^ files ifNil: [ #() ]
]

{ #category : #accessing }
CarpProject >> files: aCollection [
	files := aCollection.
	modules := nil.
	definitionIndex := nil.
	exampleIndex := nil
]

{ #category : #accessing }
CarpProject >> gtDefinitionsFor: aView [
	"Every definition of the repository, searchable by name — the way you
	find something when you know what it is called but not where it lives."

	<gtView>
	^ aView columnedList
		title: 'Definitions';
		priority: 3;
		items: [ self definitions reject: [ :each | each isModule ] ];
		column: 'Name' text: [ :each | each name ];
		column: 'Kind' text: [ :each | each head ] width: 100;
		column: 'File' text: [ :each | each file basename ] width: 180;
		send: [ :each | each ];
		actionUpdateButton;
		updateWhen: CarpProjectChanged in: [ self announcer ]
]

{ #category : #actions }
CarpProject >> gtActionBrowseFor: anAction [
	"Open the browser: modules, definitions and the coder side by side, in a
	tab of its own."

	<gtAction>
	^ anAction button
		priority: 0;
		icon: BrGlamorousVectorIcons hierarchy;
		tooltip: 'Browse this project';
		action: [ :aButton | aButton phlow spawnTool: self asBrowserTool ]
]

{ #category : #inspecting }
CarpProject >> asBrowserTool [
	^ GtPhlowExplicitTool new
		name: self rootName;
		icon: BrGlamorousVectorIcons hierarchy;
		stencil: [ CarpBrowserElement onProject: self ];
		withLabelAndIconAptitude
]

{ #category : #accessing }
CarpProject >> newPlaygroundCoder [
	"A scratch coder on the project's own session: everything the project
	defines is in scope, so you can try a definition out where you wrote
	it."

	| coder |
	coder := GtCarpCoderModel code: ''.
	coder sessionId: self sessionId.
	^ coder
]

{ #category : #git }
CarpProject >> changes [
	"What git sees: the repository is the project, so its working tree is
	part of the project's state. Answers path -> status letters."

	| output |
	output := [ (GtExternalProcessBuilder new
			command: '/usr/bin/git';
			args: {'-C'. self root. 'status'. '--porcelain'};
			output) stdoutString ]
			on: Error
			do: [ :e | '' ].
	^ (output lines
		collect: [ :each |
			(each size > 3
				ifTrue: [ (each allButFirst: 3) -> (each first: 2) trimBoth ]
				ifFalse: [ nil ]) ])
		reject: [ :each | each isNil ]
]

{ #category : #accessing }
CarpProject >> gtChangesFor: aView [
	"The working tree against HEAD — what you would be committing."

	<gtView>
	^ aView columnedList
		title: 'Changes';
		priority: 6;
		items: [ self changes ];
		column: 'Status' text: [ :each | each value ] width: 70;
		column: 'File' text: [ :each | each key ];
		actionUpdateButton
]

{ #category : #checking }
CarpProject >> problems [
	"Check every file against the session and answer the diagnostics, each
	tagged with the file it came from. This is the project-wide view of what
	does not compile; a definition shows its own inline."

	| found |
	self isSessionLoaded ifFalse: [ ^ #() ].
	found := OrderedCollection new.
	self projectFiles
		do: [ :aFile |
			[ | annotations |
			annotations := CarpServerClient default
					annotateSource: aFile contents
					session: self sessionId.
			annotations diagnostics
				do: [ :each | found add: (CarpProblem onDiagnostic: each in: aFile) ] ]
				on: Error
				do: [ :e |  ] ].
	^ found
]

{ #category : #accessing }
CarpProject >> gtProblemsFor: aView [
	"What does not compile, across the whole project."

	<gtView>
	self isSessionLoaded ifFalse: [ ^ aView empty ].
	^ aView columnedList
		title: 'Problems';
		priority: 5;
		items: [ self problems ];
		column: 'Where' text: [ :each | each file basename ] width: 180;
		column: 'Phase' text: [ :each | each phase ] width: 90;
		column: 'Message' text: [ :each | each message ];
		send: [ :each | each ];
		actionUpdateButton
]

{ #category : #actions }
CarpProject >> gtActionReloadFor: anAction [
	"Re-read the tree from disk: the repository is the truth, and it changes
	under us whenever git does."

	<gtAction>
	^ anAction button
		priority: 2;
		icon: BrGlamorousVectorIcons refresh;
		tooltip: 'Re-read the project from disk';
		action: [ :aButton | self reload ]
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
		children: [ :each |
			(each isKindOf: CarpModule)
				ifTrue: [ each definitions ]
				ifFalse: [ #() ] ];
		column: 'Name'
			text: [ :each |
				(each isKindOf: CarpModule)
					ifTrue: [ each displayName ]
					ifFalse: [ each shortName ] ];
		column: 'Kind'
			text: [ :each | (each isKindOf: CarpModule) ifTrue: [ '' ] ifFalse: [ each head ] ]
			width: 110;
		send: [ :each | each ];
		updateWhen: CarpProjectChanged in: [ self announcer ]
]

{ #category : #accessing }
CarpProject >> definitionsOfModule: aModuleName [
	^ self definitions select: [ :each | each moduleName = aModuleName ]
]

{ #category : #accessing }
CarpProject >> moduleNames [
	"The module names of the repository's own definitions, in load order of
	first appearance."

	| seen |
	seen := OrderedCollection new.
	self definitions
		do: [ :each | (seen includes: each moduleName) ifFalse: [ seen add: each moduleName ] ].
	^ seen
]

{ #category : #accessing }
CarpProject >> modules [
	"The project's modules, in load order of first appearance. Cached: they
	are identity to everything that selects one, so rebuilding them on every
	call would lose the selection."

	^ modules
		ifNil: [ modules := self moduleNames collect: [ :each | CarpModule named: each in: self ] ]
]

{ #category : #accessing }
CarpProject >> moduleNamed: aString [
	^ self modules
		detect: [ :each | each name = aString ]
		ifNone: [ CarpModule named: aString in: self ]
]

{ #category : #accessing }
CarpProject >> definitionNamed: aString [
	^ self definitions detect: [ :each | each name = aString ] ifNone: [ nil ]
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
