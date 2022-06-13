Class {
	#name : #CarpVariableNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #'Carp-AST'
}

{ #category : #generated }
CarpVariableNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitVariable: self
]

{ #category : #accessing }
CarpVariableNode >> intoModel [
	^ CarpSymbol named: self value source
]

{ #category : #accessing }
CarpVariableNode >> isDefinitionPredicate [
	^ {'defdynamic'.
		'defndynamic'.
		'defmacro'.
		'defn'.
		'def'} includes: self value source
]

{ #category : #accessing }
CarpVariableNode >> toPharo [
	^ value source asSymbol
]

{ #category : #generated }
CarpVariableNode >> tokenVariables [

	^ #( #value )
]

{ #category : #generated }
CarpVariableNode >> value [

	^ value
]

{ #category : #generated }
CarpVariableNode >> value: aSmaCCToken [

	value := aSmaCCToken
]
