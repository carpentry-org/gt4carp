Class {
	#name : #LeCarpApplicationStrategy,
	#superclass : #LeExternalServerStrategy,
	#category : #'Carp-Lepiter'
}

{ #category : #accessing }
LeCarpApplicationStrategy class >> strategyName [

	^ #global
]

{ #category : #accessing }
LeCarpApplicationStrategy >> applicationServer [

	^ CarpApplication uniqueInstance
]

{ #category : #accessing }
LeCarpApplicationStrategy >> applicationSettings [
	"Answer the settings that will be used by the server.
	This musn't actually start the server as that should be deferred until a snippet is evaluated for the first time."

	^ CarpApplication isRunning ifTrue:
		[ CarpApplication uniqueInstance settings ]
	ifFalse:
		[ CarpApplication defaultSettings ]
]
