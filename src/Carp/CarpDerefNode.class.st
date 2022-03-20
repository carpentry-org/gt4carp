Class {
	#name : #CarpDerefNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #Carp
}

{ #category : #generated }
CarpDerefNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitDeref: self
]

{ #category : #generated }
CarpDerefNode >> nodeVariables [

	^ #( #value )
]

{ #category : #generated }
CarpDerefNode >> value [

	^ value
]

{ #category : #generated }
CarpDerefNode >> value: aCarpExpressionNode [

	self value notNil ifTrue: [ self value parent: nil ].
	value := aCarpExpressionNode.
	self value notNil ifTrue: [ self value parent: self ]
]
