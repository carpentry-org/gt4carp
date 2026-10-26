Class {
  #name : #CarpValuePagingStub,
  #superclass : #Object,
  #instVars : [ 'requests', 'selected', 'sendable' ],
  #category : #'Carp-Examples'
}

{ #category : #initialization }
CarpValuePagingStub >> initialize [
  super initialize.
  requests := OrderedCollection new.
  selected := OrderedCollection new.
  sendable := true
]

{ #category : #accessing }
CarpValuePagingStub >> requests [ ^ requests ]

{ #category : #accessing }
CarpValuePagingStub >> selected [ ^ selected ]

{ #category : #accessing }
CarpValuePagingStub >> withoutSelections [ sendable := false ]

{ #category : #accessing }
CarpValuePagingStub >> objectAt: index [
  ^ Dictionary new
    at: 'id' put: index;
    at: 'object_type' put: 'Int';
    at: 'print_string' put: index printString;
    at: 'reference_count' put: 1;
    at: 'should_auto_release' put: false;
    yourself
]

{ #category : #accessing }
CarpValuePagingStub >> retrieveViewItemCount: objectId methodSelector: selector [ ^ 700 ]

{ #category : #accessing }
CarpValuePagingStub >> retrieveViewItems: objectId methodSelector: selector fromIndex: offset count: count [
  requests add: {offset. count}.
  ^ (offset to: offset + count - 1) collect: [ :index |
    Dictionary new at: 'nodeId' put: index;
      at: 'phlowObject' put: (sendable ifTrue: [ self objectAt: index ] ifFalse: [ nil ]);
      yourself ]
]

{ #category : #accessing }
CarpValuePagingStub >> retrieveViewSentItem: objectId methodSelector: selector selectedObjectId: child [
  selected add: child.
  ^ self objectAt: child
]

{ #category : #accessing }
CarpValuePagingStub >> remoteViewsSpecificationsOf: objectId [
  ^ { GtPhlowColumnedListViewSpecification new title: 'Items'; methodSelector: 'array-items'; yourself }
]
