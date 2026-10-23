"
I page view items from a Carp value host and answer selected items as
{{gtClass:name=CarpRemoteValue}}s.
"
Class {
	#name : #CarpValueDataSource,
	#superclass : #Object,
	#instVars : [
		'methodSelector',
		'objectId',
		'client',
		'items',
		'objects',
		'viewSource',
		'itemCount',
		'children'
	],
	#category : #'Carp-Execution'
}

{ #category : #accessing }
CarpValueDataSource >> client [
	^ client
]

{ #category : #accessing }
CarpValueDataSource >> client: aClient [
	client := aClient
]

{ #category : #accessing }
CarpValueDataSource >> definingMethod [
	"The defview declaration that built this view, when the host served one."

	^ self viewSource isEmpty
		ifTrue: [ nil ]
		ifFalse: [ CarpViewDefinition selector: methodSelector source: self viewSource ]
]

{ #category : #accessing }
CarpValueDataSource >> flushItemsIterator [
	items := nil.
	objects := nil.
	children := nil.
	itemCount := nil
]

{ #category : #accessing }
CarpValueDataSource >> viewSource [
	^ viewSource ifNil: [ '' ]
]

{ #category : #accessing }
CarpValueDataSource >> viewSource: aString [
	viewSource := aString
]

{ #category : #accessing }
CarpValueDataSource >> methodSelector [
	^ methodSelector
]

{ #category : #accessing }
CarpValueDataSource >> methodSelector: aSymbol [
	methodSelector := aSymbol
]

{ #category : #accessing }
CarpValueDataSource >> objectId [
	^ objectId
]

{ #category : #accessing }
CarpValueDataSource >> objectId: anInteger [
	objectId := anInteger
]

{ #category : #accessing }
CarpValueDataSource >> retrieveItems: anItemsCount fromIndex: startIndex [
	| count cached page |
	items ifNil: [ items := Dictionary new. objects := Dictionary new ].
	itemCount ifNil: [ itemCount := client retrieveViewItemCount: objectId methodSelector: methodSelector ].
	count := ((anItemsCount min: 1024) min: itemCount - startIndex + 1) max: 0.
	count = 0 ifTrue: [ ^ #() ].
	cached := (startIndex to: startIndex + count - 1) allSatisfy: [ :index | items includesKey: index ].
	cached ifTrue: [ ^ (startIndex to: startIndex + count - 1) collect: [ :index | items at: index ] ].
	page := client retrieveViewItems: objectId methodSelector: methodSelector fromIndex: startIndex - 1 count: count.
	page withIndexDo: [ :node :index |
		| position object |
		position := startIndex + index - 1.
		object := node at: 'phlowObject' ifAbsent: [ nil ].
		items at: position put: node.
		objects at: position put: (object ifNotNil: [ CarpRemoteValue fromDictionary: object client: client ]) ].
	^ page
]

{ #category : #accessing }
CarpValueDataSource >> retrieveChildrenForNodeAtPath: aNodePath [
	children ifNil: [ children := Dictionary new ].
	^ (children at: aNodePath asArray ifAbsentPut: [
		| nodes leases |
		nodes := client retrieveViewChildren: objectId methodSelector: methodSelector path: aNodePath.
		leases := nodes collect: [ :node | (node at: 'phlowObject' ifAbsent: [ nil ])
			ifNotNil: [ :object | CarpRemoteValue fromDictionary: object client: client ] ].
		{nodes. leases} ]) first
]

{ #category : #accessing }
CarpValueDataSource >> retriveSentItemAtPath: aNodePath [
	"Selecting a tree node: every nodeId is a registered object id, so the
	existing send route answers it."

	^ CarpRemoteValue
		fromDictionary: (client
				retrieveViewSentItem: objectId
				methodSelector: methodSelector
				selectedObjectId: aNodePath last)
		client: client
]

{ #category : #accessing }
CarpValueDataSource >> retriveSentItemAt: anInteger [
	| object |
	object := objects at: anInteger ifAbsent: [ ^ nil ].
	object ifNil: [ ^ nil ].
	^ CarpRemoteValue
		fromDictionary: (client
				retrieveViewSentItem: objectId
				methodSelector: methodSelector
				selectedObjectId: object id)
		client: client
]
