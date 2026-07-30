"
I release remote Carp value references when their local proxies are
garbage collected: a registered {{gtClass:name=CarpRemoteValue}}'s
finalizer asks its class to release the host-side reference.
"
Class {
	#name : #CarpValueResourceManager,
	#superclass : #Object,
	#instVars : [
		'registry'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'Carp-Execution'
}

{ #category : #accessing }
CarpValueResourceManager class >> addResource: anObject [
	^ self uniqueInstance addResource: anObject
]

{ #category : #accessing }
CarpValueResourceManager class >> reset [
	uniqueInstance := nil
]

{ #category : #accessing }
CarpValueResourceManager class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : #accessing }
CarpValueResourceManager >> addResource: anObject [
	registry
		add: anObject
		finalizer: (CarpValueReleaseExecutor new
				resourceClass: anObject class
				data: anObject resourceData)
]

{ #category : #initialization }
CarpValueResourceManager >> initialize [
	super initialize.
	registry := FinalizationRegistry new
]
