Class {
	#name : #CarpModule,
	#superclass : #CarpExpression,
	#instVars : [
		'uses',
		'expressions',
		'name',
		'tests'
	],
	#category : #'Carp-IDE'
}

{ #category : #accessing }
CarpModule >> addExpression: anExpression [
	expressions add: anExpression
]

{ #category : #accessing }
CarpModule >> addTest: aTest [
	tests add: aTest
]

{ #category : #accessing }
CarpModule >> addUse: aString [
	uses add: aString
]

{ #category : #coders }
CarpModule >> carpCoderCommentsFor: aView [

	<gtModuleView>
	^ aView explicit
		  title: 'Documentation';
		  tooltip: 'Module Documentation';
		  priority: 1;
		  disableAsync;
		  stencil: [ 
			  | snippet snippetViewModel |
			  snippet := LeTextSnippet string: self documentation.
			  snippetViewModel := snippet asSnippetViewModel.
			  snippetViewModel coderViewModel addShortcut:
					  (BrEditorShortcut lineEnding combination:
							   (LeSnippetElement keyboardShortcut: #NewLine)).
			  snippetViewModel coderViewModel addShortcut:
					  (BlShortcutWithAction new
						   combination: BlKeyCombination primaryS;
						   action: [ :anEvent | 
							   self documentation: anEvent currentTarget text asString ]).
			  ((snippetViewModel snippetView needsEmbellishments: false)
				   asElement snippetViewModel: snippetViewModel) vMatchParent ];
		  actionButtonIcon: BrGlamorousVectorIcons accept
		  tooltip: 'Save documentation'
		  action: [ :aToggle :aTab | 
			  self documentation:
				  aTab viewContentElement children first text asString ];
		  actionButtonIcon: BrGlamorousVectorIcons cancel
		  tooltip: 'Discard documentation'
		  action: [ :aToggle :aTab | 
			  aTab viewContentElement children first text: self documentation ]
]

{ #category : #coders }
CarpModule >> carpCoderStreamingMethodsFor: aView context: aPhlowContext [
	<gtModuleView>
	| aMethodsCoder aMethodsCoderViewModel aNewMethodCoderHolder coderElement |
	aNewMethodCoderHolder := ValueHolder new.

	^ aView explicit
		priority: 9;
		title: 'Methods';
		disableAsync;
		actionDropdownButtonDo: [ :aDrodownAction | 
			aDrodownAction dropdown
				icon: BrGlamorousVectorIcons add;
				tooltip: 'Add new function';
				content: [ :aButton | 
					| aNewMethodCoder aNewMethodCoderViewModel aHandler |
					aNewMethodCoderHolder contents
						ifNotNil: [ :aContents | aNewMethodCoderViewModel := aContents ]
						ifNil: [ aNewMethodCoder := GtCarpNewFunctionCoderModel new
									module: self;
									carpLinkApplicationStrategy: LeCarpApplicationStrategy new;
									onSave: [ aButton fireEvent: BrDropdownHideWish new.
										coderElement initializeForModule ].

							aNewMethodCoderViewModel := aNewMethodCoder asCoderViewModel.
							aNewMethodCoderViewModel
								withoutHeader;
								expanded: true;
								focused: true;
								moveCursorAtEnd.

							aNewMethodCoderHolder contents: aNewMethodCoderViewModel ].

					(GtExpandedOnlyCoderElement new coderViewModel: aNewMethodCoderViewModel)
						hExact: 300;
						vFitContent;
						background: Color white;
						padding: (BlInsets all: 5);
						addAptitude: BrGlamorousFocusableShadowAptitude new ];
				name: #'button--add-new-expression' ];
		stencil: [ coderElement := CarpStreamingMethodsCoderElement forModule: self ]
]

{ #category : #coders }
CarpModule >> carpCoderStreamingTestsFor: aView context: aPhlowContext [
	<gtModuleView>
	| aMethodsCoder aMethodsCoderViewModel aNewMethodCoderHolder |
		
	aNewMethodCoderHolder := ValueHolder new.

	^ aView explicit
		priority: 10;
		title: 'Tests';
		disableAsync;
		actionDropdownButtonDo: [ :aDrodownAction | 
			aDrodownAction dropdown 
				icon: BrGlamorousVectorIcons add;
				tooltip: 'Add new test suite';
				content: [ :aButton |
					| aNewMethodCoder aNewMethodCoderViewModel aHandler |

					aNewMethodCoderHolder contents
						ifNotNil: [ :aContents |
							aNewMethodCoderViewModel := aContents ]
						ifNil: [
					
						aNewMethodCoder := GtCarpCoderModel new.

						aNewMethodCoderViewModel := aNewMethodCoder asCoderViewModel.
						aNewMethodCoderViewModel
							withoutHeader;
							expanded: true;
							focused: true;
							moveCursorAtEnd.
						
						aNewMethodCoderHolder contents: aNewMethodCoderViewModel.

						aHandler := GtPharoNewMethodCodeSavedHandler new
							methodsCoderViewModel: aMethodsCoderViewModel;
							element: aButton;
							methodCoderHolder: aNewMethodCoderHolder.
						
						aNewMethodCoderViewModel weak
							when: GtMethodCoderSaved
							send: #onAnnouncement:
							to: aHandler ].

						(GtExpandedOnlyCoderElement new coderViewModel: aNewMethodCoderViewModel)
							hExact: 300;
							vFitContent;
							background: Color white;
							padding: (BlInsets all: 5);
							addAptitude: BrGlamorousFocusableShadowAptitude new ];
				name: #'button--add-new-test-suite'];
		stencil: [ (CarpStreamingMethodsCoderElement forModule: self) onTests ]
]

{ #category : #accessing }
CarpModule >> expressions [
	^ expressions
]

{ #category : #initialization }
CarpModule >> initialize [
	uses := Set new.
	expressions := OrderedCollection new.
	tests := OrderedCollection new.
]

{ #category : #converting }
CarpModule >> name [
	^ name
]

{ #category : #accessing }
CarpModule >> name: aString [ 
	name := aString
]

{ #category : #accessing }
CarpModule >> removeExpression: anExpression [
	expressions remove: anExpression
]

{ #category : #accessing }
CarpModule >> removeUse: aString [
	uses remove: aString
]

{ #category : #accessing }
CarpModule >> setUses: aCollectionOfStrings [
	uses := aCollectionOfStrings asSet
]

{ #category : #accessing }
CarpModule >> tests [
	^ tests
]

{ #category : #converting }
CarpModule >> toCarp [

	^ String streamContents: [ :aStream | 
		  aStream << '(doc ' << self name << ' "' << self documentation
		  << '")' << Character lf.
		  aStream << '(defmodule ' << self name << ' ' << (uses
			   ifEmpty: [ '' ]
			   ifNotEmpty: [ 
			   Character lf  asString , Character tab  asString, '(use-all ' , (' ' join: uses)
			   , ')' ]).
		  expressions do: [ :expression | 
			  aStream << Character lf << Character tab << expression toCarp ].
		  aStream << ')' ]
]

{ #category : #accessing }
CarpModule >> uses [
	^ uses
]

{ #category : #magritte }
CarpModule >> usesDescription [

	<magritteDescription>
	^ MAToManyRelationDescription new
		  label: 'Uses';
		  priority: 6;
		  accessor: (MASelectorAccessor read: #uses write: #setUses:);
		  classes: { String };
		  blocListStencil: [ :aMemento :aDescription :aForm | 
			  | aTagger |
			  aTagger := BrTagger new.
			  aTagger
				  margin: ((BlInsets left: 7) withBottom: 4);
				  hMatchParent;
				  vFitContent.
			  aForm hMatchParent.
			  aDescription isReadOnly
				  ifTrue: [ 
					  aTagger aptitude: (BrGlamorousTaggerAptitude new
							   margin: (BlInsets right: 5);
							   tagLabel: [ :aTag | 
								   | aLabel |
								   aLabel := BrLabel new
									             text: aTag name;
									             padding: (BlInsets all: 4);
									             geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
									             background:
										             BrGlamorousColors neutralBackgroundColor;
									             aptitude: (BrGlamorousLabelAptitude new
											              glamorousCodeFont;
											              fontSize: 10).

								   aLabel ]) ]
				  ifFalse: [ 
					  aTagger aptitude: (BrGlamorousTaggerEditableAptitude new
							   margin: (BlInsets right: 5);
							   tagLabel: [ :aTag | 
								   | aLabel |
								   aLabel := BrEditableLabel new
									             text: aTag name;
									             aptitude: (BrGlamorousEditableLabelAptitude new
											              glamorousCodeFont;
											              defaultForeground: Color black;
											              fontSize: 10).

								   aLabel ]).
					  aTagger when: BrTaggerAddTagRequest do: [ :aRequest | 
						  aMemento
							  write: ((aTagger tags collect: #name)
									   add: aRequest tag name;
									   yourself)
							  using: aDescription ].
					  aTagger when: BrTaggerRemoveTagRequest do: [ :aRequest | 
						  aMemento
							  write: ((aTagger tags collect: #name)
									   remove: aRequest tag name;
									   yourself)
							  using: aDescription ] ].
			  aTagger withAsyncSinkDo: [ :anElementSink | 
				  anElementSink
					  sink: AsyncPeakSink new;
					  whenUpdate: [ :theTagger :aSink | 
						  | theValues theTexts |
						  theValues := aSink value currentValue.
						  theTexts := theValues collect: [ :each | 
								              aDescription displayStringFor: each ].
						  theTagger namedTags: theTexts ].
				  (aMemento readObservableValueUsing: aDescription) observe:
					  anElementSink ] ]
]
