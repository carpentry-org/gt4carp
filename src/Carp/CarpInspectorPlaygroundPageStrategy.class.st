"
I make the inspector's embedded playground speak Carp: for a
{{gtClass:name=CarpRemoteValue}} the playground page is a
{{gtClass:name=LeCarpSessionPageType}} page — one per notebook session —
whose Carp snippet evaluates in the same session as the inspected value, so
the session's definitions are available.
"
Class {
	#name : #CarpInspectorPlaygroundPageStrategy,
	#superclass : #LeInspectorPlaygroundLocalClassPageStrategy,
	#category : #'Carp-Execution'
}

{ #category : #accessing }
CarpInspectorPlaygroundPageStrategy >> configureExistingPage: aPage forObject: aValue [
	aPage children
		do: [ :eachSnippet |
			(eachSnippet isKindOf: LeCarpSnippet)
				ifTrue: [ eachSnippet explicitSessionId: aValue carpSession ] ]
]

{ #category : #accessing }
CarpInspectorPlaygroundPageStrategy >> createNewPageForObject: aValue [
	| page snippet |
	page := LePage new.
	page type: (LeCarpSessionPageType
			sessionId: (self pageDatabaseKeyBasedOnObject: aValue)
			page: page).
	snippet := LeCarpSnippet new.
	snippet explicitSessionId: aValue carpSession.
	page addSnippet: snippet.
	^ page
]

{ #category : #accessing }
CarpInspectorPlaygroundPageStrategy >> pageDatabaseKeyBasedOnObject: aValue [
	^ aValue carpSession ifNil: [ 'default' ]
]

{ #category : #accessing }
CarpInspectorPlaygroundPageStrategy >> playgroundPageType [
	^ LeCarpSessionPageType
]
