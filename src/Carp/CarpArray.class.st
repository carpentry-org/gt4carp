Class {
	#name : #CarpArray,
	#superclass : #CarpSequence,
	#category : #'Carp-IDE'
}

{ #category : #accessing }
CarpArray >> close [
	^ ']'
]

{ #category : #accessing }
CarpArray >> open [
	^ '['
]
