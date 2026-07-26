"
I page view items from a Carp value host and answer selected items as
{{gtClass:name=CarpRemoteValue}}s.
"
Class {
	#name : #CarpValueDataSource,
	#superclass : #GtPhlowRustRemoteDataSource,
	#category : #'Carp-Execution'
}

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
CarpValueDataSource >> retriveSentItemAt: anInteger [
	^ CarpRemoteValue
		fromDictionary: (client
				retrieveViewSentItem: objectId
				methodSelector: methodSelector
				selectedObjectId: (objects at: anInteger) id)
		client: client
]
