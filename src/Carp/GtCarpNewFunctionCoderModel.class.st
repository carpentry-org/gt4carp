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
	super initializeAddOns: addOns.

	addOns
				addMainAction: 'Save' translated
				icon: BrGlamorousVectorIcons accept
				action: [ :aCoderUIModel :anElement | 
					self save ]
				id: GtMethodCoderSaveActionId.
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
	module addExpression: (CarpParser parse: sourceCode currentSourceText value text) intoModel.
	onSave ifNotNil: [ onSave value ]
]
