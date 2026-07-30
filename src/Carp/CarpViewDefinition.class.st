"
I am the definition of a remote Carp view: the source of the defview
declaration that built it, served by the value host in the view
specification. The inspector's Definition view renders me via gtSourceFor:.
"
Class {
	#name : #CarpViewDefinition,
	#superclass : #Object,
	#instVars : [
		'selector',
		'source'
	],
	#category : #'Carp-Execution'
}

{ #category : #'instance creation' }
CarpViewDefinition class >> selector: aSelector source: aSourceString [
	^ self new
		selector: aSelector;
		source: aSourceString
]

{ #category : #inspecting }
CarpViewDefinition >> gtSourceFor: aView [
	<gtView>
	<return: #GtPhlowView>
	^ aView textEditor
		title: 'Definition';
		aptitude: [ BrGlamorousCodeEditorAptitude ];
		styler: [ CarpParser gtStyler ];
		text: [ self source ]
]

{ #category : #printing }
CarpViewDefinition >> printOn: aStream [
	aStream nextPutAll: 'defview '; nextPutAll: (selector ifNil: [ '?' ])
]

{ #category : #accessing }
CarpViewDefinition >> selector [
	^ selector
]

{ #category : #accessing }
CarpViewDefinition >> selector: aSelector [
	selector := aSelector
]

{ #category : #accessing }
CarpViewDefinition >> source [
	^ source ifNil: [ '' ]
]

{ #category : #accessing }
CarpViewDefinition >> source: aSourceString [
	source := aSourceString
]
