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
		'viewSource'
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
	startIndex > 1 ifTrue: [ ^ #() ].

	items ifNil: [ items := client
				retrieveViewItems: objectId
				methodSelector: methodSelector.
			objects := items
					collect: [ :item | CarpRemoteValue fromDictionary: (item at: 'phlowObject') client: client ] ].

	^ items
]

{ #category : #accessing }
CarpValueDataSource >> retrieveChildrenForNodeAtPath: aNodePath [
	"Tree expansion: children hang off the node object itself, so the host
	only needs the path's last id."

	^ client
		retrieveViewChildren: objectId
		methodSelector: methodSelector
		path: aNodePath
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
	^ CarpRemoteValue
		fromDictionary: (client
				retrieveViewSentItem: objectId
				methodSelector: methodSelector
				selectedObjectId: (objects at: anInteger) id)
		client: client
]
