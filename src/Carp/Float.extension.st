Extension { #name : #Float }

{ #category : #'*Carp' }
Float >> asCarpDouble [
	^ CarpDouble number: self
]

{ #category : #'*Carp' }
Float >> asCarpFloat [
	^ CarpFloat number: self
]
