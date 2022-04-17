Class {
	#name : #CarpModuleOrTypeNode,
	#superclass : #CarpExpressionNode,
	#instVars : [
		'module',
		'value'
	],
	#category : #'Carp-Parser'
}

{ #category : #generated }
CarpModuleOrTypeNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitModuleOrType: self
]

{ #category : #generated }
CarpModuleOrTypeNode >> module [

	^ module
]

{ #category : #generated }
CarpModuleOrTypeNode >> module: aSmaCCToken [

	module := aSmaCCToken
]

{ #category : #generated }
CarpModuleOrTypeNode >> nodeVariables [

	^ #( #value )
]

{ #category : #generated }
CarpModuleOrTypeNode >> tokenVariables [

	^ #( #module )
]

{ #category : #generated }
CarpModuleOrTypeNode >> value [

	^ value
]

{ #category : #generated }
CarpModuleOrTypeNode >> value: aCarpExpressionNode [

	self value notNil ifTrue: [ self value parent: nil ].
	value := aCarpExpressionNode.
	self value notNil ifTrue: [ self value parent: self ]
]
