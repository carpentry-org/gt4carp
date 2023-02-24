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

{ #category : #accessing }
CarpModuleOrTypeNode >> intoModel [
	^ value
		ifNil: [ CarpSymbol named: module source ]
		ifNotNil: [ CarpSymbol
				named: ('.'
						join: {module source.
								value source}) ]
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

{ #category : #accessing }
CarpModuleOrTypeNode >> toPharo [
	^ value
		ifNil: [ module source asSymbol ]
		ifNotNil: [ (module source , '.' , value source) asSymbol ]
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
