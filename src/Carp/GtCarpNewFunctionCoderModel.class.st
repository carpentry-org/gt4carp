Class {
	#name : #GtCarpNewFunctionCoderModel,
	#superclass : #GtCarpCoderModel,
	#instVars : [
		'module',
		'onSave'
	],
	#category : #'Carp-Coder'
}

{ #category : #accessing }
GtCarpNewFunctionCoderModel >> initializeAddOns: addOns [
	addOns
		addMainAction: 'Save' translated
		icon: BrGlamorousVectorIcons accept
		action: [ :aCoderUIModel :anElement | self save ]
		id: GtMethodCoderSaveActionId
]

{ #category : #coders }
GtCarpNewFunctionCoderModel >> module: aModule [
	module := aModule
]

{ #category : #accessing }
GtCarpNewFunctionCoderModel >> onSave: aBlock [
	onSave := aBlock
]

{ #category : #accessing }
GtCarpNewFunctionCoderModel >> save [
	| expression |
	expression := (CarpParser parse: sourceCode currentSourceText value text) intoModel.
	module addExpression: expression.
	self bindAndExecute: module toCarp.
	onSave ifNotNil: [ onSave value ]
]
