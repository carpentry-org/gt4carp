Class {
	#name : #CarpListNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'expressions'
	],
	#category : #'Carp-AST'
}

{ #category : #generated }
CarpListNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitList: self
]

{ #category : #generated }
CarpListNode >> compositeNodeVariables [

	^ #( #expressions )
]

{ #category : #generated }
CarpListNode >> expressions [

	^ expressions
]

{ #category : #generated }
CarpListNode >> expressions: anOrderedCollection [

	self setParents: self expressions to: nil.
	expressions := anOrderedCollection.
	self setParents: self expressions to: self
]

{ #category : #'generated-initialize-release' }
CarpListNode >> initialize [
	super initialize.
	expressions := OrderedCollection new: 2.
]
