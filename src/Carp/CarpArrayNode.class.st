Class {
	#name : #CarpArrayNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'expressions'
	],
	#category : #Carp
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
