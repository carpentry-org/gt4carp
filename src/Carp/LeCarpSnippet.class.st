Class {
	#name : #LeCarpSnippet,
	#superclass : #LeCodeSnippet,
	#instVars : [
		'explicitSessionId'
	],
	#category : #'Carp-Lepiter'
}

{ #category : #'class initialization' }
LeCarpSnippet class >> initialize [
	"The Lepiter JSON serializer caches its class mappings; built before this
	class loads, it cannot store pages holding Carp snippets. Rebuild it."

	LeJsonV4 cleanUniqueInstance
]

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
LeCarpSnippet >> explicitSessionId [
	^ explicitSessionId
]

{ #category : #accessing }
LeCarpSnippet >> explicitSessionId: aString [
	"Pin this snippet to a specific notebook session (used by the inspector
	playground); by default the session derives from the page. The coder is
	built in the superclass' initialize, so it already exists by the time a
	pin arrives and has to be retargeted here."

	explicitSessionId := aString.
	coder ifNotNil: [ :aCoder | aCoder sessionId: aString ]
]

{ #category : #accessing }
LeCarpSnippet class >> displayNameForSession: aSessionId [
	"Resolve a session id back to a name a reader recognizes. Sessions are
	keyed by the page uid, which reads as a random string; answer that
	page's title instead. Ids that are no page of any registered database
	(e.g. 'default', or a page that is not loaded) answer themselves.
	Resolved at label time, not at coder creation: snippets cache their
	coder, so anything seeded at construction misses existing snippets."

	aSessionId ifNil: [ ^ '' ].
	[ LeDatabasesRegistry defaultLogicalDatabase
		databasesDo: [ :db |
			db pagesDo: [ :p |
				([ p uid asString36 ] on: Error do: [ :e | nil ]) = aSessionId
					ifTrue: [ ^ p title ifEmpty: [ aSessionId ] ] ] ] ]
		on: Error
		do: [ :e |  ].
	^ aSessionId
]

{ #category : #accessing }
LeCarpSnippet >> newCoder [
	| coder |
	coder := GtCarpCoderModel new.
	explicitSessionId
		ifNotNil: [ :sid | coder sessionId: sid ]
		ifNil: [ coder
				sessionIdProvider: [ [ self page ifNotNil: [ :aPage | aPage uid asString36 ] ]
						on: Error
						do: [ :e | nil ] ] ].
	^ coder
]
