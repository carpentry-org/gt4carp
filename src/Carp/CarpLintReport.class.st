"
angler's findings for one snippet, ready for inspection.
"
Class {
	#name : #CarpLintReport,
	#superclass : #Object,
	#instVars : [
		'findings'
	],
	#category : #'Carp-Tools'
}

{ #category : #'instance creation' }
CarpLintReport class >> onSource: aSourceString [
	^ self new
		findings: (CarpExternalTool lint: aSourceString);
		yourself
]

{ #category : #accessing }
CarpLintReport >> findings [
	^ findings ifNil: [ #() ]
]

{ #category : #accessing }
CarpLintReport >> findings: aCollection [
	findings := aCollection
]

{ #category : #accessing }
CarpLintReport >> gtFindingsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Findings';
		priority: 1;
		items: [ self findings ];
		column: 'Where'
			text: [ :each | each line printString , ':' , each column printString ]
			width: 60;
		column: 'Rule' text: [ :each | each rule ] width: 160;
		column: 'Message' text: [ :each | each message ];
		send: [ :each | each ]
]

{ #category : #printing }
CarpLintReport >> printOn: aStream [
	self findings
		ifEmpty: [ aStream nextPutAll: 'angler: clean' ]
		ifNotEmpty: [ :them |
			aStream
				nextPutAll: 'angler: ';
				print: them size;
				nextPutAll: (' finding' , (them size = 1 ifTrue: [ '' ] ifFalse: [ 's' ])) ]
]
