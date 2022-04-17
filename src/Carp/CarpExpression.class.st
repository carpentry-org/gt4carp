Class {
	#name : #CarpExpression,
	#superclass : #Object,
	#category : #'Carp-IDE'
}

{ #category : #converting }
CarpExpression >> toCarp [
	^ self subclassResponsibility
]
