Class {
	#name : #CarpCharacter,
	#superclass : #CarpLiteral,
	#instVars : [
		'character'
	],
	#category : #'Carp-IDE'
}

{ #category : #accessing }
CarpCharacter >> character [
	^ character
]

{ #category : #accessing }
CarpCharacter >> character: aCharacter [
	character := aCharacter
]

{ #category : #accessing }
CarpCharacter >> toCarp [
	^ '\', self character
]
