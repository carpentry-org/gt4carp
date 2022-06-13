Class {
	#name : #CarpMapNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'leftBrace',
		'pairs',
		'rightBrace'
	],
	#category : #'Carp-Parser'
}

{ #category : #generated }
CarpMapNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitMap: self
]

{ #category : #generated }
CarpMapNode >> compositeNodeVariables [

	^ #( #pairs )
]

{ #category : #'generated-initialize-release' }
CarpMapNode >> initialize [
	super initialize.
	pairs := OrderedCollection new: 2.
]

{ #category : #accessing }
CarpMapNode >> intoModel [
	^ CarpMap
		contents: (pairs
				flatCollect: [ :p | 
					{p key intoModel.
						p value intoModel} ])
]

{ #category : #generated }
CarpMapNode >> leftBrace [

	^ leftBrace
]

{ #category : #generated }
CarpMapNode >> leftBrace: aSmaCCToken [

	leftBrace := aSmaCCToken
]

{ #category : #generated }
CarpMapNode >> pairs [

	^ pairs
]

{ #category : #generated }
CarpMapNode >> pairs: anOrderedCollection [

	self setParents: self pairs to: nil.
	pairs := anOrderedCollection.
	self setParents: self pairs to: self
]

{ #category : #generated }
CarpMapNode >> rightBrace [

	^ rightBrace
]

{ #category : #generated }
CarpMapNode >> rightBrace: aSmaCCToken [

	rightBrace := aSmaCCToken
]

{ #category : #accessing }
CarpMapNode >> toPharo [
	^ (pairs collect: #toPharo) asDictionary
]

{ #category : #generated }
CarpMapNode >> tokenVariables [

	^ #( #leftBrace #rightBrace )
]
