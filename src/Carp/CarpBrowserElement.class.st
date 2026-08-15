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

A drawer along the bottom holds the things you do to the project as a whole
rather than to one definition: a playground on the project's own session,
and the problems the compiler sees. It stays alive while it is closed, so
what you were trying out in the playground is still there when you open it
again.
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
		'problemsHeader',
		'drawer',
		'drawerTabs',
		'drawerTab',
		'openRow',
		'updatingLists'
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
			self whenUserSelects: [
				anEvent selectedDo: [ :anInterval |
					browserModel selectedModule: (moduleList viewModel itemAt: anInterval first) ] ] ].
	definitionList := self newListLabelled: [ :each | each shortName ].
	definitionList
		itemDataBinder: [ :aLabel :each |
			aLabel
				text: (each shortName asRopedText
						foreground: (self colorForKind: each kind)) ].
	definitionList
		when: BrSelectionChanged
		do: [ :anEvent |
			self whenUserSelects: [
				anEvent selectedDo: [ :anInterval |
					browserModel selectedDefinition: (definitionList viewModel itemAt: anInterval first) ] ] ].
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
				action: [ self toggleDrawerOn: self problemsTabLabel ]);
		addChild: (self
				newToolbarButton: 'Playground'
				icon: BrGlamorousVectorIcons playinspect
				action: [ self toggleDrawerOn: self playgroundTabLabel ]).
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

{ #category : #accessing }
CarpBrowserElement >> playgroundTabLabel [
	^ 'Playground'
]

{ #category : #accessing }
CarpBrowserElement >> problemsTabLabel [
	^ 'Problems'
]

{ #category : #actions }
CarpBrowserElement >> toggleDrawerOn: aLabel [
	"The button you pressed either opens the drawer on its tab, moves the
	drawer to it, or — if you are already looking at it — puts it away."

	self drawer.
	(self children includes: drawer)
		ifFalse: [ self addChild: drawer.
			^ self showDrawerTab: aLabel ].
	drawerTab = aLabel
		ifTrue: [ self removeChild: drawer ]
		ifFalse: [ self showDrawerTab: aLabel ]
]

{ #category : #actions }
CarpBrowserElement >> showDrawerTab: aLabel [
	drawerTab := aLabel.
	drawerTabs selectTabWithLabelString: aLabel.
	aLabel = self problemsTabLabel ifTrue: [ self refreshProblems ]
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> drawer [
	"Built once and kept: closing the drawer only detaches it, so the
	playground keeps whatever you were writing in it."

	^ drawer ifNil: [ drawer := self newDrawer ]
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newDrawer [
	| pane resizer |
	drawerTabs := BrTabGroup new
			aptitude: BrGlamorousTabGroupAptitude new;
			matchParent;
			yourself.
	drawerTabs
		addTab: (BrTab new
				aptitude: BrGlamorousTabAptitude new;
				label: self playgroundTabLabel;
				stencil: [ self newPlaygroundPane ]);
		addTab: (BrTab new
				aptitude: BrGlamorousTabAptitude new;
				label: self problemsTabLabel;
				stencil: [ self newProblemsPane ]).
	pane := BlElement new
			layout: BlLinearLayout vertical;
			background: Color white;
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical exact: 280 ];
			yourself.
	resizer := BrResizer new
			aptitude: BrGlamorousResizerAptitude;
			target: pane;
			beTop;
			constraintsDo: [ :c | c ignoreByLayout ];
			when: BlResizerResizedEvent
				do: [ :anEvent |
					pane constraintsDo: [ :c | c vertical exact: (anEvent extent y max: 120) ].
					pane requestLayout ];
			yourself.
	pane
		addChild: self newHorizontalSeparator;
		addChild: drawerTabs;
		addChild: resizer.
	^ pane
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newPlaygroundPane [
	"A scratch coder on the project's session, in the project: everything it
	defines is in scope, so you can try a definition out beside it."

	| coder |
	coder := (browserModel project newPlaygroundCoder asCoderViewModel expanded: true)
			asExpandedOnlyElement.
	^ BlElement new
		layout: BlLinearLayout vertical;
		background: Color white;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		addChild: (self
				newColumnHeader: (browserModel project rootName , ' · '
						, (browserModel project isSessionLoaded
								ifTrue: [ 'everything the project defines is in scope' ]
								ifFalse: [ 'load the project into a session to evaluate here' ])));
		addChild: (coder
				padding: (BlInsets top: 0 left: 6 bottom: 8 right: 12);
				constraintsDo: [ :c |
					c horizontal matchParent.
					c vertical matchParent ]);
		yourself
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newProblemsPane [
	"Checking a project means annotating every file against the session,
	which is real compiler work: it happens in the background and the pane
	says so until the answers arrive."

	problemsPane := BlElement new
			layout: BlLinearLayout vertical;
			background: Color white;
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical matchParent ];
			yourself.
	problemsHeader := self newColumnHeader: ''.
	problemsPane
		addChild: problemsHeader;
		addChild: (self newProblemListOn: #()).
	self refreshProblems.
	^ problemsPane
]

{ #category : #actions }
CarpBrowserElement >> refreshProblems [
	"Opening the tab asks the question again: the project has usually moved
	on since the last time you looked."

	problemsPane ifNil: [ ^ self ].
	browserModel project isSessionLoaded
		ifFalse: [ ^ problemsHeader
				text: 'problems · load the project into a session to check it' asUppercase ].
	problemsHeader text: 'checking…' asUppercase.
	self checkInto: problemsPane header: problemsHeader
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

{ #category : #actions }
CarpBrowserElement >> checkInto: aPane header: aHeader [
	"Checking a project means annotating every file against the session,
	which is real compiler work — it happens in the background, and answers
	into the pane it was asked from, and only while that pane is still the
	one on screen."

	| project |
	project := browserModel project.
	[ | problems |
	problems := [ project problems ] on: Error do: [ :e | #() ].
	aPane
		enqueueTask: (BlTaskAction new
				action: [ problemsPane == aPane
						ifTrue: [ aHeader
								text: (problems size = 1
										ifTrue: [ '1 problem' ]
										ifFalse: [ problems size printString , ' problems' ]) asUppercase.
							aPane removeChild: aPane children last.
							aPane addChild: (self newProblemListOn: problems) ] ]) ]
		forkNamed: 'carp-project-problems'
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
		whileUpdatingLists: [ self
				select: browserModel selectedDefinition
				in: definitionList
				among: browserModel sortedDefinitions ].
	self updateCoderPane
]

{ #category : #updating }
CarpBrowserElement >> onFilterChanged [
	"Keep looking at the same definition if the filter still shows it, and
	otherwise let the selection go rather than jump somewhere arbitrary."

	| modules definitions |
	modules := browserModel modules.
	definitions := browserModel definitions.
	self
		whileUpdatingLists: [ moduleList items: modules.
			definitionList items: definitions.
			(modules includes: browserModel selectedModule)
				ifFalse: [ browserModel selectedModule: nil ].
			(definitions includes: browserModel selectedDefinition)
				ifFalse: [ browserModel selectedDefinition: nil ].
			self select: browserModel selectedModule in: moduleList among: modules.
			self
				select: browserModel selectedDefinition
				in: definitionList
				among: browserModel sortedDefinitions ].
	self updateCoderPane
]

{ #category : #updating }
CarpBrowserElement >> onModuleSelected [
	self
		whileUpdatingLists: [ definitionList items: browserModel sortedDefinitions.
			self select: browserModel selectedModule in: moduleList among: browserModel modules.
			self
				select: browserModel selectedDefinition
				in: definitionList
				among: browserModel sortedDefinitions ].
	self updateCoderPane
]

{ #category : #updating }
CarpBrowserElement >> whileUpdatingLists: aBlock [
	"Filling a list and selecting in it are how the model reaches the view.
	Both make the list announce a selection, which is how the view reaches
	the model — so without this the two directions drive each other: a jump
	changes the module, refilling the definition list selects something else,
	that selection changes the model back, and the browser oscillates
	forever. Announcements while we are updating are ours, not the user's."

	| was |
	was := updatingLists.
	updatingLists := true.
	^ [ aBlock value ] ensure: [ updatingLists := was ]
]

{ #category : #updating }
CarpBrowserElement >> whenUserSelects: aBlock [
	"Run the block only when the selection came from the user."

	updatingLists == true ifTrue: [ ^ self ].
	^ aBlock value
]

{ #category : #updating }
CarpBrowserElement >> updateSearchField [
	"The field writes the filter, and a jump can clear it, so it also has to
	read it back — otherwise the box still says what it no longer narrows."

	searchField ifNil: [ ^ self ].
	searchField text asString = browserModel filter ifTrue: [ ^ self ].
	searchField text: browserModel filter
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
	self
		whileUpdatingLists: [ self updateSearchField.
			moduleList items: browserModel modules.
			definitionList items: browserModel sortedDefinitions.
			self select: browserModel selectedModule in: moduleList among: browserModel modules.
			self
				select: browserModel selectedDefinition
				in: definitionList
				among: browserModel sortedDefinitions ].
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
				label: (project isSessionLoaded
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
										ifFalse: [ project sessionState = #refreshing
												ifTrue: [ 'session catching up…' ]
												ifFalse: [ 'no session' ] ] ]).
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
			row addChild: (self newFacetsFor: aDefinition) ].
	^ row
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newFacetsFor: aDefinition [
	"A definition has more sides than its source. What it does is the code;
	what it is for is its documentation; what it looks like in use are its
	examples; and a type also has the members Carp derives for it. You read
	one at a time, so they are tabs — GT's own, which give the selected one
	its underline and build a side only when you ask for it."

	| tabs |
	tabs := BrTabGroup new
			aptitude: BrGlamorousTabGroupAptitude new;
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical exact: (self facetHeightFor: aDefinition) ];
			yourself.
	tabs
		addTab: (self facetTabLabelled: 'Definition' for: [ self newDefinitionPaneFor: aDefinition ]);
		addTab: (self facetTabLabelled: 'Documentation' for: [ self newDocumentationPaneFor: aDefinition ]);
		addTab: (self facetTabLabelled: 'Examples' for: [ self newExamplesPaneFor: aDefinition ]).
	aDefinition isType
		ifTrue: [ tabs
				addTab: (self facetTabLabelled: 'Members' for: [ self newMembersPaneFor: aDefinition ]) ].
	^ tabs
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> facetTabLabelled: aString for: aBlock [
	^ BrTab new
		aptitude: BrGlamorousTabAptitude new;
		label: aString;
		stencil: aBlock;
		yourself
]

]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newMembersPaneFor: aDefinition [
	"What a type brings with it: the functions the compiler derived from its
	fields, which are ordinary definitions in the session rather than
	anything the file spells out."

	| content members |
	members := browserModel project membersOf: aDefinition.
	content := BlElement new
			layout: BlLinearLayout vertical;
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical fitContent ];
			yourself.
	members
		ifEmpty: [ content
				addChild: (BrLabel new
						aptitude: (BrGlamorousLabelAptitude new
								foreground: self mutedColor;
								fontSize: 12);
						padding: (BlInsets all: 12);
						text: (browserModel project isSessionLoaded
								ifTrue: [ 'No members' ]
								ifFalse: [ 'Load the project into a session to see what it derives' ])) ]
		ifNotEmpty: [ members
				do: [ :each |
					content
						addChild: (BrHorizontalPane new
								hMatchParent;
								vFitContent;
								alignCenterLeft;
								padding: (BlInsets top: 5 left: 10 bottom: 5 right: 8);
								cellSpacing: 10;
								addChild: (BrLabel new
										aptitude: (BrGlamorousLabelAptitude new
												glamorousCodeFont;
												fontSize: 12);
										text: (each at: 'name'));
								addChild: (BrLabel new
										aptitude: (BrGlamorousLabelAptitude new
												glamorousCodeFont;
												foreground: self mutedColor;
												fontSize: 11);
										text: (each at: 'type' ifAbsent: [ '' ]));
								yourself);
						addChild: self newHorizontalSeparator ] ].
	^ BlScrollableElement new
		addChild: content;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		yourself
]

{ #category : #style }
CarpBrowserElement >> facetHeightFor: aDefinition [
	"Enough for the definition to be read without a scrollbar, and no more."

	| lines |
	lines := aDefinition source lines size.
	^ (((lines + 3) * 18 + 46) min: 420) max: 150
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newExamplesPaneFor: aDefinition [
	| content examples |
	examples := browserModel project examplesFor: aDefinition.
	content := BlElement new
			layout: BlLinearLayout vertical;
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical fitContent ];
			yourself.
	examples
		ifEmpty: [ content
				addChild: (BrLabel new
						aptitude: (BrGlamorousLabelAptitude new
								foreground: self mutedColor;
								fontSize: 12);
						padding: (BlInsets all: 12);
						text: 'Nothing exemplifies this yet.') ]
		ifNotEmpty: [ examples
				do: [ :anExample |
					content
						addChild: (self newExampleRowFor: anExample);
						addChild: self newHorizontalSeparator ] ].
	^ BlScrollableElement new
		addChild: content;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		yourself
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newExampleRowFor: anExample [
	| result |
	result := BrLabel new
			aptitude: (BrGlamorousLabelAptitude new
					glamorousCodeFont;
					foreground: self secondaryColor;
					fontSize: 11);
			text: '';
			yourself.
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		alignCenterLeft;
		padding: (BlInsets top: 6 left: 10 bottom: 6 right: 8);
		cellSpacing: 8;
		addChild: (BrLabel new
				aptitude: (BrGlamorousLabelAptitude new
						glamorousCodeFont;
						fontSize: 12);
				text: anExample shortName);
		addChild: result;
		addChild: (BrFrame new hMatchParent vFitContent);
		addChild: (BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude;
				icon: BrGlamorousVectorIcons playinspect;
				label: 'Run this example';
				action: [ :aButton | self run: anExample into: result from: aButton ]);
		addChild: (BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude;
				icon: BrGlamorousVectorIcons edit;
				label: 'Go to this example';
				action: [ :aButton | self goTo: anExample from: aButton ]);
		yourself
]

{ #category : #actions }
CarpBrowserElement >> goTo: aDefinition from: anElement [
	"Jump after the click, not during it. Landing on a definition rebuilds
	the pane, and the button asking for the jump lives inside the pane being
	rebuilt: doing that inside the click leaves the event dispatching into
	elements that are no longer there."

	anElement
		enqueueTask: (BlTaskAction new action: [ browserModel showDefinition: aDefinition ])
]

{ #category : #actions }
CarpBrowserElement >> run: anExample into: aLabel from: anElement [
	"Run an example in the project's own session and open what it answered.
	The row keeps the short answer, and the object itself goes into a pane,
	which is what running something in GT means. It runs in the background:
	it is a compile and a run, which is fast now but not instant."

	| project |
	project := browserModel project.
	aLabel text: 'running…'.
	[ | answer |
	answer := [ (CarpServerClient default
			evalSource: '(' , anExample name , ')'
			session: project sessionId) preferredInspectable ]
			on: Error
			do: [ :e | e messageText ifNil: [ e class name ] ].
	anElement
		enqueueTask: (BlTaskAction new
				action: [ aLabel text: (self shortAnswerFor: answer).
					anElement phlow spawnObject: answer ]) ]
		forkNamed: 'carp-run-example'
]

{ #category : #actions }
CarpBrowserElement >> shortAnswerFor: anAnswer [
	"What fits on the row: the value a run answered, or whatever the thing
	itself has to say when it is not one."

	| text |
	text := (anAnswer printString ifNil: [ '' ]) asString trimBoth.
	^ text size > 80
		ifTrue: [ (text first: 79) , '…' ]
		ifFalse: [ text ]
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newDefinitionPaneFor: aDefinition [
	^ (browserModel project isSessionLoaded
		ifTrue: [ (aDefinition newCoder asCoderViewModel expanded: true) asExpandedOnlyElement ]
		ifFalse: [ BrEditor new
				aptitude: BrGlamorousCodeEditorAptitude new;
				styler: CarpParser gtStyler;
				beReadOnlyWithSelection;
				text: aDefinition source ])
		padding: (BlInsets top: 4 left: 6 bottom: 8 right: 8);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ]
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newDocumentationPaneFor: aDefinition [
	"Documentation is a (doc …) form in the file, so editing it here writes
	that form — creating it when there was none, removing it when you empty
	it. Saving is asked for rather than continuous: prose is not code, and
	rewriting the file on every keystroke would churn the session."

	| editor |
	editor := BrEditor new
			aptitude: BrGlamorousRegularEditorAptitude new;
			padding: (BlInsets top: 6 left: 8 bottom: 6 right: 8);
			text: aDefinition documentation;
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical matchParent ];
			yourself.
	^ BlElement new
		layout: BlLinearLayout vertical;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		addChild: editor;
		addChild: (BrHorizontalPane new
				hMatchParent;
				vFitContent;
				alignCenterRight;
				padding: (BlInsets top: 2 left: 8 bottom: 6 right: 8);
				addChild: (BrButton new
						aptitude: BrGlamorousButtonWithLabelAptitude new;
						label: 'Save documentation';
						action: [ aDefinition saveDocumentation: editor text asString.
							browserModel reload ];
						yourself);
				yourself);
		yourself
]

{ #category : #style }
CarpBrowserElement >> colorForKind: aSymbol [
	aSymbol = #type ifTrue: [ ^ BrGlamorousColors linkColor ].
	aSymbol = #interface ifTrue: [ ^ Color r: 0.45 g: 0.2 b: 0.6 ].
	aSymbol = #example ifTrue: [ ^ Color r: 0.15 g: 0.5 b: 0.2 ].
	aSymbol = #module ifTrue: [ ^ self secondaryColor ].
	^ BrGlamorousColors defaultHeaderTextColor
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newTagLabelled: aString [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				foreground: self mutedColor;
				fontSize: 9);
		border: (BlBorder paint: self hairline width: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
		padding: (BlInsets top: 1 left: 5 bottom: 1 right: 5);
		text: aString;
		yourself
]

{ #category : #accessing }
CarpBrowserElement >> typeTextFor: aDefinition [
	| text |
	text := aDefinition signature
			ifNotEmpty: [ :aSignature | aSignature ]
			ifEmpty: [ (browserModel project inferredTypeOf: aDefinition name) ifNil: [ '' ] ].
	^ text size > 60
		ifTrue: [ (text first: 57) , '…' ]
		ifFalse: [ text ]
]

{ #category : #'initialization - parts' }
CarpBrowserElement >> newKindChipFor: aDefinition [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				glamorousCodeFont;
				foreground: (self colorForKind: aDefinition kind);
				fontSize: 9);
		background: ((self colorForKind: aDefinition kind) alpha: 0.09);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
		padding: (BlInsets top: 1 left: 5 bottom: 1 right: 5);
		text: (aDefinition isExample ifTrue: [ 'example' ] ifFalse: [ aDefinition head ]);
		yourself
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
		addChild: (self newKindChipFor: aDefinition);
		addChild: (BrLabel new
				aptitude: (isOpen
						ifTrue: [ BrGlamorousLabelAptitude new
								glamorousCodeFont;
								fontSize: 13;
								bold ]
						ifFalse: [ BrGlamorousLabelAptitude new
								glamorousCodeFont;
								fontSize: 13 ]);
				text: aDefinition shortName).
	(self typeTextFor: aDefinition)
		ifNotEmpty: [ :aType |
			header
				addChild: (BrLabel new
						aptitude: (BrGlamorousLabelAptitude new
								glamorousCodeFont;
								foreground: self mutedColor;
								fontSize: 11);
						text: aType) ].
	aDefinition isPrivate ifTrue: [ header addChild: (self newTagLabelled: 'private') ].
	aDefinition isHidden ifTrue: [ header addChild: (self newTagLabelled: 'hidden') ].
	aDefinition implementedInterfaces
		do: [ :each | header addChild: (self newTagLabelled: 'implements ' , each) ].
	(browserModel project examplesFor: aDefinition)
		ifNotEmpty: [ :them |
			header
				addChild: (self
						newTagLabelled: them size printString
								, (them size = 1 ifTrue: [ ' example' ] ifFalse: [ ' examples' ])) ].
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
