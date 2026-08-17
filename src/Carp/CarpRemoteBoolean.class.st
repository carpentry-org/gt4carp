"
I am a live Carp `Bool`.
"
Class {
	#name : #CarpRemoteBoolean,
	#superclass : #CarpRemoteScalar,
	#category : #'Carp-Execution'
}

{ #category : #'instance creation' }
CarpRemoteBoolean class >> remoteTypeName [
	^ 'Bool'
]

{ #category : #converting }
CarpRemoteBoolean >> asPharoValue [
	^ self asBoolean
]

{ #category : #converting }
CarpRemoteBoolean >> asBoolean [
	^ self printString = 'true'
]
