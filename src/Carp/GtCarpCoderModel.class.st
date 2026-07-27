Class {
	#name : #GtCarpCoderModel,
	#superclass : #GtSourceCoder,
	#instVars : [
		'pharoBindings',
		'sessionId'
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

	^ GtSourceCoderViewModel new coder: self
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
		addStyler: (GtCoderAstSmaCCParserStyler new smaccStyler: CarpParser gtStyler).

	addOns
		addMainAction: 'Format' translated
		icon: BrGlamorousVectorIcons clipboard
		action: [ :aCoderUIModel :anElement | 
			| source |
			source := GtCarpFormatter uniqueInstance
					format: (CarpParser parse: sourceCode currentSourceText wait value text).
			self sourceCode: (GtCoderExplicitStringSource new source: source) ]
		id: #'source-coder--format-action-id'.

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
		id: GtSourceCoderDoItAndGoActionId
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
GtCarpCoderModel >> newCompletionStrategy [
	^ GtCompletionStrategy new
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
GtCarpCoderModel >> sessionId [
	"The notebook session this coder evaluates in. Snippets on the same
	Lepiter page share one session; a detached coder gets its own scratch."

	^ sessionId ifNil: [ 'default' ]
]

{ #category : #accessing }
GtCarpCoderModel >> sessionId: aString [
	sessionId := aString
]

{ #category : #accessing }
GtCarpCoderModel >> variableBindings: aGtSnippetBindings [

	^ self pharoBindings: aGtSnippetBindings
]
