Class {
	#name : #CarpVariableNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #Carp
}

{ #category : #generated }
CarpVariableNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitVariable: self
]

{ #category : #generated }
CarpVariableNode >> tokenVariables [

	^ #( #value )
]

{ #category : #generated }
CarpVariableNode >> value [

	^ value
]

{ #category : #generated }
CarpVariableNode >> value: aSmaCCToken [

	value := aSmaCCToken
]
