Extension { #name : #ByteString }

{ #category : #'*Carp' }
ByteString >> asCarpModule [
	^ CarpModule named: self
]

{ #category : #'*Carp' }
ByteString >> asCarpSymbol [
	^ CarpSymbol named: self
]
