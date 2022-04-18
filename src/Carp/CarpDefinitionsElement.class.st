Class {
	#name : #CarpDefinitionsElement,
	#superclass : #BrExpander,
	#instVars : [
		'module'
	],
	#category : #'Carp-Coder'
}

{ #category : #accessing }
CarpDefinitionsElement >> addDefinitionEditorShortcutsTo: aPropertiesElement [

	aPropertiesElement addShortcut: (BlShortcutWithAction new
			 combination: BlKeyCombination arrowUp;
			 action: [ :anEvent | 
				 anEvent currentTarget deepestFocusedChild ifNotNil: [ 
						 :aFocusedChild | 
						 BlFocusFinder new
							 up;
							 root: anEvent currentTarget;
							 referenceElement: aFocusedChild;
							 nextFocusDo: [ :aNextFocusElement | 
								 aNextFocusElement requestFocus ] ] ]).

	aPropertiesElement addShortcut: (BlShortcutWithAction new
			 combination: BlKeyCombination arrowDown;
			 action: [ :anEvent | 
				 anEvent currentTarget deepestFocusedChild ifNotNil: [ 
						 :aFocusedChild | 
						 BlFocusFinder new
							 down;
							 root: anEvent currentTarget;
							 referenceElement: aFocusedChild;
							 nextFocusDo: [ :aNextFocusElement | 
								 aNextFocusElement requestFocus ] ] ])
]

{ #category : #accessing }
CarpDefinitionsElement >> buildDefinitionEditor [

	| theProperties |
	theProperties := BrHorizontalGrid new constraintsDo: [ :c | 
		                 c horizontal matchParent.
		                 c vertical fitContent ].

	self addDefinitionEditorShortcutsTo: theProperties.

	theProperties addChild:
		self module asGtMagritteViewModel asElement.

	^ theProperties
]

{ #category : #accessing }
CarpDefinitionsElement >> buildDefinitionReader [

	| theProperties theReaders |
	theProperties := BrHorizontalGrid new constraintsDo: [ :c | 
		                 c horizontal matchParent.
		                 c vertical fitContent ].

	theProperties addChild:
		(self module asGtMagritteViewModelWithDescription:
			 self module usesDescription beReadOnly) asElement.

	^ theProperties
]

{ #category : #accessing }
CarpDefinitionsElement >> initialize [
	super initialize.	

	self
		aptitude: GtCoderExpanderAptitude;
		hMatchParent;
		vFitContent
]

{ #category : #accessing }
CarpDefinitionsElement >> module [
	^ module
]

{ #category : #accessing }
CarpDefinitionsElement >> module: aCarpModule [
	module := aCarpModule.
	self updateElements
]

{ #category : #accessing }
CarpDefinitionsElement >> updateElements [

	self header: [ 
		self buildDefinitionReader ].
	self content: [ 
		self buildDefinitionEditor ]
]
