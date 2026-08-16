"
I debug the language that runs while you compile.

Carp has two languages in one file: the static one that becomes a program,
and the dynamic one — macros, `defndynamic`, compile-time functions — that
runs inside the compiler and decides what the static one will be. I am the
debugger for the second, and I am a {{gtClass:name=DAPDebugger}} so that GT
drives me with the machinery it already drives Python, JavaScript and gdb
with. Nothing here is a debugger of my own invention.

The adapter I talk to is the carp server in `--dap` mode. It records one
expansion rather than suspending the compiler, which is why it advertises
`supportsStepBack`: walking a recording backwards costs what walking it
forwards costs, and a suspended interpreter cannot offer that at all.

Compiled Carp is a different debugger with a different shape: a native
binary, driven by {{gtClass:name=DAPGdbDebugger}} once the backend emits
`#line` directives. It shares this protocol and nothing else.

One adapter serves one session at a time — a compiler session is expensive
enough that running several is worse than sharing one — so starting me
releases whoever held it before. Two Carp debuggers open at once is one
debugger and one that has been let go of, not two sessions.
"
Class {
	#name : #CarpDAPDebugger,
	#superclass : #DAPDebugger,
	#instVars : [
		'host',
		'port',
		'source',
		'adapterProcess'
	],
	#classVars : [
		'Current'
	],
	#category : #'Carp-Execution'
}

{ #category : #'instance creation' }
CarpDAPDebugger class >> onSource: aSourceString [
	"Start an adapter of our own and debug the expansion of this source."

	^ self new
		source: aSourceString;
		start;
		yourself
]

{ #category : #accessing }
CarpDAPDebugger class >> defaultPort [
	"The adapter listens on a port of its own: the notebook protocol and the
	debug protocol are different conversations."

	^ 8996
]

{ #category : #accessing }
CarpDAPDebugger >> source [
	^ source ifNil: [ '' ]
]

{ #category : #accessing }
CarpDAPDebugger >> source: aString [
	source := aString
]

{ #category : #accessing }
CarpDAPDebugger >> hostName [
	"The name to resolve and to show; #host holds the resolved address."

	^ '127.0.0.1'
]

{ #category : #accessing }
CarpDAPDebugger >> port [
	^ port ifNil: [ port := self class defaultPort ]
]

{ #category : #accessing }
CarpDAPDebugger >> port: anInteger [
	port := anInteger
]

{ #category : #accessing }
CarpDAPDebugger class >> current [
	"The debugger holding the adapter's session, if one still does."

	^ Current
]

{ #category : #'start-stop' }
CarpDAPDebugger >> start [
	"Bring up an adapter if none is listening, then debug through it. The
	session belongs to one debugger at a time, so take it from whoever had
	it: an abandoned debugger holding the adapter would leave this one
	waiting on a socket nobody is reading."

	localRoot ifNil: [ localRoot := FileLocator temp asFileReference ].
	Current ifNotNil: [ :each | each ~~ self ifTrue: [ each release ] ].
	self isAdapterListening ifFalse: [ self startAdapter ].
	self connectTo: (NetNameResolver addressForName: self hostName) port: self port.
	Current := self
]

{ #category : #'start-stop' }
CarpDAPDebugger >> release [
	"Give the adapter's session back. A debugger that is done with it has
	nothing to say about failing to say goodbye."

	[ self disconnect ] on: Error do: [ :e |  ].
	Current == self ifTrue: [ Current := nil ]
]

{ #category : #'start-stop' }
CarpDAPDebugger >> isAdapterListening [
	^ [ (SocketStream openConnectionToHostNamed: self hostName port: self port) close.
	true ]
		on: Error
		do: [ :e | false ]
]

{ #category : #'start-stop' }
CarpDAPDebugger >> startAdapter [
	"The adapter is the carp server in --dap mode: same sessions, a different
	protocol over them."

	adapterProcess := GtExternalProcessBuilder new
			command: CarpServerClient serverBinary;
			args: {'--dap'.
					self port printString.
					CarpServerClient compilerBinary.
					CarpServerClient coreDirectory.
					CarpServerClient workDirectory.
					CarpServerClient notebookLibrary};
			spawn.
	self waitForAdapter
]

{ #category : #'start-stop' }
CarpDAPDebugger >> waitForAdapter [
	"An adapter builds its compiler session before it opens the port, so the
	wait here is a compile, not a socket handshake. It is worth the minutes:
	the alternative is paying that time inside the first request, where the
	protocol has a minute of patience and no more."

	| deadline |
	deadline := DateAndTime now + 5 minutes.
	[ self isAdapterListening ] whileFalse: [
		DateAndTime now > deadline
			ifTrue: [ ^ self error: 'the carp debug adapter did not come up' ].
		(Delay forMilliseconds: 100) wait ]
]

{ #category : #'start-stop' }
CarpDAPDebugger >> connectTo: anAddress port: aPortNumber [
	"The same shape every DAP debugger in GT has: connect, initialize, say
	what to debug, then ask where it stopped.

	The address is an address, not a name: the socket comms open the
	connection with #openConnectionToHost:, which takes the four bytes."

	host := anAddress.
	port := aPortNumber.
	client := DAPClient connectTo: host port: port debugger: self.
	self initializeRemote.
	self launchExpansion.
	self configurationDone.
	self requestAllThreads.
	self requestAllStackTraces
]

{ #category : #'start-stop' }
CarpDAPDebugger >> initializeRemote [
	| arguments request |
	arguments := DAPInitializeRequestArguments new
			clientID: 'gtoolkit';
			clientName: 'Gtoolkit Remote Debugger';
			adapterID: 'carp';
			pathFormat: 'path';
			linesStartAt1: true;
			columnsStartAt1: true;
			supportsVariableType: true;
			supportsVariablePaging: false;
			supportsRunInTerminalRequest: false;
			locale: 'en-us';
			supportsProgressReporting: false;
			supportsInvalidatedEvent: false.
	request := DAPInitializeRequest new
			arguments: arguments;
			command: 'initialize'.
	client sendMessage: request
]

{ #category : #'start-stop' }
CarpDAPDebugger >> launchExpansion [
	"What there is to debug is an expansion of this source."

	| request |
	request := DAPLaunchRequest new
			arguments: {'name' -> 'Carp: expand'.
					'type' -> 'carp'.
					'request' -> 'launch'.
					'source' -> self source} asDictionary;
			command: 'launch'.
	client sendMessage: request
]

{ #category : #opening }
CarpDAPDebugger >> open [
	"In a pager, which is how GT opens a tool. The window comes with the
	paginator, so spawning from a frame or a value lands in a page beside this
	one rather than nowhere. Inspecting me still answers the same element, for
	when a pane is what you wanted."

	^ GtPager
		openWrappedOn: (GtDAPDebuggerElement new debuggerClient: self)
		title: 'Carp compile time'
]

{ #category : #accessing }
CarpDAPDebugger >> styleSourceText: aText [
	"The debugger element shows source it cannot read: it debugs whatever the
	adapter debugs. Every frame here is Carp, so it gets the same styler the
	editors use. The stopped-at highlight is applied before this and marked
	not-overwritable, so it survives."

	^ [ CarpParser gtStyler style: aText ] on: Error do: [ :e | aText ]
]

{ #category : #inspecting }
CarpDAPDebugger >> gtDebuggerFor: aView [
	"GT's own debugger element, on this session. It is the same element that
	drives Python and gdb: frames on the left, the file the frame is in on the
	right, stepping in the toolbar."

	<gtView>
	^ aView explicit
		title: 'Debugger';
		priority: 1;
		stencil: [ GtDAPDebuggerElement new debuggerClient: self ]
]

{ #category : #printing }
CarpDAPDebugger >> printOn: aStream [
	aStream nextPutAll: 'carp compile-time debugger'
]
