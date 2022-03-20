Class {
	#name : #CarpModuleOrTypeNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'value'
	],
	#category : #Carp
}

{ #category : #generated }
CarpModuleOrTypeNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitModuleOrType: self
]

{ #category : #generated }
CarpModuleOrTypeNode >> otherVariables [

	^ #( #value )
]

{ #category : #generated }
CarpModuleOrTypeNode >> value [

	^ value
]

{ #category : #generated }
CarpModuleOrTypeNode >> value: anObject [

	self setParent: self value to: nil.
	value := anObject.
	self setParent: self value to: self
]
