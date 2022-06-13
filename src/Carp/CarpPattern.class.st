Class {
	#name : #CarpPattern,
	#superclass : #CarpStringExpression,
	#category : #'Carp-IDE'
}

{ #category : #accessing }
CarpPattern >> toCarp [
	^ '#', super toCarp
]
