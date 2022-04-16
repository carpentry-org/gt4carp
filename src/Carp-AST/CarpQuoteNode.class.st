Class {
	#name : #CarpQuoteNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #'Carp-AST'
}

{ #category : #generated }
CarpQuoteNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitQuote: self
]

{ #category : #accessing }
CarpQuoteNode >> isQuoted [
	^ true
]

{ #category : #accessing }
CarpQuoteNode >> newMethod [
	"This is a new method"
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
