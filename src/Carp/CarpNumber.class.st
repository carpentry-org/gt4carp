Class {
	#name : #CarpNumber,
	#superclass : #CarpLiteral,
	#instVars : [
		'number'
	],
	#category : #'Carp-IDE'
}

{ #category : #'instance creation' }
CarpNumber class >> number: aNumber [
	^ self new number: aNumber
]

{ #category : #acccessing }
CarpNumber >> number: aNumber [ 
	number := aNumber
]

{ #category : #accessing }
CarpNumber >> suffix [
	^ self subclassResponsibility
]

{ #category : #converting }
CarpNumber >> toCarp [
	^ number asString, self suffix
]
