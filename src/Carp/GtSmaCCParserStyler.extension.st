Extension { #name : #GtSmaCCParserStyler }

{ #category : #'*Carp' }
GtSmaCCParserStyler class >> carpStyler: aParserClass [

	<smaccStyler: #CarpParser priority: 50>
	^ (self forParser: aParserClass) stylerRules: { 
			  (GtSmaCCKeywordTokensStylerRule styleBlock: [ :styler | 
				   styler
					   bold;
					   foreground: Color purple ]).
			  (GtSmaCCCommentStylerRule styleBlock: [ :styler | 
				   styler foreground: Color lightGray ]).
			  (GtSmaCCNodeStylerRule
				   nodeClassName: #CarpNumberNode
				   styleBlock: [ :styler | styler foreground: Color blue ]).
			  (GtSmaCCNodeStylerRule
				   nodeClassName: #CarpStringNode
				   styleBlock: [ :styler | styler foreground: Color blue ]).
			  (GtSmaCCNodeStylerRule
				   nodeClassName: #CarpPatternNode
				   styleBlock: [ :styler | styler foreground: Color blue ]).
			  (GtSmaCCNodeStylerRule
				   nodeClassName: #CarpListNode
				   styleBlock: [ :styler :node :text | 
					   (node expressions notEmpty and: [ 
						    ((node expressions first isKindOf: CarpVariableNode) or:
							     (node expressions first isKindOf: CarpModuleOrTypeNode)) 
							    and: [ node isQuoted not ] ]) ifTrue: [ 
						   (text
							    from: node expressions first startPosition
							    to: node expressions first stopPosition) foreground:
							   Color purple ].
					   CarpStylerUtilities
						   colorAndHighlightParenthesesLeft: node startPosition
						   right: node stopPosition
						   atNestingLevel: node listDepth
						   inText: text ]).
			  (GtSmaCCNodeStylerRule
				   nodeClassName: #CarpMapNode
				   styleBlock: [ :styler :node :text | 
					   CarpStylerUtilities
						   colorAndHighlightParenthesesLeft: node startPosition
						   right: node stopPosition
						   atNestingLevel: node listDepth
						   inText: text ]).
			  (GtSmaCCNodeStylerRule
				   nodeClassName: #CarpArrayNode
				   styleBlock: [ :styler :node :text | 
					   CarpStylerUtilities
						   colorAndHighlightParenthesesLeft: node startPosition
						   right: node stopPosition
						   atNestingLevel: node listDepth
						   inText: text ]).
			  (GtSmaCCNodeStylerRule
				   nodeClassName: #CarpVariableNode
				   styleBlock: [ :styler | styler italic ]).
			  (GtSmaCCNodeStylerRule
				   nodeClassName: #CarpModuleOrTypeNode
				   styleBlock: [ :styler :node :text | 
					   (text
						    from: node module startPosition
						    to: node module stopPosition) foreground: Color orange ]).
			  (GtSmaCCNodeVariableStylerRule
				   nodeClassName: #SmaCCErrorNode
				   variableNames: #( dismissedTokens errorToken )
				   styleBlock: [ :styler | styler foreground: Color red ]) }
]
