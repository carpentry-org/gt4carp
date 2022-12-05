Class {
	#name : #CarpVariable,
	#superclass : #CarpBinding,
	#instVars : [
		'binding'
	],
	#category : #'Carp-IDE'
}

{ #category : #accessing }
CarpVariable >> binding [
	^ binding
]

{ #category : #accessing }
CarpVariable >> binding: anExpression [
	binding := anExpression
]

{ #category : #converting }
CarpVariable >> toCarp [

	^ String streamContents: [ :aStream | 
		  aStream << '(' << self bindingName << ' ' << self name toCarp
		  << ' ' << self binding toCarp << ')' ]
]
