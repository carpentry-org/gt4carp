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
CarpDocumentationStyler >> tooltipFor: aName row: aRow coder: aCoder annotations: annotations [
	^ BrTextTooltipAttribute new
		stencil: [ :aContext |
			| documentation label |
			documentation := aCoder documentationFor: aName.
			label := aName asRopedText glamorousCodeSmallFont
					, (' : ' , (annotations prettify: (aRow at: 'type' ifAbsent: [ '' ]))) asRopedText
							glamorousCodeSmallFont foreground: BrGlamorousColors disabledButtonTextColor.
			documentation
				ifNotNil: [ label := label , String cr asRopedText
									, (documentation first: (documentation size min: 240)) asRopedText ].
			BrMenuExplicitHandle new
				menu: (BrMenuActionItem new
						label: label;
						action: [ :anElement :aButtonModel :anEvent |
							anElement phlow
								spawnObject: (CarpDefinition new
										name: aName;
										type: (aRow at: 'type' ifAbsent: [ '' ]);
										annotations: annotations;
										yourself) ]) ]
]
