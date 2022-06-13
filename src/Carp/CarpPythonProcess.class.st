Class {
	#name : #CarpPythonProcess,
	#superclass : #CarpProcess,
	#category : #'Carp-Processes'
}

{ #category : #accessing }
CarpPythonProcess class >> program [
	^ 'python'
]

{ #category : #accessing }
CarpPythonProcess >> processArguments [
	| args |

	args := OrderedCollection new.
	self settings serverDebugMode ifTrue:
		[ args addAll: { 
			'-m'. 
			'debugpy'. 
			'--listen'. 
			self settings debugSocketAddress printAddress. 
			'--wait-for-client'. } ].
	args
		add: (self workingDirectory / self programFile) resolve fullName;
		add: '--port';
		add: self settings serverSocketAddress port asString;
		add: '--pharo';
		add: self settings clientSocketAddress port asString;
		add: '--method';
		add: 'http'.
	"self debugMode ifTrue: [ args add: '--log' ]."
	args add: '--log'.
	^ args
]

{ #category : #accessing }
CarpPythonProcess >> programFile [
	^ 'src/languagelink.py'
]
