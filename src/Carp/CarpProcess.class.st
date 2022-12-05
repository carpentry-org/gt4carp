Class {
	#name : #CarpProcess,
	#superclass : #LanguageLinkAbstractProcess,
	#instVars : [
		'process',
		'environmentVariables'
	],
	#classVars : [
		'CarpPath'
	],
	#category : #'Carp-Processes'
}

{ #category : #accessing }
CarpProcess >> exitCode [

	^ process
		ifNil: [ nil ]
		ifNotNil: [ process exitCode ]
]

{ #category : #accessing }
CarpProcess >> hasProcess [
	"Answer a boolean indicating whether the receiver has a process object"

	^ process isNotNil
]

{ #category : #accessing }
CarpProcess >> initialize [
	super initialize.
	environmentVariables := Dictionary new.
	self setDefaultEnvironmentVariables
]

{ #category : #accessing }
CarpProcess >> isRunning [
	^ process
		ifNil: [ false ]
		ifNotNil: [ process isRunning ]
]

{ #category : #'start-stop' }
CarpProcess >> newProcess [
	| newProcess |
	newProcess := GtSubprocessWithInMemoryOutput new
			command: self serverPath fullName;
			arguments: self processArguments;
			workingDirectory: self workingDirectory resolve fullName;
			terminateOnShutdown;
			yourself.
	environmentVariables
		associationsDo: [ :assoc | newProcess environmentAt: assoc key put: assoc value ].
	^ newProcess
]

{ #category : #accessing }
CarpProcess >> processArguments [
	| args |

	args := OrderedCollection new.
	self settings serverDebugMode ifTrue: 
		[ args add: '--inspect' ].
	args 
		add: (self workingDirectory / self programFile) resolve fullName;
		add: self settings serverSocketAddress port asString;
		add: self settings clientSocketAddress port asString.
	^ args
]

{ #category : #accessing }
CarpProcess >> programFile [
	^ 'src/languagelink.carp'
]

{ #category : #accessing }
CarpProcess >> serverPath [
	| fileReference |

	fileReference := self settings serverExecutable.
	fileReference ifNil: [ fileReference := self class serverPath ].
	^ fileReference.
]

{ #category : #accessing }
CarpProcess >> setDefaultEnvironmentVariables [

	environmentVariables := CarpPlatform subProcessEnvironmentDictionary.
]

{ #category : #accessing }
CarpProcess >> start [
	process := self newProcess.
	process run.
	self settings serverDebugMode ifTrue:
		[ self startServerDebugger ].
]

{ #category : #accessing }
CarpProcess >> stderr [
	"Answer the process stderr contents"

	^ process stderr
]

{ #category : #accessing }
CarpProcess >> stdout [ 
	"Answer the process stdout contents"

	^ process stdout
]

{ #category : #accessing }
CarpProcess >> stop [
	process ifNil: [ ^ self ].
	[ process queryExitStatus ifNil: [ process terminate ] ]
		on: Error
		do: [  "Do nothing.":e |  ].
	process closeAndCleanStreams.
	process := nil
]
