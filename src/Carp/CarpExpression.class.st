Class {
	#name : #CarpExpression,
	#superclass : #Object,
	#instVars : [
		'documentation'
	],
	#category : #'Carp-IDE'
}

{ #category : #accessing }
CarpExpression >> documentation [
	^ documentation ifNil: ['']
]

{ #category : #accessing }
CarpExpression >> documentation: aString [
	documentation := aString
]

{ #category : #converting }
CarpExpression >> toCarp [
	^ self subclassResponsibility
]
