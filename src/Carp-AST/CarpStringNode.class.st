Class {
	#name : #CarpStringNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #'Carp-AST'
}

{ #category : #generated }
CarpStringNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitString: self
]

{ #category : #accessing }
CarpStringNode >> toPharo [
	^ value source
]

{ #category : #generated }
CarpStringNode >> tokenVariables [

	^ #( #value )
]

{ #category : #generated }
CarpStringNode >> value [

	^ value
]

{ #category : #generated }
CarpStringNode >> value: aSmaCCToken [

	value := aSmaCCToken
]
