Class {
	#name : #CarpListNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'leftParen',
		'expressions',
		'rightParen'
	],
	#category : #'Carp-Parser'
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

{ #category : #generated }
CarpListNode >> leftParen [

	^ leftParen
]

{ #category : #generated }
CarpListNode >> leftParen: aSmaCCToken [

	leftParen := aSmaCCToken
]

{ #category : #generated }
CarpListNode >> rightParen [

	^ rightParen
]

{ #category : #generated }
CarpListNode >> rightParen: aSmaCCToken [

	rightParen := aSmaCCToken
]

{ #category : #generated }
CarpListNode >> tokenVariables [

	^ #( #leftParen #rightParen )
]
