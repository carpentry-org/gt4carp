Class {
	#name : #GtCarpCoderModel,
	#superclass : #GtSourceCoder,
	#instVars : [
		'pharoBindings',
		'carpLinkApplicationStrategy'
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
	| carpSource trimmedSource ast varNames lastStatement application commandFactory |

	trimmedSource := SmaCCString on: sourceString trimRight.
	ast := CarpParser parse: trimmedSource.
	"The variables to be returned are names that are in pharoBindings"
	varNames := pharoBindings bindingNames asSet.

	"Assign the final statement to snippetResult"
	lastStatement := ast expressions last.
	trimmedSource 
		insert: '(defdynamic snippetResult ' 
		at: lastStatement startPosition.
	varNames add: 'snippetResult'.

	"Get the final source to execute"
	carpSource := self sourceFrom: trimmedSource asString returnedVarNames: varNames.

	application := carpLinkApplicationStrategy applicationServer.
	application isRunning ifFalse: [ application start ].
	commandFactory := application newCommandFactory.

	^ commandFactory
		<< carpSource;
		sendAndWait.

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
GtCarpCoderModel >> initializeAddOns: addOns [
	super initializeAddOns: addOns.
	
	addOns addStyler: (GtCoderAstSmaCCParserStyler new smaccStyler: CarpParser gtStyler).
	
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
	| result |

	result := self bindAndExecute: aSourceString.
	result associationsDo: [ :binding |
		(pharoBindings bindingOf: binding key asSymbol) value: binding value ].

	^ result
		at: 'snippetResult'
		ifAbsent: anEvaluationFailBlock
]

{ #category : #accessing }
GtCarpCoderModel >> sourceFrom: trimmedSourceString returnedVarNames: varNames [
	"Answer the modified source to return the declared variables"

	^ String streamContents: [ :stream |
		stream << trimmedSourceString.
		stream 
			cr
			<< '{ '.
		varNames do: [ :varName |
			stream 
				<< '(quote ';
				<< varName;
				<< ') ';
				<< varName;
				<< ' ' ].
		"Answer the variable dictionary as an immediate object"
		stream
			<< '(quote carpLinkImmediate) true }' ]
]

{ #category : #accessing }
GtCarpCoderModel >> variableBindings: aGtSnippetBindings [

	^ self pharoBindings: aGtSnippetBindings
]
