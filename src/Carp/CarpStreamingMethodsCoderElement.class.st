Class {
	#name : #CarpStreamingMethodsCoderElement,
	#superclass : #BlElement,
	#traits : 'TBrLayoutResizable + TGtWithStreamingCodersViewModel',
	#classTraits : 'TBrLayoutResizable classTrait + TGtWithStreamingCodersViewModel classTrait',
	#instVars : [
		'listItemsProvider',
		'list'
	],
	#category : #'Carp-Coder'
}

{ #category : #accessing }
CarpStreamingMethodsCoderElement >> initialize [
	super initialize.
	
	self matchParent.
	
	listItemsProvider := BrListStreamItemsProvider new stream: AsyncEmptyStream new.

	list := BrSimpleList new
		itemType: [ :anItemTypeFactory :anItemObject | anItemObject elementClass ];
		itemStencil: [ :anElementClass | anElementClass new id: GtSourceCoderId ];
		itemDataBinder: [ :aCoderElement :aCoderViewModel |
			BlFrameTelemetry
				time: [ 'Set {1} as a view model of {2}' format: { aCoderViewModel class name . aCoderElement class name } ]
				during: [ aCoderElement textualCoderViewModel: aCoderViewModel ] ];
		itemsProvider: listItemsProvider.
	
	self addChild: list
]
