Trait {
	#name : #TCarpExpressionNodeVisitor,
	#traits : 'TSmaCCParseNodeVisitor',
	#classTraits : 'TSmaCCParseNodeVisitor classTrait',
	#category : #Carp
}

{ #category : #generated }
TCarpExpressionNodeVisitor >> visitArray: anArray [

	^ self visitExpression: anArray
]

{ #category : #generated }
TCarpExpressionNodeVisitor >> visitCharacter: aCharacter [

	^ self visitExpression: aCharacter
]

{ #category : #generated }
TCarpExpressionNodeVisitor >> visitDeref: aDeref [

	^ self visitExpression: aDeref
]

{ #category : #generated }
TCarpExpressionNodeVisitor >> visitExpression: anExpression [

	^ self visitSmaCCParseNode: anExpression
]

{ #category : #generated }
TCarpExpressionNodeVisitor >> visitList: aList [

	^ self visitExpression: aList
]

{ #category : #generated }
TCarpExpressionNodeVisitor >> visitModuleOrType: aModuleOrType [

	^ self visitExpression: aModuleOrType
]

{ #category : #generated }
TCarpExpressionNodeVisitor >> visitNumber: aNumber [

	^ self visitExpression: aNumber
]

{ #category : #generated }
TCarpExpressionNodeVisitor >> visitQuote: aQuote [

	^ self visitExpression: aQuote
]

{ #category : #generated }
TCarpExpressionNodeVisitor >> visitRef: aRef [

	^ self visitExpression: aRef
]

{ #category : #generated }
TCarpExpressionNodeVisitor >> visitStart: aStart [

	^ self visitExpression: aStart
]

{ #category : #generated }
TCarpExpressionNodeVisitor >> visitString: aString [

	^ self visitExpression: aString
]

{ #category : #generated }
TCarpExpressionNodeVisitor >> visitUnquote: anUnquote [

	^ self visitExpression: anUnquote
]

{ #category : #generated }
TCarpExpressionNodeVisitor >> visitVariable: aVariable [

	^ self visitExpression: aVariable
]
