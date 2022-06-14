Class {
	#name : #GtCarpIDECoderModel,
	#superclass : #GtCarpNewFunctionCoderModel,
	#instVars : [
		'expression'
	],
	#category : #'Carp-Coder'
}

{ #category : #accessing }
GtCarpIDECoderModel >> collapsedTextPromise [
	^ self expression name name , ' : '
		, (self bindAndExecute: '(type ' , module name, '.', self expression name name , ')') value
]

{ #category : #accessing }
GtCarpIDECoderModel >> expression [
	^ expression
]

{ #category : #accessing }
GtCarpIDECoderModel >> expression: anExpression [
	expression := anExpression
]

{ #category : #accessing }
GtCarpIDECoderModel >> initializeAddOns: addOns [
	super initializeAddOns: addOns.

	addOns
		addMainAction: 'Remove' translated
		icon: BrGlamorousVectorIcons remove
		action: [ :aCoderUIModel :anElement | self remove ]
		id: GtMethodCoderSaveActionId
]

{ #category : #accessing }
GtCarpIDECoderModel >> remove [
	module removeExpression: self expression.
	self bindAndExecute: module toCarp
]

{ #category : #accessing }
GtCarpIDECoderModel >> save [
	module removeExpression: expression.
	module
		addExpression: (CarpParser parse: sourceCode availableSource text) intoModel.
	self bindAndExecute: module toCarp.
	onSave ifNotNil: [ onSave value ]
]
