Class {
	#name : #CarpMapNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'pairs'
	],
	#category : #'Carp-AST'
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
