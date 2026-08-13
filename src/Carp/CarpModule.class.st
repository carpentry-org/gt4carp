"
A module of a project: the definitions whose qualified names share a
prefix, wherever they happen to live. Carp modules are open — a file can
hold several, and a module can be spread over several files — so a module
is recovered from the names rather than from the file layout.
"
Class {
	#name : #CarpModule,
	#superclass : #Object,
	#instVars : [
		'name',
		'project',
		'definitions'
	],
	#category : #'Carp-Project'
}

{ #category : #'instance creation' }
CarpModule class >> named: aString in: aProject [
	^ self new
		name: aString;
		project: aProject;
		yourself
]

{ #category : #accessing }
CarpModule >> definitions [
	"The module's members: what it defines, not the module form itself."

	^ definitions
		ifNil: [ definitions := (project definitionsOfModule: self name)
					reject: [ :each | each isModule ] ]
]

{ #category : #accessing }
CarpModule >> definitionsDo: aBlock [
	self definitions do: aBlock
]

{ #category : #accessing }
CarpModule >> displayName [
	^ self name ifEmpty: [ '(top level)' ]
]

{ #category : #accessing }
CarpModule >> files [
	"The files this module is spread over."

	^ (self definitions collect: [ :each | each file ]) asOrderedCollection
		removeDuplicates;
		yourself
]

{ #category : #saving }
CarpModule >> addDefinition: aSourceString [
	"Add a definition to this module, in the file that already holds it. A
	module spread over several files gets it in the last one, which is where
	its most recent definitions live."

	| moduleForm |
	moduleForm := self moduleFormOrNil.
	moduleForm
		ifNil: [ ^ self files
				ifEmpty: [ nil ]
				ifNotEmpty: [ :them | them last addDefinition: aSourceString ] ].
	^ moduleForm file addDefinition: aSourceString toModule: moduleForm
]

{ #category : #accessing }
CarpModule >> moduleFormOrNil [
	"The (defmodule …) form itself, when the project reported one."

	^ self project definitions
		detect: [ :each | each isModule and: [ each name = self name ] ]
		ifNone: [ nil ]
]

{ #category : #accessing }
CarpModule >> gtDefinitionsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Definitions';
		priority: 1;
		items: [ self definitions ];
		column: 'Name' text: [ :each | each shortName ];
		column: 'Kind' text: [ :each | each head ] width: 110;
		column: 'File' text: [ :each | each file basename ] width: 160;
		send: [ :each | each ]
]

{ #category : #accessing }
CarpModule >> name [
	^ name ifNil: [ '' ]
]

{ #category : #accessing }
CarpModule >> name: aString [
	name := aString
]

{ #category : #printing }
CarpModule >> printOn: aStream [
	aStream
		nextPutAll: self displayName;
		nextPutAll: ' (';
		print: self definitions size;
		nextPutAll: ' definitions)'
]

{ #category : #accessing }
CarpModule >> project [
	^ project
]

{ #category : #accessing }
CarpModule >> project: aCarpProject [
	project := aCarpProject
]
