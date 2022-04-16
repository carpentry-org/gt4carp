Class {
	#name : #CarpNumberNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #'Carp-AST'
}

{ #category : #generated }
CarpNumberNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitNumber: self
]

{ #category : #generated }
CarpNumberNode >> tokenVariables [

	^ #( #value )
]

{ #category : #generated }
CarpNumberNode >> value [

	^ value
]

{ #category : #generated }
CarpNumberNode >> value: aSmaCCToken [

	value := aSmaCCToken
]
