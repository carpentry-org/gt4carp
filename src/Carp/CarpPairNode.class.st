Class {
	#name : #CarpPairNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'key',
		'value'
	],
	#category : #Carp
}

{ #category : #generated }
CarpPairNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitPair: self
]

{ #category : #generated }
CarpPairNode >> key [

	^ key
]

{ #category : #generated }
CarpPairNode >> key: aCarpExpressionNode [

	self key notNil ifTrue: [ self key parent: nil ].
	key := aCarpExpressionNode.
	self key notNil ifTrue: [ self key parent: self ]
]

{ #category : #generated }
CarpPairNode >> nodeVariables [

	^ #( #key #value )
]

{ #category : #generated }
CarpPairNode >> value [

	^ value
]

{ #category : #generated }
CarpPairNode >> value: aCarpExpressionNode [

	self value notNil ifTrue: [ self value parent: nil ].
	value := aCarpExpressionNode.
	self value notNil ifTrue: [ self value parent: self ]
]
