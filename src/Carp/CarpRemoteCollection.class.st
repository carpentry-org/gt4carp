"
I am a live Carp value that holds other values: an array, a set, a bag.

The host already lists my elements — that view comes from Carp, and drilling
into an element is a request to the host. What Pharo adds is everything you
do to a collection once you have it in hand: {{gtMethod:name=CarpRemoteCollection>>#elements}}
fetches them once as live values of their own, so they can be searched,
sorted and counted here rather than one round trip at a time, and each one
still opens as what it is.

I read them through the host's own items endpoint, the same one the
Carp-side view uses, so what I hold is what it lists.
"
Class {
	#name : #CarpRemoteCollection,
	#superclass : #CarpRemoteValue,
	#instVars : [
		'elements'
	],
	#category : #'Carp-Execution'
}

{ #category : #'instance creation' }
CarpRemoteCollection class >> remoteTypeName [
	"The types whose values are a sequence of other values. Subclasses of a
	collection answer their own name; this one answers the array's, which is
	the collection you meet most."

	^ 'Array'
]

{ #category : #accessing }
CarpRemoteCollection >> itemsViewSelector [
	"The Carp-side view that lists what I hold. Answers nil when the host
	serves none, which is what a value with no view looks like."

	^ (self remoteViewSpecifications
		detect: [ :each | each title = 'Items' ]
		ifNone: [ nil ]) ifNotNil: [ :each | each methodSelector ]
]

{ #category : #accessing }
CarpRemoteCollection >> remoteViewSpecifications [
	^ [ self client remoteViewsSpecificationsOf: self id ]
		on: Error
		do: [ :e | #() ]
]

{ #category : #accessing }
CarpRemoteCollection >> elements [
	"What the host says I hold, fetched once and kept: a collection is read
	far more often than it changes, and it cannot change here at all."

	^ elements
		ifNil: [ elements := self itemsViewSelector
					ifNil: [ #() ]
					ifNotNil: [ :aSelector |
						[ (self client retrieveViewItems: self id methodSelector: aSelector)
							collect: [ :each | self elementFrom: each ] ]
							on: Error
							do: [ :e | #() ] ] ]
]

{ #category : #accessing }
CarpRemoteCollection >> elementFrom: aNode [
	"One element as the protocol sends it. An item node carries the value
	itself alongside the text the list shows, so an element is a live value
	like any other and opens as one — a nested array is an array, not the
	sentence the row happened to print."

	| object |
	aNode isDictionary ifFalse: [ ^ aNode ].
	object := aNode at: 'phlowObject' ifAbsent: [ nil ].
	^ object
		ifNil: [ aNode printString ]
		ifNotNil: [ CarpRemoteValue fromDictionary: object client: self client ]
]

{ #category : #accessing }
CarpRemoteCollection >> size [
	^ self elements size
]

{ #category : #inspecting }
CarpRemoteCollection >> gtElementsFor: aView [
	<gtView>
	self elements ifEmpty: [ ^ aView empty ].
	^ aView columnedList
		title: 'Elements';
		priority: 3;
		items: [ self elements withIndexCollect: [ :each :i | i - 1 -> each ] ];
		column: '#' text: [ :each | each key ] width: 60;
		column: 'Value' text: [ :each | each value printString ];
		send: [ :each | each value ]
]
