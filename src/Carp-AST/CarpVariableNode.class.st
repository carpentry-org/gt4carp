Class {
	#name : #CarpVariableNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #'Carp-AST'
}

{ #category : #generated }
CarpVariableNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitVariable: self
]

{ #category : #accessing }
CarpVariableNode >> toPharo [
	^ value source asSymbol
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
