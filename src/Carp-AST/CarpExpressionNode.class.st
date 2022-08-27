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
CarpExpressionNode >> isCallablePredicate [
	^ false
]

{ #category : #accessing }
CarpExpressionNode >> isCase [
	^ false
]

{ #category : #accessing }
CarpExpressionNode >> isCond [
	^ false
]

{ #category : #accessing }
CarpExpressionNode >> isDefModule [
	^ false
]

{ #category : #accessing }
CarpExpressionNode >> isDefinition [
	^ false
]

{ #category : #accessing }
CarpExpressionNode >> isDefinitionPredicate [
	^ false
]

{ #category : #accessing }
CarpExpressionNode >> isDo [
	^ false
]

{ #category : #accessing }
CarpExpressionNode >> isFn [
	^ false
]

{ #category : #accessing }
CarpExpressionNode >> isLet [
	^ false
]

{ #category : #accessing }
CarpExpressionNode >> isLoop [
	^ false
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
