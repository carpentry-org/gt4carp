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
		'announcer'
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
	^ selectedModule
		ifNil: [ #() ]
		ifNotNil: [ :aModule | aModule definitions ]
]

{ #category : #accessing }
CarpBrowserModel >> modules [
	^ project ifNil: [ #() ] ifNotNil: [ :aProject | aProject modules ]
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
