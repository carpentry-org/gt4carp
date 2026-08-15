"
The coder over one definition of a project. It carries everything the
snippet coder has — inline types, diagnostics, documentation on hover,
completion — but bound to the project's session, and it writes back:
saving replaces the definition's bytes in its file and commits the file
into the session.

The file stays the truth. Nothing authoritative lives in the image: saving
writes to disk first, and the session is told about the file afterwards, so
git, disk and session cannot drift apart.
"
Class {
	#name : #GtCarpDefinitionCoderModel,
	#superclass : #GtCarpCoderModel,
	#instVars : [
		'definition'
	],
	#category : #'Carp-Project'
}

{ #category : #'instance creation' }
GtCarpDefinitionCoderModel class >> on: aCarpSourceDefinition [
	^ (self code: aCarpSourceDefinition source)
		definition: aCarpSourceDefinition;
		yourself
]

{ #category : #accessing }
GtCarpDefinitionCoderModel >> acceptSource: aSourceString [
	"Write the definition back and commit its file into the session."

	self definition save: aSourceString
]

{ #category : #converting }
GtCarpDefinitionCoderModel >> asCoderViewModel [
	^ GtCarpDefinitionCoderViewModel new coder: self
]

{ #category : #accessing }
GtCarpDefinitionCoderModel >> definition [
	^ definition
]

{ #category : #accessing }
GtCarpDefinitionCoderModel >> definition: aCarpSourceDefinition [
	definition := aCarpSourceDefinition.
	self sessionId: aCarpSourceDefinition project sessionId
]

{ #category : #evaluation }
GtCarpDefinitionCoderModel >> callSource [
	"The definition followed by a call to it: an example is a definition
	written to be run, and running it means asking what it answers."

	^ self currentSourceString trimBoth , String lf , '(' , definition name , ')'
]

{ #category : #evaluation }
GtCarpDefinitionCoderModel >> isRunnable [
	"An example with nothing to pass it. What the session inferred decides:
	an example is nullary by convention, and one that is not has no call we
	could write for it."

	| type |
	definition ifNil: [ ^ false ].
	definition isExample ifFalse: [ ^ false ].
	type := definition project inferredTypeOf: definition name.
	^ type isNil or: [ type beginsWith: '(Fn []' ]
]

{ #category : #evaluation }
GtCarpDefinitionCoderModel >> runInto: anElement [
	"Run the example and open what it answered. A run is a compile and a run,
	so it happens off the UI process, and what lands in the pane is the value
	itself — live, with the views its own project declares — rather than a
	report about it."

	| source |
	source := self callSource.
	[ | answer |
	answer := [ (CarpServerClient default evalSource: source session: self sessionId)
			preferredInspectable ]
			on: Error
			do: [ :e | e messageText ifNil: [ e class name ] ].
	anElement
		enqueueTask: (BlTaskAction new action: [ anElement phlow spawnObject: answer ]) ]
		forkNamed: 'carp-run-example'
]

{ #category : #accessing }
GtCarpDefinitionCoderModel >> initializeAddOns: addOns [
	super initializeAddOns: addOns.

	addOns
		addMainAction: 'Save' translated
		icon: BrGlamorousVectorIcons accept
		action: [ :aCoderUIModel :anElement |
			[ aCoderUIModel requestSave ]
				on: Error
				do: [ :e | anElement phlow spawnObject: (e messageText ifNil: [ e class name ]) ] ]
		id: #'source-coder--carp-save-action-id'.

	"Evaluating a definition defines it, which is all a `defn` does and all
	the generic action can do while answering at once. An example is written
	to be run, so it gets an action that runs it."
	self isRunnable
		ifTrue: [ addOns
				addMainAction: 'Run' translated
				icon: BrGlamorousVectorIcons playinspect
				action: [ :aCoderUIModel :anElement | self runInto: anElement ]
				id: #'source-coder--carp-run-action-id' ]
]

{ #category : #accessing }
GtCarpDefinitionCoderModel >> initializeShortcuts: addOns [
	super initializeShortcuts: addOns.

	addOns addShortcut: GtSourceCoderSaveShortcut new
]
