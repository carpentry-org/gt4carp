Class {
	#name : #CarpNamedFunction,
	#superclass : #CarpBinding,
	#instVars : [
		'arguments',
		'body'
	],
	#category : #'Carp-IDE'
}

{ #category : #'instance creation' }
CarpNamedFunction class >> named: aString withArguments: aCollection andBody: anExpression [
	^ self new 
		name: aString;
		arguments: aCollection;
		body: anExpression
]

{ #category : #accessing }
CarpNamedFunction >> addArgument: anArgument [
	arguments add: anArgument
]

{ #category : #accessing }
CarpNamedFunction >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #accessing }
CarpNamedFunction >> body [

	^ body
]

{ #category : #accessing }
CarpNamedFunction >> body: anExpression [
	body := anExpression
]

{ #category : #initialization }
CarpNamedFunction >> initialize [
	arguments := OrderedCollection new
]

{ #category : #converting }
CarpNamedFunction >> toCarp [

	^ String streamContents: [ :aStream | 
		  aStream << '(' << self bindingName << ' ' << self name toCarp
		  << ' ['.
		  arguments do: [ :anArgument | aStream << anArgument toCarp << ' ' ].
		  aStream << '] ' << self body toCarp << ')' ]
]
