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
CarpVariableNode >> isCallablePredicate [
	^ {'defndynamic'.
		'defmacro'.
		'defn' } includes: self value source
]

{ #category : #accessing }
CarpVariableNode >> isCase [
	^ 'case' = self value source
]

{ #category : #accessing }
CarpVariableNode >> isCond [
	^ 'cond' = self value source
]

{ #category : #accessing }
CarpVariableNode >> isDefModule [
	^ 'defmodule' = self value source
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
CarpVariableNode >> isDo [
	^ 'do' = self value source
]

{ #category : #accessing }
CarpVariableNode >> isFn [
	^ 'fn' = self value source
]

{ #category : #accessing }
CarpVariableNode >> isLet [
	^ {'let' . 'let-do' }  includes: self value source
]

{ #category : #accessing }
CarpVariableNode >> isLoop [
	^ { 'for' . 'while' . 'if' . 'when' . 'unless' . 'foreach' }  includes: self value source
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
