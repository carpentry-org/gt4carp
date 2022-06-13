Class {
	#name : #CarpCliOutput,
	#superclass : #Object,
	#instVars : [
		'text'
	],
	#category : #'Carp-Core'
}

{ #category : #accessing }
CarpCliOutput class >> text: aString [
	^ self new text: aString
]

{ #category : #accessing }
CarpCliOutput >> gtExitCodeFor: aView [
	<gtView>
	^ aView forward
		title: 'Exit Code';
		priority: 2;
		object: [ self text lines last asInteger ];
		view: #gtLiveFor:
]

{ #category : #accessing }
CarpCliOutput >> gtOutputFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Output';
		priority: 1;
		text: [ Character lf join: (self text lines allButLast: 2) ]
]

{ #category : #accessing }
CarpCliOutput >> gtRawOutputFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Raw Output';
		priority: 3;
		text: [ self text ]
]

{ #category : #accessing }
CarpCliOutput >> text [
	^ text
]

{ #category : #accessing }
CarpCliOutput >> text: aString [ 
	text := aString
]
