"
I debug the program a Carp file becomes.

The other debugger, {{gtClass:name=CarpDAPDebugger}}, debugs the language that
runs while you compile. I debug what that language produced: a native binary,
stopped in a real process, with real memory behind its values.

The adapter is `lldb-dap`, which ships with the developer tools and speaks the
same protocol GT already drives. Editors drive it over standard input and
output; we start it as `lldb-dap -p <port>` and connect over a socket instead,
because GT's subprocess transport says of itself that it needs updating, and
the socket transport is the one already carrying the other debugger.

What you see depends on the debug information the C backend emits. Without
`#line` directives the frames are generated C, which is honest but not useful;
with them the frames are the Carp file the code was written in.
"
Class {
	#name : #CarpNativeDebugger,
	#superclass : #DAPDebugger,
	#instVars : [
		'program',
		'arguments',
		'serverExecutable',
		'port',
		'adapterProcess'
	],
	#category : #'Carp-Execution'
}

{ #category : #'instance creation' }
CarpNativeDebugger class >> onProgram: aFileReference [
	"Debug a compiled binary, stopped where its own code begins."

	^ self new
		program: aFileReference;
		start;
		yourself
]

{ #category : #'instance creation' }
CarpNativeDebugger class >> onSourceFile: aFileReference [
	"Build a Carp program for debugging and debug what comes out. This is the
	whole loop: a file goes in, a stopped program comes back."

	^ self onProgram: (self buildForDebugging: aFileReference)
]

{ #category : #building }
CarpNativeDebugger class >> buildForDebugging: aFileReference [
	"Compile a Carp file the way the command line does, with -g: debug
	information, no optimization, and the generated C kept beside the binary,
	because that C is the source a debugger of a compiled Carp program shows.

	The binary lands beside the source rather than in a temporary directory:
	its debug information names the C by path, so both have to stay where the
	build put them."

	| binary out |
	binary := aFileReference parent / aFileReference basenameWithoutExtension.
	out := GtExternalProcessBuilder new
			command: CarpServerClient compilerBinary;
			args: {'-g'.
					'-b'.
					'-c'.
					CarpServerClient coreDirectory.
					'-o'.
					binary fullName.
					aFileReference fullName};
			output.
	out status isSuccess
		ifFalse: [ ^ self error: 'carp-compiler could not build ' , aFileReference basename
				, ': ' , out stderrString trimBoth ].
	^ binary
]

{ #category : #accessing }
CarpNativeDebugger class >> defaultServerExecutable [
	"lldb-dap comes with the command line tools. `xcrun` is the supported way
	to find it, but it is one process spawn per lookup, so the usual path is
	tried first."

	| standard |
	standard := '/Library/Developer/CommandLineTools/usr/bin/lldb-dap' asFileReference.
	standard exists ifTrue: [ ^ standard ].
	^ (GtSubprocessWithInMemoryOutput new
		command: '/usr/bin/xcrun';
		arguments: #('-f' 'lldb-dap');
		runAndWait;
		stdout) trimBoth asFileReference
]

{ #category : #accessing }
CarpNativeDebugger >> program [
	^ program
]

{ #category : #accessing }
CarpNativeDebugger >> program: aFileReference [
	program := aFileReference asFileReference
]

{ #category : #accessing }
CarpNativeDebugger >> arguments [
	^ arguments ifNil: [ #() ]
]

{ #category : #accessing }
CarpNativeDebugger >> arguments: anArray [
	arguments := anArray
]

{ #category : #accessing }
CarpNativeDebugger >> serverExecutable [
	^ serverExecutable
		ifNil: [ serverExecutable := self class defaultServerExecutable ]
]

{ #category : #accessing }
CarpNativeDebugger >> serverExecutable: aFileReference [
	serverExecutable := aFileReference asFileReference
]

{ #category : #accessing }
CarpNativeDebugger >> port [
	"One adapter per debugged program, so the port is per debugger rather than
	a constant."

	^ port ifNil: [ port := 9000 + (Random new nextInteger: 500) ]
]

{ #category : #accessing }
CarpNativeDebugger >> port: anInteger [
	port := anInteger
]

{ #category : #'start-stop' }
CarpNativeDebugger >> start [
	"Spawn the adapter and stop the program where its own code begins.

	Stopping at the entry point stops at `_dyld_start`, which is the loader
	rather than the program: there is no source to show and nothing to step
	that anyone wrote. A breakpoint on `main` and one continue lands in the
	program instead, which is where a reader thinks `stop at the start` means."

	localRoot ifNil: [ localRoot := program parent ].
	self startAdapter.
	client := self connectToAdapter.
	self initializeRemote.
	self launchProgram.
	self stopAtMain.
	self configurationDone.
	self requestAllThreads.
	self requestAllStackTraces.
	self continueToMain
]

{ #category : #'start-stop' }
CarpNativeDebugger >> stopAtMain [
	"A breakpoint on the C entry point, which is the one symbol a Carp program
	has under a name the debugger and the reader agree on. Carp's own `main`
	is one step further in, under its mangled name."

	client setFunctionBreakpoints: (DAPSetFunctionBreakpointsArguments new
			breakpoints: { { 'name' -> 'main' } asDictionary })
]

{ #category : #'start-stop' }
CarpNativeDebugger >> continueToMain [
	"Run from the loader to the breakpoint on main. The adapter answers the
	continue before the program stops again, so wait for the stop rather than
	for the reply, and give up rather than hang if it never comes."

	| deadline |
	client stoppedThread ifNil: [ ^ self ].
	client stoppedThread continue.
	deadline := DateAndTime now + 10 seconds.
	[ client isStopped or: [ DateAndTime now > deadline ] ]
		whileFalse: [ (Delay forMilliseconds: 50) wait ]
]

{ #category : #'start-stop' }
CarpNativeDebugger >> startAdapter [
	"lldb-dap listens when given a port. It exits with the session, so there is
	nothing to reuse and nothing to clean up between programs."

	adapterProcess := GtExternalProcessBuilder new
			command: self serverExecutable fullName;
			args: {'-p'. self port printString};
			spawn
]

{ #category : #'start-stop' }
CarpNativeDebugger >> connectToAdapter [
	"Retry the real connection rather than testing for one first: lldb-dap
	serves a single client, so a connection made to ask whether it is up is
	the session, and closing it ends the adapter."

	| deadline address |
	deadline := DateAndTime now + 20 seconds.
	address := NetNameResolver addressForName: '127.0.0.1'.
	[ ^ DAPClient connectTo: address port: self port debugger: self ]
		on: Error
		do: [ :e |
			DateAndTime now > deadline ifTrue: [ e pass ].
			(Delay forMilliseconds: 100) wait.
			e retry ]
]

{ #category : #'start-stop' }
CarpNativeDebugger >> initializeRemote [
	| requestArguments request |
	requestArguments := DAPInitializeRequestArguments new
			clientID: 'gtoolkit';
			clientName: 'Gtoolkit Remote Debugger';
			adapterID: 'lldb-dap';
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
			arguments: requestArguments;
			command: 'initialize'.
	client sendMessage: request
]

{ #category : #'start-stop' }
CarpNativeDebugger >> launchProgram [
	"lldb-dap's own launch shape: the program, its arguments, and a stop at
	entry so there is something to look at before anything has run."

	client launchWithArguments: {'name' -> 'Carp: run'.
			'type' -> 'lldb-dap'.
			'request' -> 'launch'.
			'program' -> program fullName.
			'args' -> self arguments.
			'stopOnEntry' -> true.
			'cwd' -> localRoot fullName} asDictionary
]

{ #category : #opening }
CarpNativeDebugger >> open [
	"In a pager, the same as the compile-time debugger."

	^ GtPager
		openWrappedOn: (GtDAPDebuggerElement new debuggerClient: self)
		title: 'Carp native'
			, (program ifNil: [ '' ] ifNotNil: [ :each | ': ' , each basename ])
]

{ #category : #inspecting }
CarpNativeDebugger >> gtDebuggerFor: aView [
	<gtView>
	^ aView explicit
		title: 'Debugger';
		priority: 1;
		stencil: [ GtDAPDebuggerElement new debuggerClient: self ]
]

{ #category : #printing }
CarpNativeDebugger >> printOn: aStream [
	aStream nextPutAll: 'carp native debugger'.
	program ifNotNil: [ :each | aStream nextPutAll: ' on '; nextPutAll: each basename ]
]
