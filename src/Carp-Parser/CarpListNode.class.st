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

{ #category : #accessing }
CarpListNode >> callVariable [
	^ (self expressions size > 1
		and: [ self expressions first isCallablePredicate ])
		ifTrue: [ self expressions second ]
		ifFalse: [ nil ]
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
CarpListNode >> intoModel [
	^ self isDefinition
		ifTrue: [ | binding |
			binding := (CarpBinding perform: self expressions first value source asSymbol)
					name: self definitionVariable intoModel.
			self expressions size = 3
				ifTrue: [ binding binding: self expressions third intoModel ].
			self expressions size = 4
				ifTrue: [ binding
						arguments: self expressions third intoModel;
						body: self expressions fourth intoModel ].
			binding ]
		ifFalse: [ CarpList contents: (expressions collect: #intoModel) ]
]

{ #category : #accessing }
CarpListNode >> isCallableDefinition [
	^ self callVariable isNotNil
]

{ #category : #accessing }
CarpListNode >> isCase [
	^ (self expressions size > 1
		and: [ self expressions first isCase ])
]

{ #category : #accessing }
CarpListNode >> isCond [
	^ (self expressions size > 1
		and: [ self expressions first isCond ])
]

{ #category : #accessing }
CarpListNode >> isDefinition [
	^ self definitionVariable isNotNil
]

{ #category : #accessing }
CarpListNode >> isDo [
	^ (self expressions size > 1
		and: [ self expressions first isDo ])
]

{ #category : #accessing }
CarpListNode >> isFn [
	^ (self expressions size > 1
		and: [ self expressions first isFn ])
]

{ #category : #accessing }
CarpListNode >> isLet [
	^ (self expressions size > 1
		and: [ self expressions first isLet ])
]

{ #category : #accessing }
CarpListNode >> isLoop [
	^ (self expressions size > 1
		and: [ self expressions first isLoop ])
]

{ #category : #accessing }
CarpListNode >> isModuleDefinition [
	^ (self expressions size > 1
		and: [ self expressions first isDefModule ])
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
