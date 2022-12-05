Class {
	#name : #LeCarpSnippet,
	#superclass : #LeCodeSnippet,
	#category : #'Carp-Lepiter'
}

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
