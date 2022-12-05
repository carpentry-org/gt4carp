Class {
	#name : #LeCarpSnippet,
	#superclass : #LeCodeSnippet,
	#category : #'Carp-Lepiter'
}

{ #category : #'api - accessing menu' }
LeCarpSnippet class >> contextMenuItemSpecification [
	<leSnippetSpecification>
	^ LeContextMenuItemSpecification new
		snippetClass: self;
		title: 'Carp'
]

{ #category : #'lepiter-store' }
LeCarpSnippet class >> leJsonV3Name [

	^ 'carpSnippet'
]

{ #category : #'lepiter-store' }
LeCarpSnippet class >> leJsonV4Name [

	^ 'carpSnippet'
]

{ #category : #visiting }
LeCarpSnippet >> acceptVisitor: aVisitor [

	^ aVisitor visitCarpSnippet: self
]

{ #category : #converting }
LeCarpSnippet >> asSnippetViewModel [
	<return: #LeSnippetViewModel>
	^ LeCarpSnippetViewModel new snippetModel: self
]

{ #category : #accessing }
LeCarpSnippet >> newCoder [
	^ GtCarpCoderModel new
]
