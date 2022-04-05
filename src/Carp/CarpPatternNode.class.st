Class {
	#name : #CarpPatternNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #'Carp-AST'
}

{ #category : #generated }
CarpPatternNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitPattern: self
]

{ #category : #generated }
CarpPatternNode >> tokenVariables [

	^ #( #value )
]

{ #category : #generated }
CarpPatternNode >> value [

	^ value
]

{ #category : #generated }
CarpPatternNode >> value: aSmaCCToken [

	value := aSmaCCToken
]
