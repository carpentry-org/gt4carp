Class {
	#name : #CarpModuleCoderElement,
	#superclass : #BlElement,
	#traits : 'TBrLayoutResizable',
	#classTraits : 'TBrLayoutResizable classTrait',
	#instVars : [
		'carpCoderViewModel',
		'container',
		'contentPane',
		'contentTabs'
	],
	#category : #'Carp-Coder'
}

{ #category : #accessing }
CarpModuleCoderElement >> build [
	| application commandFactory |
	application := CarpApplication start.
	commandFactory := application newCommandFactory.

	^ commandFactory
		<< self module toCarp;
		sendAndWait
]

{ #category : #accessing }
CarpModuleCoderElement >> buildContentPane [

	contentPane := BlElement new.
	contentPane layout: BlLinearLayout vertical.
	contentPane constraintsDo: [ :c | 
		c horizontal matchParent.
		c vertical matchParent ].
	contentPane padding: (BlInsets top: 5 left: 6 bottom: 5 right: 6).
	contentPane addChild: self buildModuleLabel.
	contentPane addChild: self buildDefinitionElement.
	contentPane addChild: self buildContentTabs.

	^ contentPane
]

{ #category : #accessing }
CarpModuleCoderElement >> buildContentTabs [
	<return: #BrTabGroup>

	contentTabs := GtPhlowCompositeView new
		views: self classViewItems;
		asElementDo: [ :aBrTabGroup | aBrTabGroup ].

	^ contentTabs
]

{ #category : #accessing }
CarpModuleCoderElement >> buildDefinitionElement [
	^ CarpDefinitionsElement new module: self module
]

{ #category : #accessing }
CarpModuleCoderElement >> buildModuleLabel [

	| classCoder aModuleNameEditor aContainer aPreviewButton removeClassButton |
	aContainer := BrHorizontalPane new
		              hMatchParent;
		              alignCenterLeft;
		              vFitContent.

	aModuleNameEditor := BrEditableLabel new
		                     aptitude:
			                     (BrGlamorousEditableLabelAptitude new
				                      defaultBackground: Color transparent;
				                      glamorousCodeFont;
				                      bold;
				                      fontSize: 18);
		                     text: self module name;
		                     margin: (BlInsets all: 0);
		                     id: GtBehaviorCoderBehaviorNameId;
		                     whenKey: BlKeyCombination primaryG
		                     labelDo: [ :aShortcutEvent | 
		                     self phlow spawnObject: self module ];
		                     whenKey: BlKeyCombination primaryR
		                     labelDo: [ :aShortcutEvent | 
		                     aShortcutEvent currentTarget switchToEditor ];
		                     whenKey: BlKeyCombination primaryC
		                     labelDo: [ :aShortcutEvent | 
			                     Clipboard clipboardText:
				                     self module name asString ];
		                     when: BrEditorAcceptWish
		                     do: [ :aWish | 
		                     self module name: aWish text asString ].

	aContainer addChild: aModuleNameEditor.

	aContainer addChild: (BrFrame new
			 vFitContent;
			 hMatchParent).

	aContainer addChild: (BrButton new
			 aptitude: BrGlamorousButtonWithIconAptitude;
			 icon: BrGlamorousVectorIcons play;
			 beSmallSize;
			 label: 'Generate source';
			 action: [ :aButton | 
				 aButton phlow spawnObject: self module toCarp ]).

	aContainer addChild: (BrButton new
			 aptitude: BrGlamorousButtonWithIconAptitude;
			 icon: BrGlamorousVectorIcons refresh;
			 beSmallSize;
			 label: 'Build';
			 action: [ self build ]).

	^ aContainer
]

{ #category : #accessing }
CarpModuleCoderElement >> classViewItems [
	| classCoder collector context |
	
	classCoder := carpCoderViewModel coder.
	
	collector := GtPhlowViewsCollector new
		fromObject: classCoder module;
		from: classCoder module class;
		to: Behavior;
		pragmaName: #gtModuleView.

	context := GtPhlowContext new.
	context optionAt: #carpCoder put: carpCoderViewModel.

	collector context: context.

	^ collector collect
]

{ #category : #accessing }
CarpModuleCoderElement >> coderViewModel: aCarpCoderViewModel [
	
	carpCoderViewModel ifNotNil: [ :aPreviousCoderViewModel | aPreviousCoderViewModel unsubscribe: self ].
	
	carpCoderViewModel := aCarpCoderViewModel.
	"carpCoderViewModel coder weak
		when: GtCoderPackageUpdatedAnnouncement
			send: #actOnPackageUpdated:
			to: self;
		when: GtClassCoderMethodNavigationAnnouncement
			send: #actOnSelectMethod:
			to: self;
		when: GtClassCoderMethodProtocolNavigationAnnouncement
			send: #actOnMethodProtocol:
			to: self."

	container ifNotNil: #removeFromParent.
	container := self buildContentPane.
	self addChildFirst: container.
	self build
]

{ #category : #accessing }
CarpModuleCoderElement >> initialize [
	super initialize.

	self
		layout: BlLinearLayout vertical;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ].
		
	self when: BlClickEvent do: [ self requestFocus ]
]

{ #category : #accessing }
CarpModuleCoderElement >> module [
	^ carpCoderViewModel coder module
]
