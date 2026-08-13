"
A stand-in for {{gtClass:name=CarpServerClient}} that answers pre-recorded
expansions, so {{gtClass:name=CarpMacroExpansion}} can be stepped with no
server running.

Recorded per form rather than as a sequence: a step tries the whole form
first and then each subform, so what gets asked for depends on the walk.
"
Class {
	#name : #CarpMacroExpansionStub,
	#superclass : #Object,
	#instVars : [
		'expansions',
		'fullExpansion'
	],
	#category : #'Carp-Tools'
}

{ #category : #'instance creation' }
CarpMacroExpansionStub class >> expanding: aDictionary [
	^ self new expansions: aDictionary; yourself
]

{ #category : #accessing }
CarpMacroExpansionStub >> expandSource: aFormString session: aSessionString once: aBoolean [
	| expanded |
	aBoolean
		ifFalse: [ ^ Dictionary new
				at: 'expansion' put: (fullExpansion ifNil: [ aFormString ]);
				at: 'changed' put: fullExpansion notNil;
				yourself ].
	expanded := self expansions at: aFormString ifAbsent: [ nil ].
	^ Dictionary new
		at: 'expansion' put: (expanded ifNil: [ aFormString ]);
		at: 'changed' put: expanded notNil;
		yourself
]

{ #category : #accessing }
CarpMacroExpansionStub >> expansions [
	^ expansions ifNil: [ expansions := Dictionary new ]
]

{ #category : #accessing }
CarpMacroExpansionStub >> expansions: aDictionary [
	expansions := aDictionary
]

{ #category : #accessing }
CarpMacroExpansionStub >> fullExpansion: aString [
	fullExpansion := aString
]
