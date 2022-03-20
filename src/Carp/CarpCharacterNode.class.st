Class {
	#name : #CarpCharacterNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #Carp
}

{ #category : #generated }
CarpCharacterNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitCharacter: self
]

{ #category : #generated }
CarpCharacterNode >> tokenVariables [

	^ #( #value )
]

{ #category : #generated }
CarpCharacterNode >> value [

	^ value
]

{ #category : #generated }
CarpCharacterNode >> value: aSmaCCToken [

	value := aSmaCCToken
]
