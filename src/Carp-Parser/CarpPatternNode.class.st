Class {
	#name : #CarpPatternNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'patternGlyph',
		'value'
	],
	#category : #'Carp-Parser'
}

{ #category : #generated }
CarpPatternNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitPattern: self
]

{ #category : #generated }
CarpPatternNode >> patternGlyph [

	^ patternGlyph
]

{ #category : #generated }
CarpPatternNode >> patternGlyph: aSmaCCToken [

	patternGlyph := aSmaCCToken
]

{ #category : #accessing }
CarpPatternNode >> toPharo [
	^ value source
]

{ #category : #generated }
CarpPatternNode >> tokenVariables [

	^ #( #patternGlyph #value )
]

{ #category : #generated }
CarpPatternNode >> value [

	^ value
]

{ #category : #generated }
CarpPatternNode >> value: aSmaCCToken [

	value := aSmaCCToken
]
