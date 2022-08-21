Class {
	#name : #GtCarpCoderModel,
	#superclass : #GtSourceCoder,
	#instVars : [
		'pharoBindings',
		'carpLinkApplicationStrategy',
		'exception',
		'application',
		'commandFactory'
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
GtCarpCoderModel >> bindAndExecute: sourceString [
	"Answer the source code with all declared variables returned in an immediate dictionary"

	<gtIgnoreConstraint: #GtRBAcceptVisitorCalledFromNonVisitingMethods>
	<remoteDebuggerSignal>
	| res trimmedSource ast varNames lastStatement carpSource |
	trimmedSource := SmaCCString on: sourceString trimRight.
	ast := CarpParser parse: trimmedSource.	"The variables to be returned are names that are in pharoBindings"
	varNames := pharoBindings
			ifNil: [ Set new ]
			ifNotNil: [ pharoBindings bindingNames asSet ].	"Assign the final statement to snippetResult"
	lastStatement := ast expressions last.
	trimmedSource
		insert: '(defdynamic snippetResult '
		at: lastStatement startPosition.
	trimmedSource insert: ')' at: lastStatement stopPosition.
	varNames add: 'snippetResult'.	"Get the final source to execute"
	carpSource := self
			sourceFrom: trimmedSource asString
			returnedVarNames: varNames.
	res := self bindAndExecuteRaw: sourceString.

	(res at: #result) = 'success' ifTrue: [ ^ CarpExecutionResult from: res ].
	exception := PharoLinkRemoteError new
			application: application;
			command: commandFactory command;
			trace: (res at: #value).
	exception signal
]

{ #category : #accessing }
GtCarpCoderModel >> bindAndExecuteRaw: sourceString [
	self initializeApplication.
	commandFactory := application newCommandFactory.

	^ commandFactory
		<< sourceString;
		sendAndWait
]

{ #category : #accessing }
GtCarpCoderModel >> carpLinkApplicationStrategy: anApplicationStrategy [
	carpLinkApplicationStrategy := anApplicationStrategy
]

{ #category : #accessing }
GtCarpCoderModel >> computeAst: theSourceString [
	^ CarpParser
		parseWithErrors: theSourceString
]

{ #category : #accessing }
GtCarpCoderModel >> exception [
	^ exception
]

{ #category : #accessing }
GtCarpCoderModel >> initializeAddOns: addOns [
	super initializeAddOns: addOns.

	addOns
		addStyler: (GtCoderAstSmaCCParserStyler new smaccStyler: CarpParser gtStyler).

	application
		ifNotNil: [ addOns
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
				addMainAction: 'Expand Macros' translated
				icon: BrGlamorousVectorIcons repair
				action: [ :aCoderUIModel :anElement | 
					| source |
					source := '(expand ''' , sourceCode currentSourceText wait value text , ')'.
					anElement phlow
						spawnObject: ((self bindAndExecute: source) parse view: #gtSourceFor:) ]
				id: #'source-coder--macro-expand-action'.
			addOns
				addMainAction: 'Build and Run' translated
				icon: BrGlamorousVectorIcons refresh
				action: [ :aCoderUIModel :anElement | 
					self bindAndExecuteRaw: sourceCode currentSourceText wait value text.
					self bindAndExecuteRaw: '(build)'.
					anElement phlow
						spawnObject: (CarpCliOutput text: ((self bindAndExecuteRaw: '(run)') at: 'value')) ]
				id: #'source-coder--build-and-run-action'.
			addOns
				addMainAction: 'Infer Type' translated
				icon: BrGlamorousVectorIcons inspect
				action: [ :aCoderUIModel :anElement | self inspectTypeSpawningOn: anElement phlow ]
				id: #'source-coder--type-infer-action' ]
]

{ #category : #accessing }
GtCarpCoderModel >> initializeApplication [
	application := carpLinkApplicationStrategy applicationServer.
	application isRunning ifFalse: [ application start ].
]

{ #category : #accessing }
GtCarpCoderModel >> initializeShortcuts: addOns [
	super initializeShortcuts: addOns.

	application
		ifNotNil: [ addOns
				addShortcut: GtSourceCoderDoItShortcut new;
				addShortcut: GtSourceCoderDoItAndInspectShortcut new ]
]

{ #category : #accessing }
GtCarpCoderModel >> inspectTypeSpawningOn: aPhlow [
	| source ast |
	source := sourceCode currentSourceText wait value text.
	ast := CarpParser parse: source.
	
	(ast expressions size = 1 and: [ ast expressions first isDefinition ])
		ifTrue: [ self bindAndExecute: source asString.
			source := ast expressions first definitionVariable value source ].
			
	source := '(def *type-infer-this* ' , source
			, ') (defdynamic *type-infer-result* (type *type-infer-this*)) (def *type-infer-this* 0) *type-infer-result*'.
	aPhlow spawnObject: ((self bindAndExecute: source) parse transformValue: [:aValue | CarpTypeSignature on: aValue expressions first using: self])
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
	^ (self bindAndExecute: aSourceString) parse
		transformValue: [ :aValue | aValue expressions first toPharo ]
]

{ #category : #accessing }
GtCarpCoderModel >> sourceFrom: trimmedSourceString returnedVarNames: varNames [
	"Answer the modified source to return the declared variables"

	^ String
		streamContents: [ :stream | 
			stream << trimmedSourceString.
			stream lf << 'snippetResult' ]
]

{ #category : #accessing }
GtCarpCoderModel >> variableBindings: aGtSnippetBindings [

	^ self pharoBindings: aGtSnippetBindings
]
