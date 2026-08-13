"
I am a client for the carp notebook server (carp/src/server.carp).

I speak length-prefixed JSON over TCP. I lazily connect to a running server,
or spawn one from {{gtClass:name=CarpServerClient}}>>#serverBinary if nothing
listens on my port.

Configure paths class-side (or through the CARP_SERVER / CARP_COMPILER /
CARP_DIR environment variables):

{{gtExample:CarpServerClient class>>#default}}
"
Class {
	#name : #CarpServerClient,
	#superclass : #Object,
	#instVars : [
		'host',
		'port',
		'stream',
		'nextId',
		'mutex',
		'checkedFreshness',
		'serverProcess'
	],
	#classVars : [
		'Default',
		'CompilerBinary',
		'CoreDirectory',
		'DefaultPort',
		'NotebookLibrary',
		'ServerBinary',
		'WorkDirectory'
	],
	#category : #'Carp-Server'
}

{ #category : #accessing }
CarpServerClient class >> compilerBinary [
	^ CompilerBinary
		ifNil: [ Smalltalk os environment
				at: 'CARP_COMPILER'
				ifAbsent: [ (FileLocator home
						/ 'Documents/Code/Github/carp/carpentry-org/carp-compiler/out/carp-compiler')
						fullName ] ]
]

{ #category : #accessing }
CarpServerClient class >> compilerBinary: aPathString [
	CompilerBinary := aPathString
]

{ #category : #accessing }
CarpServerClient class >> coreDirectory [
	^ CoreDirectory
		ifNil: [ (Smalltalk os environment at: 'CARP_DIR' ifAbsent: [ nil ])
				ifNil: [ (FileLocator home / 'Documents/Code/Github/carp/carp/core') fullName ]
				ifNotNil: [ :dir | dir , '/core' ] ]
]

{ #category : #accessing }
CarpServerClient class >> coreDirectory: aPathString [
	CoreDirectory := aPathString
]

{ #category : #accessing }
CarpServerClient class >> default [
	^ Default ifNil: [ Default := self new ]
]

{ #category : #accessing }
CarpServerClient class >> defaultPort [
	^ DefaultPort ifNil: [ 8991 ]
]

{ #category : #accessing }
CarpServerClient class >> defaultPort: anInteger [
	DefaultPort := anInteger
]

{ #category : #accessing }
CarpServerClient class >> notebookLibrary [
	^ NotebookLibrary
		ifNil: [ Smalltalk os environment
				at: 'CARP_NB_LIB'
				ifAbsent: [ (FileLocator home
						/ 'Documents/Code/Github/carp/gt4carp/carp/src/notebook.carp') fullName ] ]
]

{ #category : #accessing }
CarpServerClient class >> notebookLibrary: aPathString [
	NotebookLibrary := aPathString
]

{ #category : #accessing }
CarpServerClient class >> reset [
	Default ifNotNil: [ :c | c stop ].
	Default := nil
]

{ #category : #accessing }
CarpServerClient class >> serverBinary [
	^ ServerBinary
		ifNil: [ Smalltalk os environment
				at: 'CARP_SERVER'
				ifAbsent: [ (FileLocator home
						/ 'Documents/Code/Github/carp/gt4carp/carp/out/carp-server') fullName ] ]
]

{ #category : #accessing }
CarpServerClient class >> serverBinary: aPathString [
	ServerBinary := aPathString
]

{ #category : #accessing }
CarpServerClient class >> workDirectory [
	^ WorkDirectory
		ifNil: [ (FileLocator temp / 'carp-server-work') ensureCreateDirectory fullName ]
]

{ #category : #accessing }
CarpServerClient class >> workDirectory: aPathString [
	WorkDirectory := aPathString
]

{ #category : #'api - commands' }
CarpServerClient >> evalSource: aSourceString session: aSessionString [
	"Evaluate a notebook cell. Answer a CarpEvalResult."

	| response ok result |
	response := self
			rpc: (Dictionary new
					at: 'id' put: self nextRequestId;
					at: 'cmd' put: 'eval';
					at: 'session' put: aSessionString;
					at: 'source' put: aSourceString;
					yourself).
	ok := response
			at: 'ok'
			ifAbsent: [ ^ CarpServerError new
					signal: (response at: 'error' ifAbsent: [ 'malformed server response' ]) ].
	result := CarpEvalResult new
			source: aSourceString;
			session: aSessionString;
			exitCode: (ok at: 'exit') asInteger;
			value: (ok at: 'value' ifAbsent: [ '' ]);
			stdout: (ok at: 'stdout');
			stderr: (ok at: 'stderr').
	(ok at: 'hasValue' ifAbsent: [ false ])
		ifTrue: [ [ result
				valueProxy: ((CarpValueClient new
						carpSession: aSessionString;
						connectTo: (ok at: 'hostPort');
						yourself)
						remoteObjectById: 0) ]
				on: Error
				do: [ :e |  "host gone already; the textual result stands" ] ].
	^ result
]

{ #category : #accessing }
CarpServerClient >> address [
	"Where the server is, or will be started: what the snippet label shows."

	^ host , ':' , port printString
]

{ #category : #private }
CarpServerClient >> openConnection [
	"A connection for one request. The server serves connections one at a
	time and reads a held connection to EOF, so a client that keeps a socket
	open between requests starves every other client — and an idle one wedges
	the notebook. One request per connection keeps the server shared."

	| aStream |
	aStream := SocketStream openConnectionToHostNamed: host port: port.
	aStream binary.
	^ aStream
]

{ #category : #private }
CarpServerClient >> disconnect [
	stream ifNotNil: [ [ stream close ] on: Error do: [ :e |  ] ].
	stream := nil
]

{ #category : #private }
CarpServerClient >> ensureServerRunning [
	"Answer once a server is listening, starting one if none is. The
	freshness check runs once per client: it costs a request of its own, so
	doing it per call would double every round trip."

	self isConnected
		ifFalse: [ self startServer.
			self waitForServer ].
	checkedFreshness == true
		ifFalse: [ checkedFreshness := true.
			self ensureFreshServer ]
]

{ #category : #'start-stop' }
CarpServerClient >> ensureFreshServer [
	"A server was already listening; replace it when it was built from an
	older binary than the one on disk (its ping stamp differs from the
	binary's --stamp)."

	[ | running expected |
	running := (self
			rpc: (Dictionary new
					at: 'id' put: self nextRequestId;
					at: 'cmd' put: 'ping';
					yourself)) at: 'stamp' ifAbsent: [ nil ].
	expected := self binaryStamp.
	(expected notNil and: [ running ~= expected ])
		ifTrue: [ GtExternalProcessBuilder new
				command: '/usr/bin/pkill';
				args: {'-f'.
						'carp-server ' , port printString};
				output.
			self startServer.
			self waitForServer ] ]
		on: Error
		do: [ :e | "never let the staleness check break connecting" ]
]

{ #category : #'start-stop' }
CarpServerClient >> binaryStamp [
	"The build stamp of the server binary on disk, or nil."

	^ [ | out |
	out := GtExternalProcessBuilder new
			command: self class serverBinary;
			args: {'--stamp'};
			output.
	out status isSuccess
		ifTrue: [ out stdoutString trimBoth ]
		ifFalse: [ nil ] ]
		on: Error
		do: [ :e | nil ]
]

{ #category : #initialization }
CarpServerClient >> initialize [
	super initialize.
	host := '127.0.0.1'.
	port := self class defaultPort.
	nextId := 0.
	checkedFreshness := false.
	mutex := Mutex new
]

{ #category : #testing }
CarpServerClient >> isConnected [
	"Whether a server is listening. Connections live for one request, so
	this probes rather than reporting a held socket."

	^ [ self openConnection close.
	true ]
		on: Error
		do: [ :e | false ]
]

{ #category : #private }
CarpServerClient >> nextRequestId [
	^ nextId := nextId + 1
]

{ #category : #'api - commands' }
CarpServerClient >> completePrefix: aPrefixString session: aSessionString [
	"Answer completion candidate dictionaries (name, kind, scheme, doc) for
	the prefix, from the session's warm compiler state."

	| response ok |
	response := self
			rpc: (Dictionary new
					at: 'id' put: self nextRequestId;
					at: 'cmd' put: 'complete';
					at: 'session' put: aSessionString;
					at: 'prefix' put: aPrefixString;
					yourself).
	ok := response
			at: 'ok'
			ifAbsent: [ ^ CarpServerError new
					signal: (response at: 'error' ifAbsent: [ 'malformed server response' ]) ].
	^ ok at: 'candidates' ifAbsent: [ #() ]
]

{ #category : #'api - commands' }
CarpServerClient >> docFor: aName session: aSessionString [
	"Answer the documentation dictionary (name, kind, scheme, documentation)
	for a definition, or nil when there is none."

	| response |
	response := self
			rpc: (Dictionary new
					at: 'id' put: self nextRequestId;
					at: 'cmd' put: 'doc';
					at: 'session' put: aSessionString;
					at: 'name' put: aName;
					yourself).
	^ response at: 'ok' ifAbsent: [ nil ]
]

{ #category : #'api - commands' }
CarpServerClient >> annotateSource: aSourceString session: aSessionString [
	"Answer the inferred types of the session's definitions plus the given
	source, as a CarpAnnotations."

	| response ok |
	response := self
			rpc: (Dictionary new
					at: 'id' put: self nextRequestId;
					at: 'cmd' put: 'annotate';
					at: 'session' put: aSessionString;
					at: 'source' put: aSourceString;
					yourself).
	ok := response
			at: 'ok'
			ifAbsent: [ ^ CarpServerError new
					signal: (response at: 'error' ifAbsent: [ 'malformed server response' ]) ].
	^ CarpAnnotations new
		session: aSessionString;
		source: aSourceString;
		definitions: (ok at: 'definitions' ifAbsent: [ #() ]);
		environment: (ok at: 'environment' ifAbsent: [ #() ]);
		locals: (ok at: 'locals' ifAbsent: [ #() ]);
		diagnostics: (ok at: 'diagnostics' ifAbsent: [ #() ])
]

{ #category : #'api - commands' }
CarpServerClient >> projectAt: aRootPathString [
	"Answer the project rooted at a repository: its load order, which files
	are its own and which are dependencies, and every definition with its
	span in file coordinates."

	| response |
	response := self
			rpc: (Dictionary new
					at: 'id' put: self nextRequestId;
					at: 'cmd' put: 'project';
					at: 'root' put: aRootPathString;
					yourself).
	^ CarpProject
		fromDictionary: (response
				at: 'ok'
				ifAbsent: [ ^ CarpServerError new
						signal: (response at: 'error' ifAbsent: [ 'malformed server response' ]) ])
]

{ #category : #'api - commands' }
CarpServerClient >> expandSource: aSourceString session: aSessionString once: aBoolean [
	"Answer the expansion of a form against the session's compile-time
	environment as {expansion, changed}. With once: true this is a single
	expansion step — the macro stepper's unit."

	| response |
	response := self
			rpc: (Dictionary new
					at: 'id' put: self nextRequestId;
					at: 'cmd' put: (aBoolean ifTrue: [ 'expand-1' ] ifFalse: [ 'expand' ]);
					at: 'session' put: aSessionString;
					at: 'source' put: aSourceString;
					yourself).
	^ response
		at: 'ok'
		ifAbsent: [ ^ CarpServerError new
				signal: (response at: 'error' ifAbsent: [ 'malformed server response' ]) ]
]

{ #category : #'api - commands' }
CarpServerClient >> ownershipSource: aSourceString session: aSessionString [
	"Answer the compiler's move/borrow/delete plan rows for the session's
	definitions plus the given source."

	| response ok |
	response := self
			rpc: (Dictionary new
					at: 'id' put: self nextRequestId;
					at: 'cmd' put: 'ownership';
					at: 'session' put: aSessionString;
					at: 'source' put: aSourceString;
					yourself).
	ok := response
			at: 'ok'
			ifAbsent: [ ^ CarpServerError new
					signal: (response at: 'error' ifAbsent: [ 'malformed server response' ]) ].
	^ ok at: 'ownership' ifAbsent: [ #() ]
]

{ #category : #'api - commands' }
CarpServerClient >> ping [
	^ (self rpc: (Dictionary new
			at: 'id' put: self nextRequestId;
			at: 'cmd' put: 'ping';
			yourself)) at: 'ok' ifAbsent: [ nil ]
]

{ #category : #private }
CarpServerClient >> readFrame [
	| line length |
	line := (stream upTo: 10) asString trimBoth.
	length := line asNumber
			ifNil: [ ^ CarpServerError new signal: 'bad frame header: ' , line ].
	^ (stream next: length asInteger) utf8Decoded
]

{ #category : #'api - commands' }
CarpServerClient >> resetSession: aSessionString [
	^ self
		rpc: (Dictionary new
				at: 'id' put: self nextRequestId;
				at: 'cmd' put: 'reset';
				at: 'session' put: aSessionString;
				yourself)
]

{ #category : #private }
CarpServerClient >> rpc: aDictionary [
	^ mutex critical: [ | attempts |
			self ensureServerRunning.
			attempts := 0.
			[ [ stream := self openConnection.
			self sendFrame: (STONJSON toString: aDictionary) utf8Encoded.
			STONJSON fromString: self readFrame ]
				ensure: [ self disconnect ] ]
				on: NetworkError , ZnCharacterEncodingError
				do: [ :e |
					"one more attempt: the server may have been restarted"
					attempts := attempts + 1.
					self disconnect.
					attempts > 1 ifTrue: [ e pass ].
					self ensureServerRunning.
					e retry ] ]
]

{ #category : #private }
CarpServerClient >> sendFrame: aByteArray [
	stream
		nextPutAll: aByteArray size printString asByteArray;
		nextPut: 10;
		nextPutAll: aByteArray;
		flush
]

{ #category : #private }
CarpServerClient >> startServer [
	serverProcess := GtExternalProcessBuilder new
			command: self class serverBinary;
			args: {port printString.
					self class compilerBinary.
					self class coreDirectory.
					self class workDirectory.
					self class notebookLibrary};
			nullStdin;
			nullStdout;
			nullStderr;
			spawn
]

{ #category : #'start-stop' }
CarpServerClient >> stop [
	self disconnect.
	serverProcess
		ifNotNil: [ :p | [ p kill ] on: Error do: [ :e |  ] ].
	serverProcess := nil
]

{ #category : #private }
CarpServerClient >> waitForServer [
	50
		timesRepeat: [ (Delay forMilliseconds: 100) wait.
			self isConnected ifTrue: [ ^ self ] ].
	^ CarpServerError new
		signal: 'carp server did not come up on port ' , port printString
]
