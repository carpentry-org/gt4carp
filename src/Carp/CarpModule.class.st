Class {
	#name : #CarpModule,
	#superclass : #CarpExpression,
	#instVars : [
		'uses',
		'expressions',
		'name'
	],
	#category : #'Carp-IDE'
}

{ #category : #'instance creation' }
CarpModule class >> named: aString [
	^ self new name: aString
]

{ #category : #accessing }
CarpModule >> addExpression: anExpression [
	expressions add: anExpression
]

{ #category : #accessing }
CarpModule >> addUse: aString [
	uses add: aString
]

{ #category : #initialization }
CarpModule >> initialize [
	uses := Set new.
	expressions := OrderedCollection new.
]

{ #category : #converting }
CarpModule >> name [
	^ name
]

{ #category : #accessing }
CarpModule >> name: aString [ 
	name := aString
]

{ #category : #converting }
CarpModule >> toCarp [

	^ String streamContents: [ :aStream | 
		  aStream << '(defmodule ' << self name << ' '
		  << (uses ifEmpty: [ '' ] ifNotEmpty: [ 
				   Character lf , Character tab , '(use-all '
				   , (' ' join: uses) , ')' ]).
		  expressions do: [ :expression | 
			  aStream << Character lf << Character tab
			  << expression toCarp ].
		  aStream << ')' ]
]
