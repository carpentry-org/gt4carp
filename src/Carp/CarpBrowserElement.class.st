"
The IDE surface: a toolbar carrying the project's lifecycle, modules and
their definitions in titled columns, and the selected definition's coder
filling the rest. Columns talk to the {{gtClass:name=CarpBrowserModel}}
rather than to each other, so a selection anywhere updates the rest.

The coder is the same one the rest of the tooling uses: inferred types
inline, diagnostics underlined, documentation on hover, completion against
the whole project, and saving writes the definition back to its file. Until
the project's session is loaded there is nothing to check against, so the
toolbar says so and offers to load it.
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
		'coderPane',
		'statusLabel',
		'nameLabel',
		'sessionButton'
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
	browserModel project
		ifNotNil: [ :aProject |
			aProject announcer
				when: CarpProjectChanged
				do: [ :announcement | self updateStatus ]
				for: self ].
	self onProjectChanged
]

{ #category : #initialization }
CarpBrowserElement >> initialize [
	super initialize.
	self layout: BlLinearLayout vertical.
	self matchParent.
	self background: BrGlamorousColors neutralBackgroundColor.
	moduleList := self newListLabelled: [ :each | each displayName ].
	moduleList
		when: BrSelectionChanged
		do: [ :anEvent |
			anEvent selectedDo: [ :anInterval |
				browserModel selectedModule: (moduleList viewModel itemAt: anInterval first) ] ].
	definitionList := self newListLabelled: [ :each | each shortName ].
	definitionList
		when: BrSelectionChanged
		do: [ :anEvent |
			anEvent selectedDo: [ :anInterval |
				browserModel selectedDefinition: (definitionList viewModel itemAt: anInterval first) ] ].
	coderPane := BlElement new
			layout: BlLinearLayout vertical;
			background: Color white;
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical matchParent ].
	self addChild: self newToolbar.
	self addChild: self newBody
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newBody [
	| body |
	body := BrHorizontalPane new
			matchParent;
			yourself.
	body
		addChild: ((self newColumn: 'Modules' containing: moduleList)
				constraintsDo: [ :c | c linear weight: 0.9 ]);
		addChild: ((self newColumn: 'Definitions' containing: definitionList)
				constraintsDo: [ :c | c linear weight: 1 ]);
		addChild: (coderPane constraintsDo: [ :c | c linear weight: 2.6 ]).
	^ body
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newColumn: aTitle containing: aList [
	"A titled column, separated from its neighbour by a hairline."

	^ BlElement new
		layout: BlLinearLayout vertical;
		background: BrGlamorousColors neutralBackgroundColor;
		border: (BlBorder paint: BrGlamorousColors lightBorderColor width: 1);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		addChild: (self newColumnHeader: aTitle);
		addChild: aList;
		yourself
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newColumnHeader: aTitle [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				foreground: BrGlamorousColors disabledHeaderTextColor;
				bold);
		background: BrGlamorousColors secondaryHeaderBackgroundColor;
		padding: (BlInsets top: 5 left: 10 bottom: 5 right: 10);
		hMatchParent;
		text: aTitle asUppercase;
		yourself
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newListLabelled: aBlock [
	^ BrSimpleList new
		matchParent;
		background: Color white;
		itemStencil: [ BrLabel new
				aptitude: BrGlamorousLabelAptitude + BrGlamorousListItemAptitude;
				padding: (BlInsets top: 4 left: 10 bottom: 4 right: 10);
				hMatchParent ];
		itemDataBinder: [ :aLabel :each | aLabel text: (aBlock value: each) ];
		items: #();
		yourself
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newToolbar [
	"The project's lifecycle: what it is, whether the compiler knows about
	it, and the things you do to the whole of it."

	| toolbar |
	statusLabel := BrLabel new
			aptitude: (BrGlamorousLabelAptitude new foreground: BrGlamorousColors disabledButtonTextColor);
			text: ''.
	toolbar := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			alignCenterLeft;
			background: BrGlamorousColors defaultHeaderBackgroundColor;
			border: (BlBorder paint: BrGlamorousColors lightBorderColor width: 1);
			padding: (BlInsets top: 6 left: 10 bottom: 6 right: 10);
			cellSpacing: 10.
	nameLabel := BrLabel new
			aptitude: (BrGlamorousLabelAptitude new bold);
			text: ''.
	toolbar
		addChild: nameLabel;
		addChild: statusLabel;
		addChild: (BrFrame new hMatchParent vFitContent);
		addChild: (sessionButton := self
				newToolbarButton: 'Load session'
				icon: BrGlamorousVectorIcons load
				action: [ browserModel project loadSessionInBackground ]);
		addChild: (self
				newToolbarButton: 'Reload'
				icon: BrGlamorousVectorIcons refresh
				action: [ browserModel reload ]);
		addChild: (self
				newToolbarButton: 'Problems'
				icon: BrGlamorousVectorIcons repair
				action: [ :aButton | aButton phlow spawnObject: browserModel project problems ]);
		addChild: (self
				newToolbarButton: 'Playground'
				icon: BrGlamorousVectorIcons playinspect
				action: [ :aButton | aButton phlow spawnObject: browserModel project newPlaygroundCoder ]).
	^ toolbar
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newToolbarButton: aLabel icon: anIcon action: aBlock [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconAndLabelAptitude;
		icon: anIcon;
		label: aLabel;
		action: [ :aButton | aBlock cull: aButton ];
		yourself
]

{ #category : #actions }
CarpBrowserElement >> addDefinitionToSelectedModule [
	"Add a definition to the module in view and select it, so you land in
	the coder ready to write it."

	| module |
	module := browserModel selectedModule ifNil: [ ^ self ].
	module addDefinition: '(defn unnamed [] ())'.
	browserModel reload.
	browserModel selectedModule
		ifNotNil: [ :aModule |
			aModule definitions
				detect: [ :each | each shortName = 'unnamed' ]
				ifFound: [ :each | browserModel selectedDefinition: each ]
				ifNone: [  ] ]
]

{ #category : #actions }
CarpBrowserElement >> deleteSelectedDefinition [
	browserModel selectedDefinition ifNil: [ ^ self ].
	browserModel selectedDefinition delete.
	browserModel selectedDefinition: nil.
	browserModel reload
]

{ #category : #updating }
CarpBrowserElement >> onDefinitionSelected [
	self
		select: browserModel selectedDefinition
		in: definitionList
		among: browserModel definitions.
	self updateCoderPane
]

{ #category : #updating }
CarpBrowserElement >> onModuleSelected [
	definitionList items: browserModel definitions.
	self select: browserModel selectedModule in: moduleList among: browserModel modules.
	self updateCoderPane
]

{ #category : #updating }
CarpBrowserElement >> select: anObject in: aList among: aCollection [
	"Keep a list's own selection in step with the model, so selecting from
	anywhere — a click, a reload, a spawned action — looks the same."

	| index |
	anObject ifNil: [ ^ aList deselectAll ].
	index := aCollection indexOf: anObject ifAbsent: [ 0 ].
	index = 0
		ifTrue: [ aList deselectAll ]
		ifFalse: [ aList selectOne: index ]
]

{ #category : #updating }
CarpBrowserElement >> onProjectChanged [
	moduleList items: browserModel modules.
	definitionList items: browserModel definitions.
	self select: browserModel selectedModule in: moduleList among: browserModel modules.
	self
		select: browserModel selectedDefinition
		in: definitionList
		among: browserModel definitions.
	self updateStatus.
	self updateCoderPane
]

{ #category : #updating }
CarpBrowserElement >> updateStatus [
	| project |
	statusLabel ifNil: [ ^ self ].
	project := browserModel project.
	nameLabel text: project rootName.
	sessionButton
		ifNotNil: [ sessionButton
				label: (project sessionState = #loaded
						ifTrue: [ 'Session loaded' ]
						ifFalse: [ project sessionState = #loading
								ifTrue: [ 'Loading…' ]
								ifFalse: [ 'Load session' ] ]).
			project isSessionLoaded
				ifTrue: [ sessionButton disable ]
				ifFalse: [ sessionButton enable ] ].
	statusLabel
		text: (String
				streamContents: [ :aStream |
					aStream
						print: project modules size;
						nextPutAll: ' modules · ';
						print: (project definitions reject: [ :each | each isModule ]) size;
						nextPutAll: ' definitions · '.
					aStream
						nextPutAll: (project sessionState = #loaded
								ifTrue: [ 'session loaded' ]
								ifFalse: [ project sessionState = #loading
										ifTrue: [ 'loading session…' ]
										ifFalse: [ 'no session' ] ]) ])
]

{ #category : #updating }
CarpBrowserElement >> updateCoderPane [
	"The module's definitions, one row each, the selected one opened in its
	coder — a module reads as a whole the way a class does, and you can move
	through it without going back to the list."

	| content |
	coderPane removeChildren.
	browserModel selectedModule
		ifNil: [ ^ coderPane addChild: self newPlaceholder ].
	content := BlElement new
			layout: BlLinearLayout vertical;
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical fitContent ].
	browserModel definitions
		do: [ :each | content addChild: (self newRowFor: each) ].
	coderPane
		addChild: (BlScrollableElement new
				addChild: content;
				constraintsDo: [ :c |
					c horizontal matchParent.
					c vertical matchParent ];
				yourself)
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newRowFor: aDefinition [
	"One definition: its header always, its coder when it is the selected
	one. Building every coder up front would mean compiling a hundred
	editors to look at one."

	| row |
	row := BlElement new
			layout: BlLinearLayout vertical;
			background: Color white;
			border: (BlBorder paint: BrGlamorousColors lightBorderColor width: 1);
			margin: (BlInsets top: 0 left: 0 bottom: 6 right: 0);
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical fitContent ].
	row addChild: (self newHeaderFor: aDefinition).
	aDefinition == browserModel selectedDefinition
		ifTrue: [ row
				addChild: ((browserModel project isSessionLoaded
						ifTrue: [ (aDefinition newCoder asCoderViewModel expanded: true) asExpandedOnlyElement ]
						ifFalse: [ BrEditor new
								aptitude: BrGlamorousCodeEditorAptitude new;
								styler: CarpParser gtStyler;
								beReadOnlyWithSelection;
								padding: (BlInsets all: 10);
								text: aDefinition source ])
						constraintsDo: [ :c |
							c horizontal matchParent.
							c vertical fitContent ]) ].
	^ row
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newHeaderFor: aDefinition [
	"The definition's line: its name, what defines it, and — when it is
	open — what you can do to it."

	| header |
	header := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			alignCenterLeft;
			background: (aDefinition == browserModel selectedDefinition
					ifTrue: [ BrGlamorousColors secondaryHeaderBackgroundColor ]
					ifFalse: [ Color white ]);
			padding: (BlInsets top: 5 left: 12 bottom: 5 right: 8);
			cellSpacing: 10;
			when: BlClickEvent do: [ :anEvent | browserModel selectedDefinition: aDefinition ];
			yourself.
	header
		addChild: (BrLabel new
				aptitude: BrGlamorousLabelAptitude;
				text: aDefinition shortName asRopedText glamorousCodeFont);
		addChild: (BrLabel new
				aptitude: (BrGlamorousLabelAptitude new foreground: BrGlamorousColors disabledButtonTextColor);
				text: aDefinition head).
	aDefinition documentation
		ifNotEmpty: [ :aDoc |
			header
				addChild: (BrLabel new
						aptitude: (BrGlamorousLabelAptitude new foreground: BrGlamorousColors disabledButtonTextColor);
						text: (aDoc lines ifEmpty: [ '' ] ifNotEmpty: [ :them | them first ])) ].
	aDefinition == browserModel selectedDefinition
		ifTrue: [ header
				addChild: (BrFrame new hMatchParent vFitContent);
				addChild: (BrButton new
						aptitude: BrGlamorousButtonWithIconAptitude;
						icon: BrGlamorousVectorIcons add;
						label: 'Add a definition to this module';
						action: [ self addDefinitionToSelectedModule ]);
				addChild: (BrButton new
						aptitude: BrGlamorousButtonWithIconAptitude;
						icon: BrGlamorousVectorIcons trash;
						label: 'Delete this definition';
						action: [ self deleteSelectedDefinition ]) ].
	^ header
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newPlaceholder [
	^ BlElement new
		layout: BlLinearLayout vertical alignCenter;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		addChild: (BrLabel new
				aptitude: (BrGlamorousLabelAptitude new foreground: BrGlamorousColors disabledButtonTextColor);
				padding: (BlInsets all: 12);
				text: (browserModel project isSessionLoaded
						ifTrue: [ 'Select a definition' ]
						ifFalse: [ 'Select a definition · load the project into a session to type and check it' ]));
		yourself
]
