"
The IDE surface: modules on the left, their definitions beside them, and
the selected definition's coder filling the rest. Columns talk to the
{{gtClass:name=CarpBrowserModel}} rather than to each other, so a selection
anywhere updates the rest.

The coder is the same one the rest of the tooling uses: inferred types
inline, diagnostics underlined, documentation on hover, completion against
the whole project, and saving writes the definition back to its file. Until
the project's session is loaded there is nothing to check against, so the
pane says so and offers to load it.
"
Class {
	#name : #CarpBrowserElement,
	#superclass : #BlElement,
	#traits : 'TBrLayoutResizable',
	#classTraits : 'TBrLayoutResizable classTrait',
	#instVars : [
		'browserModel',
		'moduleList',
		'definitionList',
		'coderPane'
	],
	#category : #'Carp-Browser'
}

{ #category : #'instance creation' }
CarpBrowserElement class >> onProject: aCarpProject [
	^ self new browserModel: (CarpBrowserModel onProject: aCarpProject); yourself
]

{ #category : #accessing }
CarpBrowserElement >> browserModel [
	^ browserModel
]

{ #category : #accessing }
CarpBrowserElement >> browserModel: aBrowserModel [
	browserModel := aBrowserModel.
	browserModel announcer
		when: CarpBrowserProjectChanged
		do: [ :announcement | self onProjectChanged ]
		for: self.
	browserModel announcer
		when: CarpBrowserModuleSelected
		do: [ :announcement | self onModuleSelected ]
		for: self.
	browserModel announcer
		when: CarpBrowserDefinitionSelected
		do: [ :announcement | self onDefinitionSelected ]
		for: self.
	self onProjectChanged
]

{ #category : #initialization }
CarpBrowserElement >> initialize [
	super initialize.
	self layout: BlLinearLayout horizontal.
	self matchParent.
	moduleList := self newListWithLabel: [ :each | each displayName ].
	moduleList
		when: BrSelectionChanged
		do: [ :anEvent |
			anEvent selectedDo: [ :anInterval |
				browserModel selectedModule: (moduleList viewModel itemAt: anInterval first) ] ].
	definitionList := self newListWithLabel: [ :each | each shortName ].
	definitionList
		when: BrSelectionChanged
		do: [ :anEvent |
			anEvent selectedDo: [ :anInterval |
				browserModel selectedDefinition: (definitionList viewModel itemAt: anInterval first) ] ].
	coderPane := BlElement new
			layout: BlLinearLayout vertical;
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical matchParent ].
	self
		addChild: (moduleList constraintsDo: [ :c | c linear weight: 0.8 ]);
		addChild: (definitionList constraintsDo: [ :c | c linear weight: 0.8 ]);
		addChild: (coderPane constraintsDo: [ :c | c linear weight: 2.4 ])
]

{ #category : #initialization }
CarpBrowserElement >> newListWithLabel: aBlock [
	^ BrSimpleList new
		matchParent;
		itemStencil: [ BrLabel new
				aptitude: BrGlamorousLabelAptitude + BrGlamorousListItemAptitude;
				padding: (BlInsets top: 2 left: 8 bottom: 2 right: 8);
				hMatchParent ];
		itemDataBinder: [ :aLabel :each | aLabel text: (aBlock value: each) ];
		items: #();
		yourself
]

{ #category : #updating }
CarpBrowserElement >> onProjectChanged [
	moduleList items: browserModel modules.
	definitionList items: browserModel definitions.
	self updateCoderPane
]

{ #category : #updating }
CarpBrowserElement >> onModuleSelected [
	definitionList items: browserModel definitions.
	self updateCoderPane
]

{ #category : #updating }
CarpBrowserElement >> onDefinitionSelected [
	self updateCoderPane
]

{ #category : #updating }
CarpBrowserElement >> updateCoderPane [
	coderPane removeChildren.
	browserModel selectedDefinition
		ifNil: [ ^ coderPane addChild: self newPlaceholder ].
	coderPane addChild: self newHeader.
	coderPane
		addChild: ((browserModel project isSessionLoaded
				ifTrue: [ browserModel selectedDefinition newCoder asCoderViewModel asElement ]
				ifFalse: [ BrEditor new
						aptitude: BrGlamorousCodeEditorAptitude new;
						styler: CarpParser gtStyler;
						beReadOnlyWithSelection;
						padding: (BlInsets all: 8);
						text: browserModel selectedDefinition source ])
				constraintsDo: [ :c |
					c horizontal matchParent.
					c vertical matchParent ])
]

{ #category : #updating }
CarpBrowserElement >> newHeader [
	"What you are looking at and where it lives."

	| definition |
	definition := browserModel selectedDefinition.
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		alignCenterLeft;
		padding: (BlInsets top: 6 left: 8 bottom: 6 right: 8);
		cellSpacing: 8;
		addChild: (BrLabel new
				aptitude: BrGlamorousLabelAptitude;
				text: definition name asRopedText glamorousCodeFont);
		addChild: (BrLabel new
				aptitude: (BrGlamorousLabelAptitude new foreground: BrGlamorousColors disabledButtonTextColor);
				text: definition head , ' · ' , definition file basename);
		yourself
]

{ #category : #updating }
CarpBrowserElement >> newPlaceholder [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: BrGlamorousColors disabledButtonTextColor);
		padding: (BlInsets all: 10);
		text: (browserModel project isSessionLoaded
				ifTrue: [ 'Select a definition' ]
				ifFalse: [ 'Select a definition. Load the project into a session to type and check it.' ])
]
