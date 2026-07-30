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
	playground); by default the session derives from the page."

	explicitSessionId := aString
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
