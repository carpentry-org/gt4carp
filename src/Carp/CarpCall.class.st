Class {
	#name : #CarpCall,
	#superclass : #CarpExpression,
	#instVars : [
		'function',
		'arguments'
	],
	#category : #'Carp-IDE'
}

{ #category : #'instance creation' }
CarpCall class >> function: aSymbol arguments: aCollection [
	^ self new name: aSymbol; arguments: aCollection
]

{ #category : #accessing }
CarpCall >> addArgument: anArgument [
	arguments add: anArgument
]

{ #category : #accessing }
CarpCall >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #initialization }
CarpCall >> initialize [
	arguments := OrderedCollection new
]

{ #category : #accessing }
CarpCall >> name: aSymbol [
	function := aSymbol
]

{ #category : #accessing }
CarpCall >> toCarp [

	^ String streamContents: [ :aStream | 
		  aStream << '(' << function toCarp.
		  arguments do: [ :anArgument | aStream << ' ' << anArgument toCarp ].
		  aStream << ')' ]
]
