Class {
	#name : #CarpRefCallNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'refGlyph',
		'value'
	],
	#category : #'Carp-Parser'
}

{ #category : #generated }
CarpRefCallNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitRefCall: self
]

{ #category : #accessing }
CarpRefCallNode >> intoModel [
	^ CarpCall function: '~' arguments: {value intoModel}
]

{ #category : #generated }
CarpRefCallNode >> nodeVariables [

	^ #( #value )
]

{ #category : #generated }
CarpRefCallNode >> refGlyph [

	^ refGlyph
]

{ #category : #generated }
CarpRefCallNode >> refGlyph: aSmaCCToken [

	refGlyph := aSmaCCToken
]

{ #category : #accessing }
CarpRefCallNode >> toPharo [
	^ {#'ref-call' . value toPharo}
]

{ #category : #generated }
CarpRefCallNode >> tokenVariables [

	^ #( #refGlyph )
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
