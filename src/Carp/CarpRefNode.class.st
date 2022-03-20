Class {
	#name : #CarpRefNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #Carp
}

{ #category : #generated }
CarpRefNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitRef: self
]

{ #category : #generated }
CarpRefNode >> nodeVariables [

	^ #( #value )
]

{ #category : #generated }
CarpRefNode >> value [

	^ value
]

{ #category : #generated }
CarpRefNode >> value: aCarpExpressionNode [

	self value notNil ifTrue: [ self value parent: nil ].
	value := aCarpExpressionNode.
	self value notNil ifTrue: [ self value parent: self ]
]
