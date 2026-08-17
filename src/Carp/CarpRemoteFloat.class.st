"
I am a live Carp floating point number: a `Double` or a `Float`.
"
Class {
	#name : #CarpRemoteFloat,
	#superclass : #CarpRemoteScalar,
	#category : #'Carp-Execution'
}

{ #category : #'instance creation' }
CarpRemoteFloat class >> remoteTypeName [
	^ 'Double'
]

{ #category : #'instance creation' }
CarpRemoteFloat class >> handlesRemoteType: aTypeName [
	^ #('Double' 'Float') includes: aTypeName
]

{ #category : #converting }
CarpRemoteFloat >> asPharoValue [
	^ self asNumber
]

{ #category : #converting }
CarpRemoteFloat >> asNumber [
	^ (self printString ifEmpty: [ '0' ]) asNumber ifNil: [ 0 ]
]
