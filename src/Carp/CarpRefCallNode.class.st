Class {
	#name : #CarpRefCallNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #'Carp-AST'
}

{ #category : #generated }
CarpRefCallNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitRefCall: self
]

{ #category : #generated }
CarpRefCallNode >> nodeVariables [

	^ #( #value )
]

{ #category : #generated }
CarpRefCallNode >> value [

	^ value
]

{ #category : #generated }
CarpRefCallNode >> value: aCarpExpressionNode [

	self value notNil ifTrue: [ self value parent: nil ].
	value := aCarpExpressionNode.
	self value notNil ifTrue: [ self value parent: self ]
]
