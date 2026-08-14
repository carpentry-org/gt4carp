"
What the browser is looking at: a project, the module selected in it, and
the definition selected in that module. The columns and the coder pane
subscribe to me rather than to each other, so selecting in one place
updates everything else — the same shape GtCoderNavigationModel has for
Pharo.
"
Class {
	#name : #CarpBrowserModel,
	#superclass : #Object,
	#instVars : [
		'project',
		'selectedModule',
		'selectedDefinition',
		'announcer',
		'filter'
	],
	#category : #'Carp-Browser'
}

{ #category : #'instance creation' }
CarpBrowserModel class >> onProject: aCarpProject [
	^ self new project: aCarpProject; yourself
]

{ #category : #accessing }
CarpBrowserModel >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
CarpBrowserModel >> definitions [
	"The selected module's definitions, narrowed to the ones the filter
	matches — unless the module itself is what matched, in which case you
	asked for the module and get all of it."

	^ selectedModule
		ifNil: [ #() ]
		ifNotNil: [ :aModule |
			(self filter isEmpty or: [ self matches: aModule displayName ])
				ifTrue: [ aModule definitions ]
				ifFalse: [ aModule definitions select: [ :each | self matches: each shortName ] ] ]
]

{ #category : #accessing }
CarpBrowserModel >> filter [
	^ filter ifNil: [ filter := '' ]
]

{ #category : #accessing }
CarpBrowserModel >> filter: aString [
	"Narrow what the browser shows to what the text matches, by module name
	or by definition name."

	self filter = aString ifTrue: [ ^ self ].
	filter := aString.
	self announce: CarpBrowserFilterChanged new
]

{ #category : #private }
CarpBrowserModel >> matches: aString [
	^ aString asLowercase includesSubstring: self filter asLowercase
]

{ #category : #accessing }
CarpBrowserModel >> modules [
	"Every module, or — when there is a filter — the ones it names and the
	ones holding a definition it names."

	| modules |
	modules := project ifNil: [ #() ] ifNotNil: [ :aProject | aProject modules ].
	self filter isEmpty ifTrue: [ ^ modules ].
	^ modules
		select: [ :aModule |
			(self matches: aModule displayName)
				or: [ aModule definitions anySatisfy: [ :each | self matches: each shortName ] ] ]
]

{ #category : #accessing }
CarpBrowserModel >> project [
	^ project
]

{ #category : #accessing }
CarpBrowserModel >> project: aCarpProject [
	project := aCarpProject.
	selectedModule := nil.
	selectedDefinition := nil.
	self announce: CarpBrowserProjectChanged new
]

{ #category : #announcing }
CarpBrowserModel >> announce: anAnnouncement [
	self announcer announce: anAnnouncement
]

{ #category : #accessing }
CarpBrowserModel >> selectedDefinition [
	^ selectedDefinition
]

{ #category : #accessing }
CarpBrowserModel >> selectedDefinition: aDefinition [
	selectedDefinition == aDefinition ifTrue: [ ^ self ].
	selectedDefinition := aDefinition.
	self announce: CarpBrowserDefinitionSelected new
]

{ #category : #accessing }
CarpBrowserModel >> showDefinition: aDefinition [
	"Land on a definition wherever it lives, for when something outside the
	columns — a problem, a reference, another tool — hands us one. A filter
	that would hide it is dropped rather than silently swallowing the jump."

	| module definition |
	aDefinition ifNil: [ ^ self ].
	project ifNil: [ ^ self ].
	module := project moduleNamed: aDefinition moduleName.
	definition := project definitionNamed: aDefinition name.
	(self modules includes: module) ifFalse: [ self filter: '' ].
	self selectedModule: module.
	self selectedDefinition: definition
]

{ #category : #accessing }
CarpBrowserModel >> selectedModule [
	^ selectedModule
]

{ #category : #accessing }
CarpBrowserModel >> selectedModule: aModule [
	selectedModule == aModule ifTrue: [ ^ self ].
	selectedModule := aModule.
	selectedDefinition := nil.
	self announce: CarpBrowserModuleSelected new
]

{ #category : #accessing }
CarpBrowserModel >> reload [
	"Re-read the project and keep looking at the same place, by name: the
	objects are rebuilt, so identity cannot carry the selection."

	| moduleName definitionName |
	project ifNil: [ ^ self ].
	moduleName := selectedModule ifNotNil: [ :each | each name ].
	definitionName := selectedDefinition ifNotNil: [ :each | each name ].
	project reload.
	selectedModule := moduleName ifNotNil: [ :aName | project moduleNamed: aName ].
	selectedDefinition := definitionName ifNotNil: [ :aName | project definitionNamed: aName ].
	self announce: CarpBrowserProjectChanged new
]
