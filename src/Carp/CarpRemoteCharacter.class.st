"
I am a live Carp `Char`. Carp characters are Unicode codepoints, and print
as themselves.
"
Class {
	#name : #CarpRemoteCharacter,
	#superclass : #CarpRemoteScalar,
	#category : #'Carp-Execution'
}

{ #category : #'instance creation' }
CarpRemoteCharacter class >> remoteTypeName [
	^ 'Char'
]

{ #category : #converting }
CarpRemoteCharacter >> asPharoValue [
	^ self asCharacter
]

{ #category : #converting }
CarpRemoteCharacter >> asCharacter [
	^ self printString ifEmpty: [ Character space ] ifNotEmpty: [ :each | each first ]
]
