Class {
	#name : #CarpStringExpression,
	#superclass : #CarpExpression,
	#instVars : [
		'contents'
	],
	#category : #'Carp-IDE'
}

{ #category : #'instance creation' }
CarpStringExpression class >> contents: aString [
	^ self new contents: aString
]

{ #category : #'instance creation' }
CarpStringExpression >> contents: aString [ 
	contents := aString
]

{ #category : #accessing }
CarpStringExpression >> toCarp [
	^ contents asString
]
