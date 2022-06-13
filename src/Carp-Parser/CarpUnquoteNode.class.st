Class {
	#name : #CarpUnquoteNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'unquoteGlyph',
		'value'
	],
	#category : #'Carp-Parser'
}

{ #category : #generated }
CarpUnquoteNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitUnquote: self
]

{ #category : #accessing }
CarpUnquoteNode >> intoModel [
	^ CarpCall function: 'unquote' arguments: {value intoModel}
]

{ #category : #accessing }
CarpUnquoteNode >> isQuoted [
	^ false
]

{ #category : #generated }
CarpUnquoteNode >> nodeVariables [

	^ #( #value )
]

{ #category : #accessing }
CarpUnquoteNode >> toPharo [
	^ {#unquote . value toPharo}
]

{ #category : #generated }
CarpUnquoteNode >> tokenVariables [

	^ #( #unquoteGlyph )
]

{ #category : #generated }
CarpUnquoteNode >> unquoteGlyph [

	^ unquoteGlyph
]

{ #category : #generated }
CarpUnquoteNode >> unquoteGlyph: aSmaCCToken [

	unquoteGlyph := aSmaCCToken
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
