Class {
	#name : #CarpSymbol,
	#superclass : #CarpLiteral,
	#instVars : [
		'name'
	],
	#category : #'Carp-IDE'
}

{ #category : #'instance creation' }
CarpSymbol class >> named: aString [
	^ self new name: aString 
]

{ #category : #accessing }
CarpSymbol >> name [
	^ name
]

{ #category : #accessing }
CarpSymbol >> name: aString [
	name := aString
]

{ #category : #accessing }
CarpSymbol >> toCarp [
	^ name
]
