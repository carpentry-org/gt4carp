Class {
	#name : #CarpExpressionNode,
	#superclass : #SmaCCParseNode,
	#category : #'Carp-AST'
}

{ #category : #generated }
CarpExpressionNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitExpression: self
]

{ #category : #accessing }
CarpExpressionNode >> isQuoted [
	^ parent ifNil: [ false ] ifNotNil: [ parent isQuoted ]
]

{ #category : #accessing }
CarpExpressionNode >> listDepth [
	^ parent ifNil: [ 0 ] ifNotNil: [ parent listDepth + 1 ]
]
