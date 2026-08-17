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
		'adapterProcess',
		'sourceFile',
		'sourceLine',
		'sourceBreakpointResolved'
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
	whole loop: a file goes in, a stopped program comes back, standing in that
	same file."

	^ self new
		program: (self buildForDebugging: aFileReference);
		sourceFile: aFileReference;
		start;
		yourself
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
CarpNativeDebugger >> styleSourceText: aText [
	"A frame built with debug information stands in the Carp it was written
	as, so it gets the styler the editors use. A frame in a C runtime file
	does not, and is left alone: styling C as Carp reads worse than not
	styling it at all."

	^ (self stoppedInCarp and: [ aText isNotNil ])
		ifTrue: [ [ CarpParser gtStyler style: aText ] on: Error do: [ :e | aText ] ]
		ifFalse: [ aText ]
]

{ #category : #accessing }
CarpNativeDebugger >> formRangeIn: aString line: aLine [
	"The range of the form that begins on a line.

	A frame is about a form, and a form is not a line: `(let [x 10]` carries
	its body on the lines after it. Marking the line marks a fragment of what
	the program is actually at. The adapter cannot say where the form ends —
	it reports positions in the C — so the extent is read off the source by
	matching parentheses, skipping any inside strings."

	| indexes index open depth inString escaped |
	indexes := [ aString gtIndexOfLineNumber: aLine ] on: Error do: [ :e | nil ].
	indexes ifNil: [ ^ nil ].
	index := indexes key.
	open := nil.
	[ open isNil and: [ index <= (indexes value min: aString size) ] ] whileTrue: [
		(aString at: index) = $( ifTrue: [ open := index ].
		index := index + 1 ].
	open ifNil: [ ^ nil ].
	depth := 0.
	inString := false.
	escaped := false.
	index := open.
	[ index <= aString size ] whileTrue: [
		| char |
		char := aString at: index.
		inString
			ifTrue: [
				escaped
					ifTrue: [ escaped := false ]
					ifFalse: [
						char = $\ ifTrue: [ escaped := true ].
						char = $" ifTrue: [ inString := false ] ] ]
			ifFalse: [
				char = $" ifTrue: [ inString := true ].
				char = $( ifTrue: [ depth := depth + 1 ].
				char = $) ifTrue: [
					depth := depth - 1.
					depth = 0 ifTrue: [ ^ open to: index ] ] ].
		index := index + 1 ].
	^ nil
]

{ #category : #accessing }
CarpNativeDebugger >> framesCarryColumns [
	"No: the columns come from the generated C, and the file on screen is the
	Carp it was generated from. The line is right — that is what the source map
	is for — but the column belongs to another text, so a frame marks its whole
	line rather than a range that means nothing here."

	^ false
]

{ #category : #accessing }
CarpNativeDebugger >> stoppedInCarp [
	"Whether the frame being shown came from a Carp file. Without `#line`
	directives in the build it never does, and the debugger shows the C it
	really runs."

	^ [ | thread |
	thread := self stoppedThread.
	thread notNil and: [ thread stackFrames anySatisfy: [ :each |
		each source notNil and: [ (each source path ifNil: [ '' ]) endsWith: '.carp' ] ] ] ]
		on: Error
		do: [ :e | false ]
]

{ #category : #naming }
CarpNativeDebugger >> displayNameForVariable: aName [
	"What a variable was called before the compiler wrote it as C.

	A local is written L<n>_<name>_<id> and a global C<n>_<name>__<type>; both
	carry the length of the encoded name, so both can be read back the same
	way. Anything else — argc, a runtime constant — is its own name already."

	| separator count |
	(aName size > 2 and: [ aName first = $L ]) ifFalse: [
		^ self class carpNameFor: aName ].
	separator := aName indexOf: $_ startingAt: 2.
	separator = 0 ifTrue: [ ^ aName ].
	count := [ (aName copyFrom: 2 to: separator - 1) asNumber ] on: Error do: [ :e | nil ].
	(count isInteger and: [ count > 0 and: [ separator + count <= aName size ] ])
		ifFalse: [ ^ aName ].
	^ self class decodeCarpName: (aName copyFrom: separator + 1 to: separator + count)
]

{ #category : #naming }
CarpNativeDebugger >> hidesVariable: aName [
	"Whether a variable is the compiler's own bookkeeping rather than
	something in the program. Temporaries are named for what they do — lifting
	a reference, hoisting a value — and begin with an underscore no Carp name
	starts with."

	| name |
	name := self displayNameForVariable: aName.
	^ (name beginsWith: '_') or: [ name beginsWith: 'carp_' ]
]

{ #category : #naming }
CarpNativeDebugger >> displayNameForFrame: aDAPStackFrame [
	"What to call a frame. The C name a Carp definition compiles to is the Carp
	name with its type written after it, and a reader wants the first half."

	^ self class carpNameFor: (aDAPStackFrame name ifNil: [ '' ])
]

{ #category : #naming }
CarpNativeDebugger class >> carpNameFor: aString [
	"The Carp name a compiled symbol came from.

	The compiler writes a definition as C<n>_<name>__<type>, where n counts the
	characters of the encoded name (see CAbi.mangle). A symbol without that
	shape belongs to the C runtime rather than to Carp, and is answered as it
	is: `main` and `carp_init_globals` are their own names."

	| separator count encoded |
	(aString size > 2 and: [ aString first = $C ]) ifFalse: [ ^ aString ].
	separator := aString indexOf: $_ startingAt: 2.
	separator = 0 ifTrue: [ ^ aString ].
	count := [ (aString copyFrom: 2 to: separator - 1) asNumber ]
			on: Error
			do: [ :e | nil ].
	(count isNil or: [ count isInteger not or: [ count <= 0 ] ]) ifTrue: [ ^ aString ].
	separator + count > aString size ifTrue: [ ^ aString ].
	encoded := aString copyFrom: separator + 1 to: separator + count.
	^ self decodeCarpName: encoded
]

{ #category : #naming }
CarpNativeDebugger class >> decodeCarpName: aString [
	"Undo the encoding a C identifier forces on a Carp name: everything C
	cannot spell is written _x<code>_, and the code is decimal, not hex."

	| out index |
	out := WriteStream on: String new.
	index := 1.
	[ index <= aString size ] whileTrue: [
		| escape |
		escape := ((aString at: index) = $_ and: [
				index < aString size and: [ (aString at: index + 1) = $x ] ])
					ifTrue: [ aString indexOf: $_ startingAt: index + 2 ]
					ifFalse: [ 0 ].
		escape > 0
			ifTrue: [
				| code |
				code := [ (aString copyFrom: index + 2 to: escape - 1) asNumber ]
						on: Error
						do: [ :e | nil ].
				code isInteger
					ifTrue: [ out nextPut: (Character value: code). index := escape + 1 ]
					ifFalse: [ out nextPut: (aString at: index). index := index + 1 ] ]
			ifFalse: [ out nextPut: (aString at: index). index := index + 1 ] ].
	^ out contents
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
CarpNativeDebugger >> sourceFile [
	"The Carp file this program was built from, when the caller knows it. It
	is what `runIntoSource` steps towards."

	^ sourceFile
]

{ #category : #accessing }
CarpNativeDebugger >> sourceFile: aFileReference [
	sourceFile := aFileReference ifNotNil: [ :each | each asFileReference ]
]

{ #category : #accessing }
CarpNativeDebugger >> sourceLine [
	"The line the program starts running on.

	A caller that built the program can say; one that cannot is not left with
	line one, because an adapter slides that to the first line holding code —
	which is inside the first function defined, and nothing has called it yet.
	Read from the file instead, by the same rule the builder uses: the first
	top-level form that is not a definition."

	^ sourceLine ifNil: [ sourceLine := self entryLineInSourceFile ]
]

{ #category : #accessing }
CarpNativeDebugger class >> definitionHeads [
	"Heads that introduce something rather than do something. Kept in step
	with the same list in the server, which shapes the file this reads."

	^ #('defn' 'defn-' 'def' 'defmodule' 'deftype' 'defmacro' 'defview'
		'defndynamic' 'defdynamic' 'definterface' 'defalias' 'sig' 'doc'
		'hidden' 'private' 'use' 'load' 'load-once' 'load-and-use'
		'register' 'register-type' 'deftemplate' 'derive' 'implements'
		'add-cflag' 'add-lib' 'add-pkg' 'relative-include' 'add-c')
]

{ #category : #accessing }
CarpNativeDebugger >> entryLineInSourceFile [
	"The line of the first top-level form in the file that runs something.

	Forms are found by counting parentheses at the top level, which is all
	that is needed to tell one top-level form from the next; strings and
	character literals are skipped so a paren inside them does not count."

	| text depth start line startLine inString escaped |
	sourceFile ifNil: [ ^ 1 ].
	text := [ sourceFile contents ] on: Error do: [ :e | ^ 1 ].
	depth := 0.
	line := 1.
	start := nil.
	startLine := 1.
	inString := false.
	escaped := false.
	1 to: text size do: [ :index |
		| char |
		char := text at: index.
		char = Character lf ifTrue: [ line := line + 1 ].
		inString
			ifTrue: [
				escaped
					ifTrue: [ escaped := false ]
					ifFalse: [
						char = $\ ifTrue: [ escaped := true ].
						char = $" ifTrue: [ inString := false ] ] ]
			ifFalse: [
				char = $" ifTrue: [ inString := true ].
				char = $( ifTrue: [
					depth = 0 ifTrue: [ start := index. startLine := line ].
					depth := depth + 1 ].
				char = $) ifTrue: [
					depth := depth - 1.
					(depth = 0 and: [ start notNil ]) ifTrue: [
						(self class definitionHeads includes:
							(self headOf: (text copyFrom: start to: index)))
								ifFalse: [ ^ startLine ].
						start := nil ] ] ] ].
	^ 1
]

{ #category : #accessing }
CarpNativeDebugger >> headOf: aForm [
	"The symbol a form starts with, or an empty string when it starts with
	something else."

	| rest end |
	rest := aForm allButFirst trimLeft.
	end := rest indexOfAnyOf: (CharacterSet with: Character space with: Character tab
		with: Character cr with: Character lf) ifAbsent: [ rest size + 1 ].
	^ (rest first: end - 1) copyWithout: $)
]

{ #category : #accessing }
CarpNativeDebugger >> sourceLine: anInteger [
	sourceLine := (anInteger isNil or: [ anInteger isNumber not or: [ anInteger < 1 ] ])
		ifTrue: [ nil ]
		ifFalse: [ anInteger asInteger ]
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
	self trace: 'adapter'.
	self startAdapter.
	self trace: 'connect'.
	client := self connectToAdapter.
	self trace: 'initialize'.
	self initializeRemote.
	self trace: 'launch'.
	self launchProgram.
	self trace: 'breakpoints'.
	self stopAtMain.
	self trace: 'configurationDone'.
	self configurationDone.
	self trace: 'threads'.
	self requestAllThreads.
	self trace: 'stackTraces'.
	self requestAllStackTraces.
	self trace: 'run'.
	self continueToMain.
	self trace: 'stopped'
]

{ #category : #'start-stop' }
CarpNativeDebugger >> trace: aString [
	"Where start got to. What happens on a button press happens in a forked
	process inside a live image, so the only account of it that survives is
	one written down."

	| file previous |
	file := '/tmp/carp-native-action.log' asFileReference.
	previous := file exists ifTrue: [ file contents ] ifFalse: [ '' ].
	file writeStreamDo: [ :stream |
		stream
			nextPutAll: previous;
			nextPutAll: DateAndTime now printString;
			nextPutAll: '  debugger: ';
			nextPutAll: aString;
			nextPut: Character lf ]
]

{ #category : #'start-stop' }
CarpNativeDebugger >> carpMainSymbol [
	"What `(defn main [] ...)` is called once compiled: the name, its length,
	and the key of its type, which for a main taking nothing and answering
	nothing is always this."

	^ 'C4_main__F0_Z1_U'
]

{ #category : #'start-stop' }
CarpNativeDebugger >> breakpointOnFunction: aName [
	"Ask for a breakpoint on one symbol and answer what the adapter made of it.

	The client's own setFunctionBreakpoints: registers the answer without
	handing it back, and what matters here is whether the symbol was found at
	all — an adapter reports that by answering a place for it."

	| request response found |
	request := DAPSetFunctionBreakpointsRequest new
			arguments: (DAPSetFunctionBreakpointsArguments new
					breakpoints: { { 'name' -> aName } asDictionary }).
	response := client sendMessageAndWait: request.
	found := (response breakpoints ifNil: [ #() ]) collect: [ :each |
		DAPBreakpoint fromDictionary: each client: client ].
	found do: [ :each | client registerBreakpoint: each ].
	^ found
]

{ #category : #'start-stop' }
CarpNativeDebugger >> stopAtMain [
	"Ask to stop where the program starts doing what someone wrote.

	A breakpoint in the file the program was built from is the reliable way
	there: an adapter moves it to the first line that has code, and the
	program runs to it by itself. The entry points are asked for as well, so a
	build with no line information still stops somewhere rather than running
	to completion."

	self breakpointInSourceFile.
	(self breakpointOnFunction: self carpMainSymbol)
		ifNotEmpty: [ :found |
			(found anySatisfy: [ :each | each line notNil ]) ifTrue: [ ^ self ] ].
	self breakpointOnFunction: 'main'
]

{ #category : #'start-stop' }
CarpNativeDebugger >> breakpointInSourceFile [
	"A breakpoint on the first line of the program's own file, and whether the
	adapter found a line to put it on.

	The answer comes from the response and is remembered here. Asking the
	client's registry afterwards does not work: it keeps breakpoints without
	the source they were set in, so the question `is there one in this file`
	has no answer there."

	| request response places |
	sourceBreakpointResolved := false.
	sourceFile ifNil: [ ^ false ].
	request := DAPSetBreakpointsRequest new
			arguments: (DAPSetBreakpointsArguments new
					source: (DAPSource new
							name: sourceFile basename;
							path: sourceFile fullName);
					lines: { self sourceLine };
					breakpoints: { { 'line' -> self sourceLine } asDictionary };
					sourceModified: false).
	response := [ client sendMessageAndWait: request ]
			on: Error
			do: [ :e | ^ false ].
	places := (response breakpoints ifNil: [ #() ]) collect: [ :each |
		DAPBreakpoint fromDictionary: each client: client ].
	places do: [ :each | client registerBreakpoint: each ].
	sourceBreakpointResolved := places anySatisfy: [ :each | each line notNil ].
	self trace: 'source breakpoint in ' , sourceFile basename , ' asked at '
		, self sourceLine printString , ', set at '
		, (places collect: [ :each | each line printString ]) asArray printString.
	^ sourceBreakpointResolved
]

{ #category : #'start-stop' }
CarpNativeDebugger >> continueToMain [
	"Run to the entry point, and then into the program itself."

	self runToBreakpoint.
	self trace: 'first stop in source: ' , self stoppedInSourceFile printString
		, ', source breakpoint: ' , self hasSourceBreakpoint printString.
	self stoppedInSourceFile ifTrue: [ ^ self ].
	"the entry point was hit first: the program's own code is one more run
	away when a breakpoint in it resolved, and only stepping otherwise"
	self hasSourceBreakpoint
		ifTrue: [ self runToBreakpoint ]
		ifFalse: [ self runIntoSource ]
]

{ #category : #'start-stop' }
CarpNativeDebugger >> hasSourceBreakpoint [
	"Whether the breakpoint asked for in the program's own file resolved, as
	the adapter answered when it was set."

	^ sourceBreakpointResolved = true
]

{ #category : #'start-stop' }
CarpNativeDebugger >> runIntoSource [
	"Step until the program is standing in the file it was built from.

	The entry point runs a program's top-level forms, so stopping there means
	standing in generated C with the reader's own code one step away. Stepping
	over until the frame is their file lands on the first thing the cell
	actually does. A file that never comes up — a cell that only defines
	things — leaves the debugger where it was rather than running the program
	out from under it."

	| steps |
	steps := 0.
	[ steps < 12
		and: [ client isStopped and: [ self stoppedInSourceFile not ] ] ] whileTrue: [
		steps := steps + 1.
		self stepOverAndWait ]
]

{ #category : #'start-stop' }
CarpNativeDebugger >> stoppedInSourceFile [
	"Whether the frame on top stands in the program's own Carp.

	A caller that knows which file it built says so, and that file is the
	answer. A caller that does not is not left without one: any Carp file
	outside the standard library is the program's own, because the standard
	library is the only Carp a program did not write itself. Relying on the
	caller here made this work in one place and not in the other."

	| path |
	path := [ client stoppedThread
		ifNil: [ ^ false ]
		ifNotNil: [ :thread | thread stackFrames
			ifEmpty: [ ^ false ]
			ifNotEmpty: [ :frames | frames first source
				ifNil: [ ^ false ]
				ifNotNil: [ :each | each path ifNil: [ ^ false ] ] ] ] ]
			on: Error
			do: [ :e | ^ false ].
	sourceFile ifNotNil: [ ^ path endsWith: sourceFile basename ].
	^ (path endsWith: '.carp') and: [ (path includesSubstring: self class coreDirectory) not ]
]

{ #category : #accessing }
CarpNativeDebugger class >> coreDirectory [
	"Where the standard library lives. Frames in it are Carp, but they are not
	the program's own code."

	^ [ CarpServerClient coreDirectory ] on: Error do: [ :e | '/carp-core-unknown' ]
]

{ #category : #stepping }
CarpNativeDebugger >> stepIntoFor: aThread [
	"Step into, then keep going until the program stands in Carp again.

	A step lands wherever the next line of C is, and some of those lines are
	temporaries the compiler wrote for a form nobody typed. Stopping there
	shows a file the reader has never seen. The standard library is Carp and
	is worth stopping in; the generated C of this very program is not."

	aThread stepInto.
	self waitForStopAfter: aThread.
	self skipGeneratedCode
]

{ #category : #stepping }
CarpNativeDebugger >> stepOverFor: aThread [
	"Step over, then out of any generated code it lands in."

	aThread next.
	self waitForStopAfter: aThread.
	self skipGeneratedCode
]

{ #category : #stepping }
CarpNativeDebugger >> stepOutFor: aThread [
	"Step out, then out of any generated code it lands in."

	aThread stepOut.
	self waitForStopAfter: aThread.
	self skipGeneratedCode
]

{ #category : #stepping }
CarpNativeDebugger >> skipGeneratedCode [
	"Step on while the program stands in code it was not written as.

	Bounded, because a program can end while being stepped, and stopping
	stepping is better than stepping a program that is no longer there."

	| steps |
	steps := 0.
	[ steps < 8
		and: [ client isStopped and: [ self stoppedInGeneratedCode ] ] ] whileTrue: [
		| thread |
		steps := steps + 1.
		thread := client stoppedThread ifNil: [ ^ self ].
		"over, not into: the statement standing here is one the compiler
		wrote, and what is inside it is more of the same. Stepping over lands
		on the next thing that was written."
		[ thread next ] on: Error do: [ :e | ^ self ].
		self waitForStopAfter: thread ]
]

{ #category : #stepping }
CarpNativeDebugger >> stoppedInGeneratedCode [
	"Whether the frame on top is in the C this program was compiled to, rather
	than in anyone's source."

	^ [ client stoppedThread
		ifNil: [ false ]
		ifNotNil: [ :thread | thread stackFrames
			ifEmpty: [ false ]
			ifNotEmpty: [ :frames | frames first source
				ifNil: [ false ]
				ifNotNil: [ :source | (source path ifNil: [ '' ]) endsWith: '.c' ] ] ] ]
		on: Error
		do: [ :e | false ]
]

{ #category : #'start-stop' }
CarpNativeDebugger >> stepOverAndWait [
	"One step, waited out: the adapter answers before the program stops."

	| thread |
	thread := client stoppedThread ifNil: [ ^ self ].
	"a step past the last thing a program does runs it to the end, and the
	step after that has no program to step: the adapter says so with an error
	rather than a stop"
	[ thread next ] on: Error do: [ :e | ^ self ].
	self waitForStopAfter: thread
]

{ #category : #'start-stop' }
CarpNativeDebugger >> runToBreakpoint [
	"Let the program run to the next breakpoint. The adapter answers the
	continue before the program stops again, so wait for the stop rather than
	for the reply, and give up rather than hang if it never comes."

	| thread |
	thread := client stoppedThread ifNil: [ ^ self ].
	thread continue.
	self waitForStopAfter: thread
]

{ #category : #'start-stop' }
CarpNativeDebugger >> waitForStopAfter: aThread [
	"Wait for the program to stop again, not for it to be stopped.

	A client stays marked stopped for a moment after it is told to continue,
	so waiting for `isStopped` answers straight away with the stop it was
	already at — and whoever asked then reads a stack the program has left.
	Waiting for it to start first, then to stop, waits for the right thing."

	| deadline |
	deadline := DateAndTime now + 3 seconds.
	[ client isStopped not or: [ DateAndTime now > deadline ] ]
		whileFalse: [ (Delay forMilliseconds: 10) wait ].
	deadline := DateAndTime now + 10 seconds.
	[ client isStopped or: [ DateAndTime now > deadline ] ]
		whileFalse: [ (Delay forMilliseconds: 20) wait ]
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
