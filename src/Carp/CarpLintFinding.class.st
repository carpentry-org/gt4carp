"
One angler finding: a rule that matched at a source position, with the
offending form.
"
Class {
	#name : #CarpLintFinding,
	#superclass : #Object,
	#instVars : [
		'line',
		'column',
		'rule',
		'message',
		'form'
	],
	#category : #'Carp-Tools'
}

{ #category : #accessing }
CarpLintFinding >> column [
	^ column
]

{ #category : #accessing }
CarpLintFinding >> column: aNumber [
	column := aNumber
]

{ #category : #accessing }
CarpLintFinding >> form [
	^ form ifNil: [ '' ]
]

{ #category : #accessing }
CarpLintFinding >> form: aString [
	form := aString
]

{ #category : #accessing }
CarpLintFinding >> gtFormFor: aView [
	<gtView>
	self form ifEmpty: [ ^ aView empty ].
	^ aView textEditor
		title: 'Form';
		priority: 1;
		aptitude: [ BrGlamorousCodeEditorAptitude ];
		styler: [ CarpParser gtStyler ];
		text: [ self form ]
]

{ #category : #accessing }
CarpLintFinding >> line [
	^ line
]

{ #category : #accessing }
CarpLintFinding >> line: aNumber [
	line := aNumber
]

{ #category : #accessing }
CarpLintFinding >> message [
	^ message ifNil: [ '' ]
]

{ #category : #accessing }
CarpLintFinding >> message: aString [
	message := aString
]

{ #category : #printing }
CarpLintFinding >> printOn: aStream [
	aStream
		nextPutAll: '['; nextPutAll: self rule; nextPutAll: '] ';
		print: line; nextPut: $:; print: column;
		nextPutAll: ' '; nextPutAll: self message
]

{ #category : #accessing }
CarpLintFinding >> rule [
	^ rule ifNil: [ '' ]
]

{ #category : #accessing }
CarpLintFinding >> rule: aString [
	rule := aString
]
