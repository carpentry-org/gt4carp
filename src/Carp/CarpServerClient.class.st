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

{ #category : #private }
CarpServerClient >> connect [
	stream := SocketStream openConnectionToHostNamed: host port: port.
	stream binary
]

{ #category : #private }
CarpServerClient >> disconnect [
	stream ifNotNil: [ [ stream close ] on: Error do: [ :e |  ] ].
	stream := nil
]

{ #category : #private }
CarpServerClient >> ensureConnected [
	stream ifNotNil: [ ^ self ].
	[ self connect ]
		on: Error
		do: [ :e |
			self startServer.
			self waitForServer ]
]

{ #category : #initialization }
CarpServerClient >> initialize [
	super initialize.
	host := '127.0.0.1'.
	port := self class defaultPort.
	nextId := 0.
	mutex := Mutex new
]

{ #category : #testing }
CarpServerClient >> isConnected [
	^ stream notNil
]

{ #category : #private }
CarpServerClient >> nextRequestId [
	^ nextId := nextId + 1
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
			self ensureConnected.
			attempts := 0.
			[ self sendFrame: (STONJSON toString: aDictionary) utf8Encoded.
			STONJSON fromString: self readFrame ]
				on: NetworkError , ZnCharacterEncodingError
				do: [ :e |
					"one reconnect attempt: the server may have been restarted"
					attempts := attempts + 1.
					self disconnect.
					attempts > 1 ifTrue: [ e pass ].
					self ensureConnected.
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
			[ ^ self connect ] on: Error do: [ :e |  ] ].
	^ CarpServerError new
		signal: 'carp server did not come up on port ' , port printString
]
