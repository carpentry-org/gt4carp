Class {
	#name : #CarpStreamingMethodsCoderElement,
	#superclass : #BlElement,
	#traits : 'TBrLayoutResizable + TGtWithStreamingCodersViewModel',
	#classTraits : 'TBrLayoutResizable classTrait + TGtWithStreamingCodersViewModel classTrait',
	#instVars : [
		'list',
		'module'
	],
	#category : #'Carp-Coder'
}

{ #category : #accessing }
CarpStreamingMethodsCoderElement class >> forModule: aModule [
	^ self new module: aModule
]

{ #category : #accessing }
CarpStreamingMethodsCoderElement >> initialize [

	super initialize.

	self matchParent.

	list := BrSimpleList new
		        itemType: [ :anItemTypeFactory :anItemObject | 
			        anItemObject ];
		        itemStencil: [ :anItem | 
			        anItem asElement id: GtSourceCoderId ];
		        itemsProvider:
			        (BrListStreamItemsProvider new stream: AsyncEmptyStream new).

	self addChild: list
]

{ #category : #accessing }
CarpStreamingMethodsCoderElement >> initializeForModule [
	list itemsProvider: module expressions asBrItemsProvider
]

{ #category : #accessing }
CarpStreamingMethodsCoderElement >> module: aModule [ 
	module := aModule.
	self initializeForModule
]
