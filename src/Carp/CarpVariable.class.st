Class {
	#name : #CarpVariable,
	#superclass : #CarpBinding,
	#instVars : [
		'binding'
	],
	#category : #'Carp-IDE'
}

{ #category : #'instance creation' }
CarpVariable class >> named: aString binding: anExpression [

	^ self new
		name: aString;
		binding: anExpression
]

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
