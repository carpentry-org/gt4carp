Class {
	#name : #CarpExecutionResult,
	#superclass : #Object,
	#instVars : [
		'value',
		'warnings',
		'view'
	],
	#category : #'Carp-Execution'
}

{ #category : #accessing }
CarpExecutionResult >> gtValueFor: aView [
	<gtView>
	| v |
	v := aView forward
		title: 'Value';
		priority: 1;
		object: value.
	view ifNotNil: [ v view: view ].
	^ v
]

{ #category : #accessing }
CarpExecutionResult >> gtWarningsFor: aView [
	<gtView>
	^ aView list
		title: 'Warnings';
		priority: 2;
		items: [ warnings ]
]

{ #category : #accessing }
CarpExecutionResult >> parse [
	value := CarpParser parse: value
]

{ #category : #accessing }
CarpExecutionResult >> transformValue: aBlock [
	value := aBlock value: value
]

{ #category : #accessing }
CarpExecutionResult >> value [
	^ value
]

{ #category : #accessing }
CarpExecutionResult >> value: aValue [
	value := aValue
]

{ #category : #accessing }
CarpExecutionResult >> view: aView [
	view := aView
]

{ #category : #accessing }
CarpExecutionResult >> warnings: aCollection [
	warnings := aCollection
]
