Class {
	#name : #CarpExpression,
	#superclass : #Object,
	#instVars : [
		'documentation'
	],
	#category : #'Carp-IDE'
}

{ #category : #accessing }
CarpExpression >> asElement [
	^ (GtCarpCoderModel code: self toCarp) asElement
]

{ #category : #accessing }
CarpExpression >> asElementWithModule: aModule [
	| applicationStrategy |
	applicationStrategy := LeCarpApplicationStrategy new.
	^ (GtExpandableSourceCoderElement new
		coderViewModel: ((GtCarpIDECoderModel code: self toCarp)
				module: aModule;
				carpLinkApplicationStrategy: applicationStrategy;
				expression: self) asCoderViewModel) collapse
]

{ #category : #accessing }
CarpExpression >> documentation [
	^ documentation ifNil: ['']
]

{ #category : #accessing }
CarpExpression >> documentation: aString [
	documentation := aString
]

{ #category : #accessing }
CarpExpression >> gtCoderFor: aView [
	<gtView>
	^ aView explicit
		title: 'Code';
		priority: 1;
		stencil: [ self asElement ]
]

{ #category : #accessing }
CarpExpression >> gtTextFor: aView [
	<gtView>
	^ aView textEditor
		title: 'String';
		priority: 2;
		text: [ self toCarp ]
]

{ #category : #converting }
CarpExpression >> toCarp [
	^ self subclassResponsibility
]
