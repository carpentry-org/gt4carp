Class {
	#name : #CarpSequence,
	#superclass : #CarpLiteral,
	#instVars : [
		'elements',
		'contents'
	],
	#category : #'Carp-IDE'
}

{ #category : #'instance creation' }
CarpSequence class >> contents: aCollection [
	^ self new contents: aCollection
]

{ #category : #accessing }
CarpSequence >> close [
	^ self subclassResponsibility
]

{ #category : #accessing }
CarpSequence >> contents: aCollection [
	contents := aCollection
]

{ #category : #accessing }
CarpSequence >> do: aBlock [
	contents do: aBlock
]

{ #category : #accessing }
CarpSequence >> open [
	^ self subclassResponsibility
]

{ #category : #accessing }
CarpSequence >> toCarp [

	^ String streamContents: [ :aStream | 
		  aStream << self open.
		  contents do: [ :anArgument | aStream << anArgument toCarp << ' ' ].
		  aStream ensureNoSpace << self close]
]
