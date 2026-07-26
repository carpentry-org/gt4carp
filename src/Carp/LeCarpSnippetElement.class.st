Class {
	#name : #LeCarpSnippetElement,
	#superclass : #LeExternalEvaluatedSnippetElement,
	#category : #'Carp-Lepiter'
}

{ #category : #accessing }
LeCarpSnippetElement >> onSnippetViewModelChanged [
	super onSnippetViewModelChanged.

	self updateLanguageLabel.
	self coder pharoBindings: self snippetViewModel snippetBindings
]

{ #category : #accessing }
LeCarpSnippetElement >> updateLanguageLabel [
	| label |
	label := String
			streamContents: [ :stream |
				stream << 'Carp · '.
				CarpServerClient default isConnected
					ifTrue: [ stream << ':' << CarpServerClient defaultPort printString ]
					ifFalse: [ stream << 'server on demand' ].
				stream << ' · ' << self coder sessionId ].
	languageElement
		text: (label asRopedText glamorousRegularFont
				foreground: BrGlamorousColors textMarkupColor)
]
