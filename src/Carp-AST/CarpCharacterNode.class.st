Class {
	#name : #CarpCharacterNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #'Carp-AST'
}

{ #category : #generated }
CarpCharacterNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitCharacter: self
]

{ #category : #accessing }
CarpCharacterNode >> toPharo [
	^ value source asCharacter
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
