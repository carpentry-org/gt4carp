"
I am a Carp type name as a navigable object: given the typed environment of
an annotation run, I show every function whose signature mentions me —
across the standard library and the session — and my definition when the
session knows it. Each function is again a {{gtClass:name=CarpDefinition}},
so exploration keeps going.
"
Class {
	#name : #CarpTypeReference,
	#superclass : #Object,
	#instVars : [
		'typeName',
		'annotations'
	],
	#category : #'Carp-Execution'
}

{ #category : #accessing }
CarpTypeReference >> annotations [
	^ annotations
]

{ #category : #accessing }
CarpTypeReference >> annotations: aCarpAnnotations [
	annotations := aCarpAnnotations
]

{ #category : #accessing }
CarpTypeReference >> functions [
	annotations ifNil: [ ^ #() ].
	^ annotations environmentDefinitions
		select: [ :each | each mentionsType: typeName ]
]

{ #category : #accessing }
CarpTypeReference >> gtFunctionsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Functions';
		priority: 1;
		items: [ self functions ];
		column: 'Name'
			text: [ :each | each name asRopedText glamorousCodeFont ]
			width: 220;
		column: 'Type'
			text: [ :each | each prettyType asRopedText glamorousCodeFont ];
		send: [ :each | each ]
]

{ #category : #printing }
CarpTypeReference >> printOn: aStream [
	aStream nextPutAll: typeName
]

{ #category : #accessing }
CarpTypeReference >> typeName [
	^ typeName
]

{ #category : #accessing }
CarpTypeReference >> typeName: aString [
	typeName := aString
]
