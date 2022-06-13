Class {
	#name : #CarpRefNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'refGlyph',
		'value'
	],
	#category : #'Carp-Parser'
}

{ #category : #generated }
CarpRefNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitRef: self
]

{ #category : #accessing }
CarpRefNode >> intoModel [
	^ CarpCall function: 'ref' arguments: {value intoModel}
]

{ #category : #generated }
CarpRefNode >> nodeVariables [

	^ #( #value )
]

{ #category : #generated }
CarpRefNode >> refGlyph [

	^ refGlyph
]

{ #category : #generated }
CarpRefNode >> refGlyph: aSmaCCToken [

	refGlyph := aSmaCCToken
]

{ #category : #accessing }
CarpRefNode >> toPharo [
	^ {#ref . value toPharo}
]

{ #category : #generated }
CarpRefNode >> tokenVariables [

	^ #( #refGlyph )
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
