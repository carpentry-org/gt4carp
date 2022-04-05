Class {
	#name : #CarpExpressionNode,
	#superclass : #SmaCCParseNode,
	#category : #'Carp-AST'
}

{ #category : #generated }
CarpExpressionNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitExpression: self
]
