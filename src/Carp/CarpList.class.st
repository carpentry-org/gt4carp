Class {
	#name : #CarpList,
	#superclass : #CarpSequence,
	#category : #'Carp-IDE'
}

{ #category : #accessing }
CarpList >> close [
	^ ')'
]

{ #category : #accessing }
CarpList >> open [
	^ '('
]
