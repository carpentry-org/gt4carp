Class {
	#name : #LeCarpSnippetElement,
	#superclass : #LeExternalEvaluatedSnippetElement,
	#instVars : [
		'serverStrategy'
	],
	#category : #'Carp-Lepiter'
}

{ #category : #accessing }
LeCarpSnippetElement >> onSnippetViewModelChanged [
	super onSnippetViewModelChanged.

	self updateLanguageLabel.
	self coder
		carpLinkApplicationStrategy: self serverStrategy;
		pharoBindings: self snippetViewModel snippetBindings
]

{ #category : #accessing }
LeCarpSnippetElement >> serverStrategy [

	^ serverStrategy ifNil: 
		[ serverStrategy := LeCarpApplicationStrategy new content: self snippet ].
]

{ #category : #accessing }
LeCarpSnippetElement >> updateLanguageLabel [
	| serverAddress label |

	serverAddress := self serverStrategy applicationSettings serverSocketAddress.
	label := String streamContents: [ :stream |
		stream
			<< 'Carp @ ';
			<< serverAddress ipOrName;
			<< ':';
			print: serverAddress port ].
	languageElement text: (label asRopedText glamorousRegularFont foreground: BrGlamorousColors textMarkupColor).
]
