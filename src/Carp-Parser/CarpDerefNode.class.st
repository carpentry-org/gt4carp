Class {
	#name : #CarpDerefNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'derefGlyph',
		'value'
	],
	#category : #'Carp-Parser'
}

{ #category : #generated }
CarpDerefNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitDeref: self
]

{ #category : #generated }
CarpDerefNode >> derefGlyph [

	^ derefGlyph
]

{ #category : #generated }
CarpDerefNode >> derefGlyph: aSmaCCToken [

	derefGlyph := aSmaCCToken
]

{ #category : #generated }
CarpDerefNode >> nodeVariables [

	^ #( #value )
]

{ #category : #generated }
CarpDerefNode >> tokenVariables [

	^ #( #derefGlyph )
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
