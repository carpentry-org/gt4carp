Class {
	#name : #CarpTypeSignature,
	#superclass : #Object,
	#instVars : [
		'signature',
		'model',
		'tooltipsContainer'
	],
	#category : #'Carp-Coder'
}

{ #category : #'instance creation' }
CarpTypeSignature class >> on: aValue using: aModel [
	^ self new
		fromAST: aValue;
		model: aModel
]

{ #category : #accessing }
CarpTypeSignature >> elementsList [
	| tokens verticalContainer docsRegex |
	tokens := signature value source findTokens: ' () []'.
	docsRegex := 'Documentation\: (.*)' asRegexIgnoringCase.

	verticalContainer := BrVerticalPane new
			fitContent;
			padding: (BlInsets all: 10).

	tokens
		do: [ :each | 
			| res |
			res := model bindAndExecuteRaw: '(info ' , each , ')'.
			(docsRegex search: (res at: #value))
				ifTrue: [ | docs |
					docs := docsRegex subexpression: 2.
					verticalContainer
						addChild: (BrLabel new
								aptitude: BrGlamorousLabelAptitude new
										+ (GtExplainerExplanationAptitude new explanationModel: each)
										+ (BrStyleCommonAptitude new
												hovered: [ :aStyle | 
													aStyle background: BrGlamorousColors textHighlightColor.
													aStyle
														do: [ tooltipsContainer
																text: docs;
																visibility: BlVisibility visible ]
														after: [ tooltipsContainer
																text: '' asRopedText;
																visibility: BlVisibility gone ] ]);
								geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
								text: each;
								padding: (BlInsets all: 5)) ] ].

	(tokens includes: '<StaticLifetime>')
		ifTrue: [ verticalContainer
				addChild: (BrLabel new
						aptitude: BrGlamorousLabelAptitude new
								+ (GtExplainerExplanationAptitude new explanationModel: '<StaticLifetime>')
								+ (BrStyleCommonAptitude new
										hovered: [ :aStyle | 
											aStyle background: BrGlamorousColors textHighlightColor.
											aStyle
												do: [ tooltipsContainer
														text: 'is the default static lifetime of values (this lifetime includes the entire program run).';
														visibility: BlVisibility visible ]
												after: [ tooltipsContainer
														text: '' asRopedText;
														visibility: BlVisibility gone ] ]);
						geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
						text: '<StaticLifetime>';
						padding: (BlInsets all: 5)) ].

	(tokens includes: 'Fn')
		ifTrue: [ verticalContainer
				addChild: (BrLabel new
						aptitude: BrGlamorousLabelAptitude new
								+ (GtExplainerExplanationAptitude new explanationModel: 'Fn')
								+ (BrStyleCommonAptitude new
										hovered: [ :aStyle | 
											aStyle background: BrGlamorousColors textHighlightColor.
											aStyle
												do: [ tooltipsContainer
														text: 'is the function type and is read: ' asRopedText, '(Fn [<arguments>] <return type> <lifetime>).' asRopedText glamorousCodeFont;
														visibility: BlVisibility visible ]
												after: [ tooltipsContainer
														text: '' asRopedText;
														visibility: BlVisibility gone ] ]);
						geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
						text: 'Fn';
						padding: (BlInsets all: 5)) ].

	^ verticalContainer asScrollableElement
		constraintsDo: [ :c | 
			c horizontal fitContent.
			c vertical matchParent ];
		background: Color white;
		aptitude: BrShadowAptitude new
]

{ #category : #accessing }
CarpTypeSignature >> explainSignature [
	| mainContainer coderElement leftContainer rightContainer rightContainerLabel leftContainerLabel tooltipsTarget coder elementsContainer editor |
	mainContainer := BrHorizontalPane new
			matchParent;
			padding: (BlInsets all: 5).
	mainContainer explainer isExplanationHolder: true.

	leftContainer := BrVerticalPane new
			hFitContent;
			vMatchParent;
			padding: (BlInsets all: 5);
			margin: (BlInsets right: 20).

	rightContainer := BrVerticalPane new
			matchParent;
			padding: (BlInsets all: 5).

	tooltipsContainer := BrEditor new
			text: '' asRopedText;
			padding: (BlInsets all: 10);
			margin: (BlInsets
					top: 10
					right: 0
					bottom: 0
					left: 0);
			constraintsDo: [ :c | c horizontal matchParent ];
			visibility: BlVisibility gone;
			border: (BlBorder paint: BrGlamorousColors textHighlightColor width: 2);
			aptitude: BrShadowAptitude + BrGlamorousEditorAptitude;
			vFitContent;
			background: BrGlamorousColors textHighlightColor.

	tooltipsTarget := BrButton new
			constraintsDo: [ :c | c ignoreByLayout ];
			size: 0 @ 0;
			elevation: (BlRelativeElevation elevation: 10);
			geometry: BlCircleGeometry new.

	elementsContainer := self elementsList.

	leftContainerLabel := BrLabel new
			text: ('Type Elements:' asRopedText
					glamorousRegularFont;
					foreground: Color gray);
			aptitude: BrGlamorousLabelAptitude;
			hFitContent;
			margin: (BlInsets
					top: 0
					right: 0
					bottom: 5
					left: 0).
	rightContainerLabel := BrLabel new
			text: ('Type:' asRopedText
					glamorousRegularFont;
					foreground: Color gray);
			aptitude: BrGlamorousLabelAptitude;
			margin: (BlInsets
					top: 0
					right: 0
					bottom: 5
					left: 5).

	editor := BrEditorElement new
			constraintsDo: [ :c | 
				c horizontal matchParent.
				c vertical matchParent ];
			editor: (BrTextEditor new text: signature value source asRopedText glamorousCodeFont).

	leftContainer addChild: leftContainerLabel.
	leftContainer addChild: elementsContainer.

	rightContainer addChild: rightContainerLabel.
	rightContainer addChild: editor.
	rightContainer addChild: tooltipsContainer.

	mainContainer addChild: leftContainer.
	mainContainer addChild: rightContainer.

	^ mainContainer
]

{ #category : #accessing }
CarpTypeSignature >> fromAST: anASTNode [
	signature := anASTNode
]

{ #category : #accessing }
CarpTypeSignature >> gtLiveFor: aView [
	<gtView>
	^ aView explicit
		title: 'Signature';
		priority: 1;
		stencil: [ self explainSignature ]
]

{ #category : #accessing }
CarpTypeSignature >> model: aModel [
	model := aModel
]
