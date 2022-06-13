Extension { #name : #String }

{ #category : #'*Carp' }
String >> asCarpModule [
	^ CarpModule named: self
]

{ #category : #'*Carp' }
String >> asCarpSymbol [
	^ CarpSymbol named: self
]
