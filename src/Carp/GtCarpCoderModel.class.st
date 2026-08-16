Class {
	#name : #GtCarpCoderModel,
	#superclass : #GtSourceCoder,
	#instVars : [
		'pharoBindings',
		'sessionId',
		'sessionIdProvider',
		'lifetimeHoverPosition',
		'lintFindingsCache',
		'lintFindingsHash',
		'typeAnnotationsCache',
		'typeAnnotationsHash',
		'typeAnnotationsFailedHash',
		'typeAnnotationsPending',
		'documentationCache'
	],
	#category : #'Carp-Coder'
}

{ #category : #'instance creation' }
GtCarpCoderModel class >> code: aString [

	^ self new sourceCode:
		  (GtCoderExplicitStringSource new source: aString)
]

{ #category : #converting }
GtCarpCoderModel >> asCoderViewModel [

	^ GtCarpSnippetCoderViewModel new coder: self
]

{ #category : #accessing }
GtCarpCoderModel >> computeAst: theSourceString [
	^ CarpParser
		parseWithErrors: theSourceString
]

{ #category : #accessing }
GtCarpCoderModel >> initializeAddOns: addOns [
	super initializeAddOns: addOns.

	addOns
		addStyler: (GtCoderAstSmaCCParserStyler new smaccStyler: CarpParser gtStyler);
		addStyler: CarpTypeAdornmentStyler new;
		addStyler: CarpLifetimeHighlightStyler new;
		addStyler: CarpDiagnosticHighlightStyler new;
		addStyler: CarpDocumentationStyler new;
		addStyler: CarpLintHighlightStyler new.

	addOns
		addMainAction: 'Format' translated
		icon: BrGlamorousVectorIcons edit
		action: [ :aCoderUIModel :anElement |
			[ | formatted |
			formatted := CarpExternalTool format: self currentSourceString.
			self sourceCode: (GtCoderExplicitStringSource new source: formatted) ]
				on: Error
				do: [ :e | anElement phlow spawnObject: (e messageText ifNil: [ e class name ]) ] ]
		id: #'source-coder--carp-format-action-id'.

	addOns
		addMainAction: 'Lint' translated
		icon: BrGlamorousVectorIcons repair
		action: [ :aCoderUIModel :anElement |
			[ anElement phlow spawnObject: (CarpLintReport onSource: self currentSourceString) ]
				on: Error
				do: [ :e | anElement phlow spawnObject: (e messageText ifNil: [ e class name ]) ] ]
		id: #'source-coder--carp-lint-action-id'.

	addOns
		addMainAction: 'Evaluate' translated
		icon: BrGlamorousVectorIcons play
		action: [ :aCoderUIModel :anElement |
			GtCoderCodeExecutor doIt
				coderViewModel: aCoderUIModel;
				element: anElement;
				execute ]
		id: GtSourceCoderDoItActionId.
	addOns
		addMainAction: 'Inspect' translated
		icon: BrGlamorousVectorIcons playinspect
		action: [ :aCoderUIModel :anElement |
			GtCoderCodeExecutor doItAndGo
				coderViewModel: aCoderUIModel;
				element: anElement;
				execute ]
		id: GtSourceCoderDoItAndGoActionId.
	addOns
		addMainAction: 'Expand' translated
		icon: BrGlamorousVectorIcons emphasizedInspect
		action: [ :aCoderUIModel :anElement |
			[ | expansion |
			expansion := CarpMacroExpansion
					onSource: self currentSourceString
					session: self sessionId.
			anElement phlow spawnObject: expansion ]
				on: Error
				do: [ :e | anElement phlow spawnObject: (e messageText ifNil: [ e class name ]) ] ]
		id: #'source-coder--carp-expand-action-id'.

	"Expansion answers what a form became; this answers how it got there.
	It is the tool to reach for when expansion fails, which is when `what it
	became` is nothing at all."
	addOns
		addMainAction: 'Debug' translated
		icon: BrGlamorousVectorIcons debug
		action: [ :aCoderUIModel :anElement |
			"Connecting to the adapter takes seconds, and this runs on the UI
			process, so it happens on a process of its own; the window then
			opens back on the UI process, which is the only one allowed to."
			| source |
			source := self currentSourceString.
			[ [ | debugger |
			debugger := CarpDAPDebugger onSource: source.
			anElement enqueueTask: (BlTaskAction new action: [ debugger open ]) ]
				on: Error
				do: [ :e |
					| message |
					message := e messageText ifNil: [ e class name ].
					anElement enqueueTask: (BlTaskAction new
							action: [ anElement phlow spawnObject: message ]) ] ]
				forkNamed: 'carp-debug' ]
		id: #'source-coder--carp-debug-action-id'.

	"The other debugger: not the expansion of the cell but the program it
	compiles to, stopped in its own code. Building takes a whole compile, so
	this too runs off the UI process."
	addOns
		addMainAction: 'Debug native' translated
		icon: BrGlamorousVectorIcons play
		action: [ :aCoderUIModel :anElement |
			| source |
			source := self currentSourceString.
			[ [ | built debugger |
			built := CarpServerClient default
					buildDebugSource: source
					session: self sessionId.
			debugger := CarpNativeDebugger onProgram: (built at: 'binary') asFileReference.
			anElement enqueueTask: (BlTaskAction new action: [ debugger open ]) ]
				on: Error
				do: [ :e |
					| message |
					message := e messageText ifNil: [ e class name ].
					anElement enqueueTask: (BlTaskAction new
							action: [ anElement phlow spawnObject: message ]) ] ]
				forkNamed: 'carp-debug-native' ]
		id: #'source-coder--carp-debug-native-action-id'
]

{ #category : #accessing }
GtCarpCoderModel >> embeddedDebuggerAddOnFor: anAST into: coderAddOns [
	"Deliberately empty: the inherited add-on attaches Pharo-AST stylers
	(GtEmbeddedDebuggerStyler and friends) that choke on our SmaCC AST with
	a #visitStart: DNU on every keystroke."
]

{ #category : #accessing }
GtCarpCoderModel >> initializeShortcuts: addOns [
	super initializeShortcuts: addOns.

	addOns
		addShortcut: GtSourceCoderDoItShortcut new;
		addShortcut: GtSourceCoderDoItAndInspectShortcut new
]

{ #category : #accessing }
GtCarpCoderModel >> pharoBindings: anObject [
	pharoBindings := anObject
]

{ #category : #accessing }
GtCarpCoderModel >> primitiveEvaluate: aSourceString inContext: aGtSourceCoderEvaluationContext onFailDo: anEvaluationFailBlock [
	^ [ (CarpServerClient default
		evalSource: aSourceString
		session: self sessionId) preferredInspectable ]
		on: CarpServerError
		do: [ :e | anEvaluationFailBlock cull: e ]
]

{ #category : #accessing }
GtCarpCoderModel >> lintFindingsFor: aString [
	"angler findings for aString, cached by text hash. angler runs in
	single-digit milliseconds, so this is synchronous; errors (missing
	binary, tool failure) degrade to no findings."

	| hash |
	hash := aString hash.
	lintFindingsHash = hash ifTrue: [ ^ lintFindingsCache ].
	lintFindingsCache := [ CarpExternalTool lint: aString ] on: Error do: [ :e | #() ].
	lintFindingsHash := hash.
	^ lintFindingsCache
]

{ #category : #accessing }
GtCarpCoderModel >> documentationFor: aName [
	"The session's doc string for a name, or nil. Cached per name for the
	life of the coder: docs are fetched when a tooltip is shown, and the
	same symbol is hovered again and again."

	documentationCache ifNil: [ documentationCache := Dictionary new ].
	^ (documentationCache
		at: aName
		ifAbsentPut: [ [ (CarpServerClient default docFor: aName session: self sessionId)
				ifNil: [ '' ]
				ifNotNil: [ :aDictionary | aDictionary at: 'documentation' ifAbsent: [ '' ] ] ]
				on: Error
				do: [ :e | '' ] ]) ifEmpty: [ nil ]
]

{ #category : #accessing }
GtCarpCoderModel >> lifetimeHoverAt: aPositionOrNil [
	"Set by the hover attributes the lifetime styler attaches to variable
	occurrences; drives the lifetime highlight."

	lifetimeHoverPosition = aPositionOrNil ifTrue: [ ^ self ].
	lifetimeHoverPosition := aPositionOrNil.
	[ self requestStyleSourceText ] on: Error do: [ :e |  ]
]

{ #category : #accessing }
GtCarpCoderModel >> lifetimeHoverPosition [
	^ lifetimeHoverPosition
]

{ #category : #accessing }
GtCarpCoderModel >> typeAdornmentAnnotations [
	"Answer the annotations matching the CURRENT source, or nil while they
	are being computed. A single background worker tracks the text until it
	stabilizes, fetches, then triggers a restyle."

	| text hash |
	text := [ self currentSourceString ] on: Error do: [ :e | ^ nil ].
	hash := text hash.
	typeAnnotationsHash = hash ifTrue: [ ^ typeAnnotationsCache ].
	typeAnnotationsFailedHash = hash ifTrue: [ ^ nil ].
	typeAnnotationsPending == true ifTrue: [ ^ nil ].
	typeAnnotationsPending := true.
	[ [ | current stable latest |
	current := text.
	stable := false.
	[ stable ]
		whileFalse: [ (Delay forMilliseconds: 300) wait.
			latest := [ self currentSourceString ] on: Error do: [ :e | nil ].
			latest
				ifNil: [ stable := true ]
				ifNotNil: [ latest = current
						ifFalse: [ current := latest ]
						ifTrue: [ stable := true.
							(latest hash = typeAnnotationsHash
								or: [ latest hash = typeAnnotationsFailedHash ])
								ifFalse: [ [ typeAnnotationsCache := CarpServerClient default
												annotateSource: latest
												session: self sessionId.
									typeAnnotationsHash := latest hash.
									[ self requestStyleSourceText ] on: Error do: [ :e |  ] ]
										on: Error
										do: [ :e | typeAnnotationsFailedHash := latest hash ] ] ] ] ] ]
		ensure: [ typeAnnotationsPending := false ] ]
		forkNamed: 'carp-type-annotations'.
	^ nil
]

{ #category : #accessing }
GtCarpCoderModel >> sessionId [
	"The notebook session this coder evaluates in. Snippets on the same
	Lepiter page share one session; a detached coder gets its own scratch.
	Computed lazily: snippet coders are created before their snippet is
	attached to a page, so the page can only be asked at use time."

	^ sessionId
		ifNil: [ (sessionIdProvider ifNotNil: [ :aProvider | aProvider value ])
				ifNil: [ 'default' ] ]
]

{ #category : #accessing }
GtCarpCoderModel >> sessionIdProvider: aBlock [
	sessionIdProvider := aBlock
]


{ #category : #accessing }
GtCarpCoderModel >> sessionId: aString [
	sessionId := aString
]

{ #category : #accessing }
GtCarpCoderModel >> variableBindings: aGtSnippetBindings [

	^ self pharoBindings: aGtSnippetBindings
]
