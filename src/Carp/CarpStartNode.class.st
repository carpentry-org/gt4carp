Class {
	#name : #CarpStartNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'expressions'
	],
	#category : #'Carp-AST'
}

{ #category : #generated }
CarpStartNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitStart: self
]

{ #category : #generated }
CarpStartNode >> compositeNodeVariables [

	^ #( #expressions )
]

{ #category : #generated }
CarpStartNode >> expressions [

	^ expressions
]

{ #category : #generated }
CarpStartNode >> expressions: anOrderedCollection [

	self setParents: self expressions to: nil.
	expressions := anOrderedCollection.
	self setParents: self expressions to: self
]

{ #category : #'generated-initialize-release' }
CarpStartNode >> initialize [
	super initialize.
	expressions := OrderedCollection new: 2.
]
