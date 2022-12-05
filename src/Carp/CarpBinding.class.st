Class {
	#name : #CarpBinding,
	#superclass : #CarpExpression,
	#instVars : [
		'name'
	],
	#category : #'Carp-IDE'
}

{ #category : #accessing }
CarpBinding >> bindingName [
	^ self subclassResponsibility
]

{ #category : #accessing }
CarpBinding >> name [
	^ name
]

{ #category : #accessing }
CarpBinding >> name: aString [
	name := aString
]
