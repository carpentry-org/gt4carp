Class {
	#name : #GtCarpIDECoderModel,
	#superclass : #GtCarpNewFunctionCoderModel,
	#instVars : [
		'expression'
	],
	#category : #'Carp-Coder'
}

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
	^ module removeExpression: self expression
]

{ #category : #accessing }
GtCarpIDECoderModel >> save [
	module removeExpression: expression.
	module
		addExpression: (CarpParser parse: sourceCode availableSource text) intoModel.
	onSave ifNotNil: [ onSave value ]
]
