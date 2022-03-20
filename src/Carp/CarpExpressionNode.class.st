Class {
	#name : #CarpExpressionNode,
	#superclass : #SmaCCParseNode,
	#category : #'Carp-Carp'
}

{ #category : #generated }
CarpExpressionNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitExpression: self
]
