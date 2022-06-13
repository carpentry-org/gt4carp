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

{ #category : #accessing }
CarpNumberNode >> intoModel [
	^ CarpDouble number: self value source asNumber
]

{ #category : #accessing }
CarpNumberNode >> toPharo [
	^ value source asInteger
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
