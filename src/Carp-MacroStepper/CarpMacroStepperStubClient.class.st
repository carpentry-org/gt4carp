"
A stand-in for CarpLLClient that returns a pre-recorded sequence of
expansion results. Useful for offline testing of the view model and UI
without a running languagelink server.
"
Class {
	#name : #CarpMacroStepperStubClient,
	#superclass : #Object,
	#instVars : [
		'sequence',
		'cursor'
	],
	#category : #'Carp-MacroStepper'
}

{ #category : #'instance creation' }
CarpMacroStepperStubClient class >> sequence: aCollection [
	^ self new sequence: aCollection; yourself
]

{ #category : #commands }
CarpMacroStepperStubClient >> expand1: aFormString [
	| next |
	cursor >= sequence size ifTrue: [ ^ aFormString ].
	cursor := cursor + 1.
	next := sequence at: cursor.
	^ next
]

{ #category : #initialization }
CarpMacroStepperStubClient >> initialize [
	super initialize.
	cursor := 0.
	sequence := #()
]

{ #category : #accessing }
CarpMacroStepperStubClient >> sequence: aCollection [
	sequence := aCollection asArray.
	cursor := 0
]
