Class {
	#name : #CarpExpressionNode,
	#superclass : #SmaCCParseNode,
	#category : #'Carp-AST'
}

{ #category : #accessing }
CarpExpressionNode class >> itself [
	<gtExample>
	^ self
]

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

{ #category : #accessing }
CarpExpressionNode >> toPharo [
	^ self subclassResponsibility
]
