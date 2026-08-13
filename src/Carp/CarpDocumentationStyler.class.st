"
I put a definition's documentation one hover away: every symbol in the
coder that names something the session can see gets a tooltip with its
type and doc string, and clicking it dives into the
{{gtClass:name=CarpDefinition}}.

Types come from the annotation cache, which is already loaded. The doc
string is fetched on demand — the tooltip's stencil only runs when the
tooltip is actually shown — and cached per name on the coder, so styling
costs nothing extra.
"
Class {
	#name : #CarpDocumentationStyler,
	#superclass : #GtCoderAstStyler,
	#category : #'Carp-Coder'
}

{ #category : #comparing }
CarpDocumentationStyler >> = anObject [
	^ self class == anObject class
]

{ #category : #comparing }
CarpDocumentationStyler >> hash [
	^ self class hash
]

{ #category : #accessing }
CarpDocumentationStyler >> style: aText ast: theAst [
	| coder annotations |
	coder := self coderViewModel ifNotNil: [ :aViewModel | aViewModel coderModel ].
	(coder isKindOf: GtCarpCoderModel) ifFalse: [ ^ self ].
	annotations := coder typeAdornmentAnnotations.
	annotations ifNil: [ ^ self ].
	self
		symbolsIn: theAst
		do: [ :aNode |
			[ | row |
			row := annotations environmentRowNamed: aNode source.
			row
				ifNotNil: [ aText
						attribute: (self
								tooltipFor: aNode source
								row: row
								coder: coder
								annotations: annotations)
						from: aNode startPosition
						to: aNode stopPosition ] ]
				on: Error
				do: [ :e |  ] ]
]

{ #category : #accessing }
CarpDocumentationStyler >> symbolsIn: aNode do: aBlock [
	"Every name occurrence, callees included: in Carp the head of a call is
	a symbol like any other. A qualified name (String.append) parses as a
	module-or-type node wrapping the bare variable, so it is taken whole and
	not descended into — 'append' on its own names nothing."

	((aNode isKindOf: CarpModuleOrTypeNode) or: [ aNode isKindOf: CarpVariableNode ])
		ifTrue: [ ^ aBlock value: aNode ].
	[ aNode children do: [ :each | self symbolsIn: each do: aBlock ] ]
		on: Error
		do: [ :e |  ]
]

{ #category : #accessing }
CarpDocumentationStyler >> paragraphFor: aText width: aNumber [
	"A wrapping, read-only line of text. BrLabel is single-line — it does not
	even break on newlines — so a doc string needs an editor to wrap."

	^ BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithSelection;
		text: aText;
		constraintsDo: [ :c |
			c horizontal exact: aNumber.
			c vertical fitContent ]
]

{ #category : #accessing }
CarpDocumentationStyler >> tooltipContentFor: aName row: aRow coder: aCoder annotations: annotations [
	| element documentation signature |
	signature := aName asRopedText glamorousCodeFontAndSmallSize
			, ((' : ' , (annotations prettify: (aRow at: 'type' ifAbsent: [ '' ]))) asRopedText
					glamorousCodeFontAndSmallSize
					foreground: BrGlamorousColors disabledButtonTextColor).
	element := BlElement new
			layout: BlLinearLayout vertical;
			padding: (BlInsets all: 4);
			constraintsDo: [ :c |
				c horizontal fitContent.
				c vertical fitContent ];
			addChild: (self paragraphFor: signature width: 420).
	documentation := aCoder documentationFor: aName.
	documentation
		ifNotNil: [ element
				addChild: (self paragraphFor: documentation asRopedText glamorousRegularFont width: 420) ].
	^ element
]

{ #category : #accessing }
CarpDocumentationStyler >> tooltipFor: aName row: aRow coder: aCoder annotations: annotations [
	"Built the way BrTextTooltipAttribute>>#stencil: builds its own aptitude,
	but with an element instead of a menu item: a menu item is one clipped
	line, and a type plus a doc string needs two wrapping ones."

	^ BrTextTooltipAttribute new
		tooltipStencil: [ BrGlamorousWithExplicitTooltipAptitude new
				mouseEventHandler: BrTextTooltipMouseHoverEventHandler new;
				content: [ self
						tooltipContentFor: aName
						row: aRow
						coder: aCoder
						annotations: annotations ] ];
		yourself
]
