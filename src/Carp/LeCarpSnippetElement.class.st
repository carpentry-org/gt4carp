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
LeCarpSnippetElement >> foreignSessionName [
	"The session's name when this snippet evaluates somewhere other than its
	own page — a snippet pinned to an inspected value's session, say. A
	page-scoped session is the page the reader is already looking at, so it
	answers nil: there is nothing to tell them."

	| sessionId ownPageId |
	sessionId := [ self coder sessionId ] on: Error do: [ :e | nil ].
	sessionId ifNil: [ ^ nil ].
	ownPageId := [ self snippetViewModel snippetModel page
			ifNotNil: [ :aPage | aPage uid asString36 ] ]
			on: Error
			do: [ :e | nil ].
	sessionId = ownPageId ifTrue: [ ^ nil ].
	^ LeCarpSnippet displayNameForSession: sessionId
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
				self foreignSessionName
					ifNotNil: [ :aName | stream << ' · ' << aName ] ].
	languageElement
		text: (label asRopedText glamorousRegularFont
				foreground: BrGlamorousColors textMarkupColor)
]
