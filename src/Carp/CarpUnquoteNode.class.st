Class {
	#name : #CarpUnquoteNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #Carp
}

{ #category : #generated }
CarpUnquoteNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitUnquote: self
]

{ #category : #generated }
CarpUnquoteNode >> nodeVariables [

	^ #( #value )
]

{ #category : #generated }
CarpUnquoteNode >> value [

	^ value
]

{ #category : #generated }
CarpUnquoteNode >> value: aCarpExpressionNode [

	self value notNil ifTrue: [ self value parent: nil ].
	value := aCarpExpressionNode.
	self value notNil ifTrue: [ self value parent: self ]
]
