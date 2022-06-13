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

{ #category : #accessing }
CarpListNode >> definitionVariable [
	^ (self expressions size > 1
		and: [ self expressions first isDefinitionPredicate ])
		ifTrue: [ self expressions second ]
		ifFalse: [ nil ]
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

{ #category : #accessing }
CarpListNode >> isDefinition [
	^ self definitionVariable isNotNil
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

{ #category : #accessing }
CarpListNode >> toPharo [
	^ expressions collect: #toPharo
]

{ #category : #generated }
CarpListNode >> tokenVariables [

	^ #( #leftParen #rightParen )
]
