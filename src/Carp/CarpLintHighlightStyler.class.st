"
I underline angler findings inline: the offending form gets an orange
underline, and its tooltip names the rule and message; clicking the tooltip
dives into the {{gtClass:name=CarpLintFinding}}.

angler is fast (single-digit milliseconds), so I run it synchronously in
the styling pass, cached by text hash on the coder.
"
Class {
	#name : #CarpLintHighlightStyler,
	#superclass : #GtCoderAstStyler,
	#category : #'Carp-Coder'
}

{ #category : #comparing }
CarpLintHighlightStyler >> = anObject [
	^ self class == anObject class
]

{ #category : #comparing }
CarpLintHighlightStyler >> hash [
	^ self class hash
]

{ #category : #accessing }
CarpLintHighlightStyler >> lineStartOffsetsOf: aString [
	| offsets next |
	offsets := OrderedCollection with: 1.
	next := 1.
	aString doWithIndex: [ :char :index |
		char = Character lf ifTrue: [ offsets add: index + 1 ] ].
	^ offsets
]

{ #category : #accessing }
CarpLintHighlightStyler >> nodeStartingAt: aPosition in: aNode [
	"The outermost parse node starting exactly at the finding's position."

	aNode startPosition = aPosition ifTrue: [ ^ aNode ].
	(aNode startPosition <= aPosition and: [ aPosition <= aNode stopPosition ])
		ifFalse: [ ^ nil ].
	aNode children
		do: [ :child | (self nodeStartingAt: aPosition in: child) ifNotNil: [ :found | ^ found ] ].
	^ nil
]

{ #category : #accessing }
CarpLintHighlightStyler >> style: aText ast: theAst [
	| coder findings string lineStarts |
	coder := self coderViewModel ifNotNil: [ :vm | vm coderModel ].
	(coder isKindOf: GtCarpCoderModel) ifFalse: [ ^ self ].
	string := aText asString.
	findings := [ coder lintFindingsFor: string ] on: Error do: [ :e | #() ].
	findings ifEmpty: [ ^ self ].
	lineStarts := self lineStartOffsetsOf: string.
	findings
		do: [ :finding |
			[ | start stop |
			start := (lineStarts at: finding line) + finding column - 1.
			start <= string size
				ifTrue: [ stop := (self nodeStartingAt: start in: theAst)
							ifNotNil: [ :node | node stopPosition ]
							ifNil: [ start + (finding form size max: 1) - 1 min: string size ].
					(aText from: start to: stop)
						underlineColor: (Color r: 0.9 g: 0.55 b: 0.1) thickness: 2;
						attribute: (self tooltipAttributeFor: finding) ] ]
				on: Error
				do: [ :e |  ] ]
]

{ #category : #accessing }
CarpLintHighlightStyler >> tooltipAttributeFor: aFinding [
	^ BrTextTooltipAttribute new
		stencil: [ :aContext |
			BrMenuExplicitHandle new
				menu: (BrMenuActionItem new
						label: '[' , aFinding rule , '] ' , aFinding message;
						action: [ :anElement :aButtonModel :anEvent |
							anElement phlow spawnObject: aFinding ]) ]
]
