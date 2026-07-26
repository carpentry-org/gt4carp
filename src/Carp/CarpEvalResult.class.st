"
I am the result of evaluating a notebook cell against the carp server.

I hold the cell's source, the session it ran in, the exit code, the echoed
value of the cell's last expression, and the captured stdout and stderr.
My default view is the value; program output and diagnostics have their own
views, shown only when present.
"
Class {
	#name : #CarpEvalResult,
	#superclass : #Object,
	#instVars : [
		'source',
		'session',
		'exitCode',
		'value',
		'stdout',
		'stderr',
		'valueProxy'
	],
	#category : #'Carp-Execution'
}

{ #category : #accessing }
CarpEvalResult >> exitCode [
	^ exitCode
]

{ #category : #accessing }
CarpEvalResult >> exitCode: anInteger [
	exitCode := anInteger
]

{ #category : #accessing }
CarpEvalResult >> gtDiagnosticsFor: aView [
	<gtView>
	stderr ifEmpty: [ ^ aView empty ].
	^ aView textEditor
		title: 'Diagnostics';
		priority: (self isSuccess ifTrue: [ 4 ] ifFalse: [ 1 ]);
		text: [ stderr asRopedText glamorousCodeFont
				foreground: BrGlamorousColors errorBackgroundColor twiceDarker ]
]

{ #category : #accessing }
CarpEvalResult >> gtOutputFor: aView [
	<gtView>
	stdout ifEmpty: [ ^ aView empty ].
	^ aView textEditor
		title: 'Output';
		priority: 2;
		text: [ stdout asRopedText glamorousCodeFont ]
]

{ #category : #accessing }
CarpEvalResult >> gtSourceFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Source';
		priority: 5;
		text: [ source asRopedText glamorousCodeFont ]
]

{ #category : #accessing }
CarpEvalResult >> gtValueFor: aView [
	<gtView>
	(self isSuccess and: [ value notEmpty ]) ifFalse: [ ^ aView empty ].
	^ aView textEditor
		title: 'Value';
		priority: 1;
		text: [ value asRopedText glamorousCodeFont fontSize: 14 ]
]

{ #category : #testing }
CarpEvalResult >> isSuccess [
	^ exitCode = 0
]

{ #category : #printing }
CarpEvalResult >> printOn: aStream [
	self isSuccess
		ifTrue: [ aStream
				nextPutAll: (value notEmpty
						ifTrue: [ value ]
						ifFalse: [ stdout trimBoth
								ifEmpty: [ 'ok' ]
								ifNotEmpty: [ :trimmed | trimmed lines last ] ]) ]
		ifFalse: [ aStream
				nextPutAll: 'error: ';
				nextPutAll: (stderr trimBoth lines
						ifEmpty: [ 'exit ' , exitCode printString ]
						ifNotEmpty: [ :diagnosticLines | diagnosticLines first ]) ]
]

{ #category : #accessing }
CarpEvalResult >> session [
	^ session
]

{ #category : #accessing }
CarpEvalResult >> session: aString [
	session := aString
]

{ #category : #accessing }
CarpEvalResult >> source [
	^ source
]

{ #category : #accessing }
CarpEvalResult >> source: aString [
	source := aString
]

{ #category : #accessing }
CarpEvalResult >> stderr [
	^ stderr
]

{ #category : #accessing }
CarpEvalResult >> stderr: aString [
	stderr := aString
]

{ #category : #accessing }
CarpEvalResult >> stdout [
	^ stdout
]

{ #category : #accessing }
CarpEvalResult >> stdout: aString [
	stdout := aString
]

{ #category : #accessing }
CarpEvalResult >> preferredInspectable [
	"The object a snippet evaluation should answer: the live value proxy
	when the cell produced one, otherwise the result itself."

	^ valueProxy ifNil: [ self ]
]

{ #category : #accessing }
CarpEvalResult >> value [
	^ value
]

{ #category : #accessing }
CarpEvalResult >> value: aString [
	value := aString
]

{ #category : #accessing }
CarpEvalResult >> valueProxy [
	^ valueProxy
]

{ #category : #accessing }
CarpEvalResult >> valueProxy: aCarpValueProxy [
	valueProxy := aCarpValueProxy
]
