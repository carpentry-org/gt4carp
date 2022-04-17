Class {
	#name : #CarpModule,
	#superclass : #CarpExpression,
	#instVars : [
		'uses',
		'expressions',
		'name'
	],
	#category : #'Carp-IDE'
}

{ #category : #'instance creation' }
CarpModule class >> named: aString [
	^ self new name: aString
]

{ #category : #accessing }
CarpModule >> addExpression: anExpression [
	expressions add: anExpression
]

{ #category : #accessing }
CarpModule >> addUse: aString [
	uses add: aString
]

{ #category : #accessing }
CarpModule >> carpCoderCommentsFor: aView [

	<gtModuleView>
	^ aView explicit
		  title: 'Documentation';
		  tooltip: 'Module Documentation';
		  priority: 30;
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
		  actionUpdateButtonTooltip: 'Update documentation'
]

{ #category : #accessing }
CarpModule >> carpCoderStreamingMethodsFor: aView context: aPhlowContext [
	<gtModuleView>
	| aMethodsCoder aMethodsCoderViewModel aNewMethodCoderHolder |
	
	aMethodsCoder := GtStreamingCodersModel new.
	aMethodsCoderViewModel := GtStreamingCodersViewModel new streamingCodersModel: aMethodsCoder.
		
	aNewMethodCoderHolder := ValueHolder new.

	^ aView explicit
		priority: 9;
		title: 'Methods';
		disableAsync;
		actionDropdownButtonDo: [ :aDrodownAction | 
			aDrodownAction dropdown 
				icon: BrGlamorousVectorIcons add;
				tooltip: 'Add new expression';
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
				name: #'button--add-new-expression'];
		stencil: [ CarpStreamingMethodsCoderElement new streamingCodersViewModel: aMethodsCoderViewModel ]
]

{ #category : #initialization }
CarpModule >> initialize [
	uses := Set new.
	expressions := OrderedCollection new.
]

{ #category : #converting }
CarpModule >> name [
	^ name
]

{ #category : #accessing }
CarpModule >> name: aString [ 
	name := aString
]

{ #category : #converting }
CarpModule >> toCarp [

	^ String streamContents: [ :aStream | 
		  aStream << '(doc ' << self name << ' "' << self documentation
		  << '")' << Character lf.
		  aStream << '(defmodule ' << self name << ' ' << (uses
			   ifEmpty: [ '' ]
			   ifNotEmpty: [ 
			   Character lf , Character tab , '(use-all ' , (' ' join: uses)
			   , ')' ]).
		  expressions do: [ :expression | 
			  aStream << Character lf << Character tab << expression toCarp ].
		  aStream << ')' ]
]
