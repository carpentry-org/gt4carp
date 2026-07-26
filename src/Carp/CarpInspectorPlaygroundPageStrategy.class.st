"
I make the inspector's embedded playground speak Carp: for a
{{gtClass:name=CarpRemoteValue}} the playground page starts with a Carp
snippet evaluating in the same notebook session as the inspected value, so
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
	page := LePage named: (self pageDatabaseKeyBasedOnObject: aValue).
	snippet := LeCarpSnippet new.
	snippet explicitSessionId: aValue carpSession.
	page addSnippet: snippet.
	^ page
]

{ #category : #accessing }
CarpInspectorPlaygroundPageStrategy >> pageDatabaseKeyBasedOnObject: aValue [
	^ 'Carp session ' , (aValue carpSession ifNil: [ 'default' ])
]
