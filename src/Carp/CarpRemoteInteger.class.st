"
I am a live Carp integer: an `Int`, a `Long` or a `Byte`. They differ in
width and in nothing a reader cares about, so one proxy speaks for all three.
"
Class {
	#name : #CarpRemoteInteger,
	#superclass : #CarpRemoteScalar,
	#category : #'Carp-Execution'
}

{ #category : #'instance creation' }
CarpRemoteInteger class >> remoteTypeName [
	^ 'Int'
]

{ #category : #'instance creation' }
CarpRemoteInteger class >> handlesRemoteType: aTypeName [
	^ #('Int' 'Long' 'Byte') includes: aTypeName
]

{ #category : #converting }
CarpRemoteInteger >> asPharoValue [
	^ self asInteger
]

{ #category : #converting }
CarpRemoteInteger >> asInteger [
	^ (self printString ifEmpty: [ '0' ]) asInteger ifNil: [ 0 ]
]
