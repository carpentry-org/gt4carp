"
Class-side examples for fast iteration on the macro stepper. Requires the
Carp languagelink server to be running locally on port 8765.

In a Playground, evaluate:
	CarpMacroStepperExamples openOn: '(or (when true 1) (or false true))'.

To unit-test the view model without a server, use a stub:
	CarpMacroStepperExamples viewModelTest.
"
Class {
	#name : #CarpMacroStepperExamples,
	#superclass : #Object,
	#category : #'Carp-MacroStepper'
}

{ #category : #examples }
CarpMacroStepperExamples class >> defaultClient [
	^ CarpLLClient host: '127.0.0.1' port: 8765
]

{ #category : #examples }
CarpMacroStepperExamples class >> openOn: aFormString [
	"Open a stepper window on the given source. The languagelink server
	must be running on 127.0.0.1:8765."
	| viewModel element |
	viewModel := CarpMacroExpansionViewModel
		source: aFormString
		client: self defaultClient.
	element := CarpMacroExpansionElement onViewModel: viewModel.
	^ element openInSpace
]

{ #category : #examples }
CarpMacroStepperExamples class >> openOnWhenOrSample [
	^ self openOn: '(or (when true 1) (or false true))'
]

{ #category : #examples }
CarpMacroStepperExamples class >> viewModelTest [
	"Smoke-test the view model with a stub client returning a fixed sequence."
	| stub viewModel |
	stub := CarpMacroStepperStubClient sequence: #(
		'(if true (or a b) ())'
		'(if true (if a true b) ())'
		'(if true (if a true b) ())').
	viewModel := CarpMacroExpansionViewModel
		source: '(when true (or a b))'
		client: stub.
	viewModel runToFixpoint.
	^ viewModel steps
]
