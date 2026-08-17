"
I am a live Carp `Set`. What I hold is listed by the host the way an array's
elements are, so I am a collection with a different name.
"
Class {
	#name : #CarpRemoteSet,
	#superclass : #CarpRemoteCollection,
	#category : #'Carp-Execution'
}

{ #category : #'instance creation' }
CarpRemoteSet class >> remoteTypeName [
	^ 'Set'
]
