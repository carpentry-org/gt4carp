Extension { #name : #Integer }

{ #category : #'*Carp' }
Integer >> asCarpInteger [
	^ CarpInteger number: self
]

{ #category : #'*Carp' }
Integer >> asCarpLong [
	^ CarpLong number: self
]
