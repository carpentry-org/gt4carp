"
I am a live Carp `Bag`: a collection whose elements may repeat.
"
Class {
	#name : #CarpRemoteBag,
	#superclass : #CarpRemoteCollection,
	#category : #'Carp-Execution'
}

{ #category : #'instance creation' }
CarpRemoteBag class >> remoteTypeName [
	^ 'Bag'
]
