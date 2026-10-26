Class {
  #name : #CarpValuePagingExamples,
  #superclass : #Object,
  #category : #'Carp-Examples'
}

{ #category : #examples }
CarpValuePagingExamples >> boundedPagesAndSelection [
  <gtExample>
  | client source page |
  client := CarpValuePagingStub new.
  source := CarpValueDataSource new client: client; objectId: 0; methodSelector: 'array-items'; yourself.
  page := source retrieveItems: 3 fromIndex: 5.
  self assert: page size equals: 3.
  self assert: client requests asArray equals: #((4 3)).
  self assert: (source retrieveItems: 3 fromIndex: 5) equals: page.
  self assert: client requests size equals: 1.
  self assert: (source retriveSentItemAt: 6) id equals: 5.
  self assert: client selected asArray equals: #(5).
  source retrieveItems: 256 fromIndex: 257.
  self assert: client requests last equals: #(256 256).
  self assert: (source retriveSentItemAt: 258) id equals: 257.
  self assert: (source retrieveItems: 100 fromIndex: 701) isEmpty.
  self assert: client requests size equals: 2.
  ^ source
]

{ #category : #examples }
CarpValuePagingExamples >> rowsWithoutSelection [
  <gtExample>
  | client source |
  client := CarpValuePagingStub new withoutSelections; yourself.
  source := CarpValueDataSource new client: client; objectId: 0; methodSelector: 'plain'; yourself.
  source retrieveItems: 1 fromIndex: 1.
  self assert: (source retriveSentItemAt: 1) isNil.
  self assert: client selected isEmpty.
  ^ source
]

{ #category : #examples }
CarpValuePagingExamples >> collectionSizeAndExplicitMaterialization [
  <gtExample>
  | client collection elements |
  client := CarpValuePagingStub new.
  collection := CarpRemoteCollection new id: 0; client: client; yourself.
  self assert: collection size equals: 700.
  self assert: client requests isEmpty.
  elements := collection elements.
  self assert: elements size equals: 700.
  self assert: elements last id equals: 699.
  self assert: client requests asArray equals: #((0 256) (256 256) (512 188)).
  self assert: collection elements == elements.
  ^ collection
]
