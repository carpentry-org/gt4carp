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
		'sessionButton',
		'coderHeader',
		'searchField',
		'problemsPane',
		'openRow'
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
	browserModel announcer
		when: CarpBrowserFilterChanged
		do: [ :announcement | self onFilterChanged ]
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
	self background: Color white.
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
	self addChild: self newHorizontalSeparator.
	self addChild: self newBody
]

{ #category : #style }
CarpBrowserElement >> hairline [
	"Separators are a whisper: GT's own tools draw structure with whitespace
	and let a hairline mark where two things meet, rather than boxing every
	pane in a border."

	^ Color black alpha: 0.08
]

{ #category : #style }
CarpBrowserElement >> mutedColor [
	^ BrGlamorousColors disabledButtonTextColor
]

{ #category : #style }
CarpBrowserElement >> secondaryColor [
	^ Color gray
]

{ #category : #style }
CarpBrowserElement >> openRowColor [
	^ Color black alpha: 0.035
]

{ #category : #style }
CarpBrowserElement >> newHorizontalSeparator [
	"Structure comes from whitespace and hairlines. A border would draw on
	all four sides and box the pane back up, so a separator is its own
	one-pixel element."

	^ BlElement new
		background: self hairline;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical exact: 1 ];
		yourself
]

{ #category : #style }
CarpBrowserElement >> newVerticalSeparator [
	^ BlElement new
		background: self hairline;
		constraintsDo: [ :c |
			c horizontal exact: 1.
			c vertical matchParent ];
		yourself
]

{ #category : #style }
CarpBrowserElement >> newEyebrow: aString [
	"The small muted line that says what kind of thing is named below it."

	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				foreground: self mutedColor;
				fontSize: 10);
		text: aString;
		yourself
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
		addChild: self newVerticalSeparator;
		addChild: ((self newColumn: 'Definitions' containing: definitionList)
				constraintsDo: [ :c | c linear weight: 1 ]);
		addChild: self newVerticalSeparator;
		addChild: ((self newColumn: '' containing: coderPane)
				constraintsDo: [ :c | c linear weight: 2.6 ]).
	^ body
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newColumn: aTitle containing: aList [
	"A titled column, separated from its neighbour by a hairline."

	^ BlElement new
		layout: BlLinearLayout vertical;
		background: Color white;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		addChild: (aTitle isEmpty
				ifTrue: [ coderHeader := self newColumnHeader: '' ]
				ifFalse: [ self newColumnHeader: aTitle ]);
		addChild: aList;
		yourself
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newColumnHeader: aTitle [
	"A column says what it holds in the quietest voice that still reads."

	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				foreground: self mutedColor;
				fontSize: 10);
		padding: (BlInsets top: 12 left: 16 bottom: 6 right: 12);
		hMatchParent;
		text: aTitle asUppercase;
		yourself
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newListLabelled: aBlock [
	"Rows sit inside the column rather than spanning it edge to edge, so the
	selection reads as a highlight on a name and not as a bar across a pane."

	^ BrSimpleList new
		matchParent;
		background: Color white;
		itemStencil: [ BrLabel new
				aptitude: (BrGlamorousLabelAptitude new fontSize: 12)
						+ BrGlamorousListItemAptitude;
				geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
				margin: (BlInsets top: 0 left: 8 bottom: 1 right: 8);
				padding: (BlInsets top: 5 left: 8 bottom: 5 right: 8);
				hMatchParent ];
		itemDataBinder: [ :aLabel :each | aLabel text: (aBlock value: each) ];
		items: #();
		yourself
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newToolbar [
	"The project names itself the way GT's own tools do: what kind of thing
	this is, then its name, then the state you would want to know about it —
	with the things you do to the whole project along the same line."

	| header identity |
	nameLabel := BrLabel new
			aptitude: (BrGlamorousLabelAptitude new
					glamorousCodeFont;
					bold;
					fontSize: 16);
			text: ''.
	statusLabel := BrLabel new
			aptitude: (BrGlamorousLabelAptitude new
					foreground: self secondaryColor;
					fontSize: 11);
			text: ''.
	identity := BrVerticalPane new
			vFitContent;
			hFitContent;
			cellSpacing: 2;
			addChild: (self newEyebrow: 'carp project');
			addChild: nameLabel;
			addChild: statusLabel;
			yourself.
	header := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			alignCenterLeft;
			background: Color white;
			padding: (BlInsets top: 14 left: 16 bottom: 14 right: 16);
			cellSpacing: 8.
	header
		addChild: identity;
		addChild: (BrFrame new hMatchParent vFitContent);
		addChild: self newSearchField;
		addChild: (sessionButton := self
				newToolbarButton: 'Load session'
				icon: BrGlamorousVectorIcons load
				action: [ browserModel project loadSessionInBackground ]);
		addChild: (self
				newToolbarButton: 'Reload'
				icon: BrGlamorousVectorIcons refresh
				action: [ browserModel reload ]);
		addChild: (self
				newToolbarButton: 'Changes'
				icon: BrGlamorousVectorIcons changes
				action: [ :aButton | aButton phlow spawnObject: browserModel project ]);
		addChild: (self
				newToolbarButton: 'Problems'
				icon: BrGlamorousVectorIcons repair
				action: [ self toggleProblems ]);
		addChild: (self
				newToolbarButton: 'Playground'
				icon: BrGlamorousVectorIcons playinspect
				action: [ :aButton | aButton phlow spawnObject: browserModel project newPlaygroundCoder ]).
	^ header
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newSearchField [
	"Type a name: the modules narrow to the ones that hold it, and their
	definitions to the ones that are it."

	| field |
	searchField := BrEditor new
			aptitude: (BrGlamorousRegularEditorAptitude new fontSize: 12);
			hMatchParent;
			vFitContent;
			text: '';
			yourself.
	searchField editor
		when: BrTextEditorModifiedEvent
		do: [ :anEvent | browserModel filter: anEvent currentTarget text asString ].
	field := BrHorizontalPane new
			vFitContent;
			alignCenterLeft;
			background: (Color black alpha: 0.04);
			geometry: (BlRoundedRectangleGeometry cornerRadius: 5);
			padding: (BlInsets top: 4 left: 8 bottom: 4 right: 8);
			cellSpacing: 6;
			constraintsDo: [ :c | c horizontal exact: 220 ];
			yourself.
	field
		addChild: (BrGlamorousVectorIcons search asElement
				size: 14 @ 14;
				yourself);
		addChild: searchField.
	^ field
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
CarpBrowserElement >> toggleProblems [
	"Problems live in the browser rather than in a window of their own: you
	check, you click one, you are in the definition that caused it."

	problemsPane
		ifNil: [ problemsPane := self newProblemsPane.
			self addChild: problemsPane ]
		ifNotNil: [ self removeChild: problemsPane.
			problemsPane := nil ]
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newProblemsPane [
	"Checking a project means annotating every file against the session,
	which is real compiler work: it happens in the background and the pane
	says so until the answers arrive."

	| pane header |
	pane := BlElement new
			layout: BlLinearLayout vertical;
			background: Color white;
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical exact: 170 ];
			yourself.
	header := self
			newColumnHeader: (browserModel project isSessionLoaded
					ifTrue: [ 'checking…' ]
					ifFalse: [ 'problems · load the project into a session to check it' ]).
	pane
		addChild: self newHorizontalSeparator;
		addChild: header;
		addChild: (self newProblemListOn: #()).
	browserModel project isSessionLoaded
		ifTrue: [ self checkInto: pane header: header ].
	^ pane
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newProblemListOn: aCollection [
	"A scrolled column of rows rather than a list: a list built into a pane
	that is already on screen never materialises its items, and there are
	rarely enough problems for virtualisation to matter."

	| content |
	content := BlElement new
			layout: BlLinearLayout vertical;
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical fitContent ];
			yourself.
	aCollection
		do: [ :aProblem |
			| row |
			row := self newProblemRow.
			self fill: row with: aProblem.
			content
				addChild: row;
				addChild: self newHorizontalSeparator ].
	^ BlScrollableElement new
		addChild: content;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		yourself
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newProblemRow [
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		alignCenterLeft;
		margin: (BlInsets top: 0 left: 8 bottom: 0 right: 8);
		padding: (BlInsets top: 6 left: 8 bottom: 6 right: 8);
		cellSpacing: 8;
		yourself
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> fill: aRow with: aProblem [
	aRow removeChildren.
	aRow
		when: BlClickEvent
		do: [ :anEvent | browserModel showDefinition: aProblem definition ].
	aRow
		addChild: (BrLabel new
				aptitude: (BrGlamorousLabelAptitude new
						foreground: BrGlamorousColors errorBackgroundColor;
						fontSize: 10);
				text: aProblem phase asUppercase);
		addChild: (BrLabel new
				aptitude: (BrGlamorousLabelAptitude new fontSize: 12);
				text: aProblem message);
		addChild: (BrFrame new hMatchParent vFitContent);
		addChild: (BrLabel new
				aptitude: (BrGlamorousLabelAptitude new
						glamorousCodeFont;
						foreground: self secondaryColor;
						fontSize: 11);
				text: (aProblem definition
						ifNil: [ browserModel project relativePathOf: aProblem file ]
						ifNotNil: [ :aDefinition | aDefinition name ]))
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
CarpBrowserElement >> onFilterChanged [
	"Keep looking at the same definition if the filter still shows it, and
	otherwise let the selection go rather than jump somewhere arbitrary."

	| modules definitions |
	modules := browserModel modules.
	definitions := browserModel definitions.
	moduleList items: modules.
	definitionList items: definitions.
	(modules includes: browserModel selectedModule)
		ifFalse: [ browserModel selectedModule: nil ].
	(definitions includes: browserModel selectedDefinition)
		ifFalse: [ browserModel selectedDefinition: nil ].
	self select: browserModel selectedModule in: moduleList among: modules.
	self select: browserModel selectedDefinition in: definitionList among: definitions.
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
	anywhere — a click, a reload, a spawned action — looks the same, and
	bring it into view: in a project this size the selection is usually
	below the fold."

	| index |
	anObject ifNil: [ ^ aList deselectAll ].
	index := aCollection indexOf: anObject ifAbsent: [ 0 ].
	index = 0
		ifTrue: [ aList deselectAll ]
		ifFalse: [ aList selectOne: index.
			aList scrollToSelection ]
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
										ifFalse: [ 'no session' ] ]).
					project changes
						ifNotEmpty: [ :them |
							aStream
								nextPutAll: ' · ';
								print: them size;
								nextPutAll: ' changed' ] ])
]

{ #category : #updating }
CarpBrowserElement >> updateCoderPane [
	"The module's definitions, one row each, the selected one opened in its
	coder — a module reads as a whole the way a class does, and you can move
	through it without going back to the list."

	| content scrollable |
	coderPane removeChildren.
	openRow := nil.
	self updateCoderHeader.
	browserModel selectedModule
		ifNil: [ ^ coderPane addChild: self newPlaceholder ].
	content := BlElement new
			layout: BlLinearLayout vertical;
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical fitContent ].
	browserModel definitions
		do: [ :each | content addChild: (self newRowFor: each) ].
	scrollable := BlScrollableElement new
			addChild: content;
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical matchParent ];
			yourself.
	coderPane addChild: scrollable.
	openRow
		ifNotNil: [ :aRow |
			aRow
				when: BlElementLayoutComputedEvent
				doOnce: [ :anEvent | self scroll: scrollable to: aRow ] ]
]

{ #category : #updating }
CarpBrowserElement >> updateCoderHeader [
	"The third column says which module you are inside."

	coderHeader ifNil: [ ^ self ].
	coderHeader
		text: (browserModel selectedModule
				ifNil: [ 'no module selected' ]
				ifNotNil: [ :aModule |
					aModule displayName , ' · ' , browserModel definitions size printString
						, ' definitions' ]) asUppercase
]

{ #category : #updating }
CarpBrowserElement >> scroll: aScrollable to: anElement [
	"Put the open definition at the top of the pane. Scrolling down moves the
	content up, hence the negated offset; the row only knows where it is once
	it has been laid out, which is what waits for us."

	| offset |
	anElement parent ifNil: [ ^ self ].
	offset := anElement position y + aScrollable scrollPosition y.
	offset = 0 ifTrue: [ ^ self ].
	aScrollable scrollVerticallyBy: offset negated
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newRowFor: aDefinition [
	"One definition: its header always, its coder when it is the selected
	one. Building every coder up front would mean compiling a hundred
	editors to look at one."

	| row isOpen |
	isOpen := aDefinition == browserModel selectedDefinition.
	row := BlElement new
			layout: BlLinearLayout vertical;
			background: (isOpen ifTrue: [ self openRowColor ] ifFalse: [ Color white ]);
			geometry: (BlRoundedRectangleGeometry cornerRadius: (isOpen ifTrue: [ 6 ] ifFalse: [ 0 ]));
			margin: (isOpen
					ifTrue: [ BlInsets top: 6 left: 8 bottom: 6 right: 8 ]
					ifFalse: [ BlInsets top: 0 left: 8 bottom: 0 right: 8 ]);
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical fitContent ].
	row addChild: (self newHeaderFor: aDefinition).
	isOpen ifFalse: [ row addChild: self newHorizontalSeparator ].
	isOpen
		ifTrue: [ openRow := row.
			row
				addChild: ((browserModel project isSessionLoaded
						ifTrue: [ (aDefinition newCoder asCoderViewModel expanded: true) asExpandedOnlyElement ]
						ifFalse: [ BrEditor new
								aptitude: BrGlamorousCodeEditorAptitude new;
								styler: CarpParser gtStyler;
								beReadOnlyWithSelection;
								text: aDefinition source ])
						padding: (BlInsets top: 0 left: 6 bottom: 8 right: 8);
						constraintsDo: [ :c |
							c horizontal matchParent.
							c vertical fitContent ]) ].
	^ row
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newHeaderFor: aDefinition [
	"The definition's line: its name, what defines it, and — when it is
	open — what you can do to it."

	| header isOpen |
	isOpen := aDefinition == browserModel selectedDefinition.
	header := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			alignCenterLeft;
			padding: (BlInsets top: 7 left: 10 bottom: 7 right: 6);
			cellSpacing: 8;
			when: BlClickEvent do: [ :anEvent | browserModel selectedDefinition: aDefinition ];
			yourself.
	header
		addChild: (BrLabel new
				aptitude: (isOpen
						ifTrue: [ BrGlamorousLabelAptitude new
								glamorousCodeFont;
								fontSize: 13;
								bold ]
						ifFalse: [ BrGlamorousLabelAptitude new
								glamorousCodeFont;
								fontSize: 13 ]);
				text: aDefinition shortName);
		addChild: (BrLabel new
				aptitude: (BrGlamorousLabelAptitude new
						foreground: self mutedColor;
						fontSize: 10);
				text: aDefinition head).
	aDefinition documentation
		ifNotEmpty: [ :aDoc |
			header
				addChild: (BrLabel new
						aptitude: (BrGlamorousLabelAptitude new
								foreground: self secondaryColor;
								fontSize: 11);
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
				aptitude: (BrGlamorousLabelAptitude new
						foreground: self mutedColor;
						fontSize: 12);
				padding: (BlInsets all: 12);
				text: (browserModel project isSessionLoaded
						ifTrue: [ 'Select a definition' ]
						ifFalse: [ 'Select a definition · load the project into a session to type and check it' ]));
		yourself
]
