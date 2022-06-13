Class {
	#name : #CarpArrayNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'leftBracket',
		'expressions',
		'rightBracket'
	],
	#category : #'Carp-Parser'
}

{ #category : #generated }
CarpArrayNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitArray: self
]

{ #category : #generated }
CarpArrayNode >> compositeNodeVariables [

	^ #( #expressions )
]

{ #category : #generated }
CarpArrayNode >> expressions [

	^ expressions
]

{ #category : #generated }
CarpArrayNode >> expressions: anOrderedCollection [

	self setParents: self expressions to: nil.
	expressions := anOrderedCollection.
	self setParents: self expressions to: self
]

{ #category : #'generated-initialize-release' }
CarpArrayNode >> initialize [
	super initialize.
	expressions := OrderedCollection new: 2.
]

{ #category : #accessing }
CarpArrayNode >> intoModel [
	^ CarpArray contents: (expressions collect: #intoModel)
]

{ #category : #generated }
CarpArrayNode >> leftBracket [

	^ leftBracket
]

{ #category : #generated }
CarpArrayNode >> leftBracket: aSmaCCToken [

	leftBracket := aSmaCCToken
]

{ #category : #generated }
CarpArrayNode >> rightBracket [

	^ rightBracket
]

{ #category : #generated }
CarpArrayNode >> rightBracket: aSmaCCToken [

	rightBracket := aSmaCCToken
]

{ #category : #accessing }
CarpArrayNode >> toPharo [
	^ expressions collect: #toPharo
]

{ #category : #generated }
CarpArrayNode >> tokenVariables [

	^ #( #leftBracket #rightBracket )
]
