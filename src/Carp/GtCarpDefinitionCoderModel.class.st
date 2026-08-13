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
		id: #'source-coder--carp-save-action-id'
]

{ #category : #accessing }
GtCarpDefinitionCoderModel >> initializeShortcuts: addOns [
	super initializeShortcuts: addOns.

	addOns addShortcut: GtSourceCoderSaveShortcut new
]
