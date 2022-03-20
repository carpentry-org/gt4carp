Class {
	#name : #CarpQuoteNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #Carp
}

{ #category : #generated }
CarpQuoteNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitQuote: self
]

{ #category : #generated }
CarpQuoteNode >> nodeVariables [

	^ #( #value )
]

{ #category : #generated }
CarpQuoteNode >> value [

	^ value
]

{ #category : #generated }
CarpQuoteNode >> value: aCarpExpressionNode [

	self value notNil ifTrue: [ self value parent: nil ].
	value := aCarpExpressionNode.
	self value notNil ifTrue: [ self value parent: self ]
]
