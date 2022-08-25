Class {
	#name : #CarpEsugSlideShow,
	#superclass : #PrioritySlideshow,
	#category : #'Carp-Presentations'
}

{ #category : #accessing }
CarpEsugSlideShow >> blastFor: aSlide [
	<gtSlide>
	
	^ (aSlide element)
		priority: (self priorityFor: #blastFor:);
		element: [ GtPager createWrappedOn: (CarpModuleCoder forModule: self exampleModule) ]
]

{ #category : #accessing }
CarpEsugSlideShow >> carpAppetizerExpandedFor: aSlide [
	<gtSlide>
	^ aSlide element
		priority: (self priorityFor: #carpAppetizerExpandedFor:);
		element: [ GtPager createWrappedOn: (CarpModuleCoder forModule: self exampleModule) ]
]

{ #category : #accessing }
CarpEsugSlideShow >> carpAppetizerFor: aSlide [
	<gtSlide>
	^ aSlide element
		priority: (self priorityFor: #carpAppetizerFor:);
		element: [ BlElement new
				layout: BlFrameLayout new;
				constraintsDo: [ :c | 
					c horizontal matchParent.
					c vertical matchParent ];
				addChild: (BlElement new
						aptitude: BrShadowAptitude;
						background: Color white;
						layout: BlLinearLayout new;
						constraintsDo: [ :c | 
							c frame horizontal alignCenter.
							c frame vertical alignCenter.
							c horizontal fitContent.
							c vertical matchParent ];
						padding: (BlInsets all: 10);
						margin: (BlInsets all: 10);
						addChild: (CarpModuleCoder forModule: self exampleModule) asElement hFitContent
								vMatchParent) ]
]

{ #category : #accessing }
CarpEsugSlideShow >> carpAppetizerTwoExpandedFor: aSlide [
	<gtSlide>
	^ aSlide element
		priority: (self priorityFor: #carpAppetizerTwoExpandedFor:);
		element: [ GtPager
				createWrappedOn: ((GtCarpCoderModel code: self exampleCode)
						carpLinkApplicationStrategy: LeCarpApplicationStrategy new)
						initializeApplication asElement ]
]

{ #category : #accessing }
CarpEsugSlideShow >> carpAppetizerTwoFor: aSlide [
	<gtSlide>
	^ aSlide element
		priority: (self priorityFor: #carpAppetizerTwoFor:);
		element: [ ((GtCarpCoderModel code: self exampleCode)
						carpLinkApplicationStrategy: LeCarpApplicationStrategy new)
						initializeApplication asElement hFitContent ]
]

{ #category : #accessing }
CarpEsugSlideShow >> carpBookFor: aSlide [
	<gtSlide>
	
	^ (aSlide lepiterPage)
		priority: (self priorityFor: #carpBookFor:);
		pageNamed: 'Adding a Language to Glamorous Toolkit' from: 'Adding a Language to Glamorous Toolkit'
]

{ #category : #accessing }
CarpEsugSlideShow >> carpDebuggerFor: aSlide [
	<gtSlide>
	^ aSlide element
		priority: (self priorityFor: #carpDebuggerFor:);
		element: [ ((GtCarpCoderModel code: self exampleWrongCode)
						carpLinkApplicationStrategy: LeCarpApplicationStrategy new)
						initializeApplication asElement hFitContent ]
]

{ #category : #accessing }
CarpEsugSlideShow >> carpDefFor: aSlide [
	<gtSlide>
	
	^ (aSlide paragraph)
		priority: (self priorityFor: #carpDefFor:);
		subtitleWithFormat: (self asSubtitle: 'Wait—What’s Carp?');
		paragraphWithFormat:
				(self
						asText:
							'
Carp is a statically compiled Lisp-y programming language sporting
• macros,
• type inference,
• and borrow-checking (as in Rust).
')
]

{ #category : #accessing }
CarpEsugSlideShow >> carpMotivationFor: aSlide [
	<gtSlide>
	^ aSlide title
		priority: (self priorityFor: #carpMotivationFor:);
		titleWithFormat: (self asTitle: 'It is a perfect challenge.');
		subtitleWithFormat: (self asText: 'If I can make this work, I can make any language work.')
]

{ #category : #accessing }
CarpEsugSlideShow >> exampleCode [
	^ '(defn main []
  (IO.println
    &(case (+ 0 1)
      1 @"okay"
      2 @"not okay at all"
      @"what is happening?")))'
]

{ #category : #accessing }
CarpEsugSlideShow >> exampleModule [
	^ 'Example' asCarpModule
		documentation: 'Example Module documentation';
		addUse: 'Test.carp';
		addExpression: (CarpDynamicVariable named: 'x' asCarpSymbol binding: 1 asCarpInteger);
		addExpression: (CarpStaticFunction
				named: 'fun' asCarpSymbol
				withArguments: {'a' asCarpSymbol.
						'b' asCarpSymbol}
				andBody: (CarpCall
						function: '+' asCarpSymbol
						arguments: {CarpCall function: 'from-int' asCarpSymbol arguments: {'a' asCarpSymbol}.
								'b' asCarpSymbol}))
]

{ #category : #accessing }
CarpEsugSlideShow >> exampleWrongCode [
	^ '(case true
true "missing a case")'
]

{ #category : #accessing }
CarpEsugSlideShow >> highlighterFor: aSlide [
	<gtSlide>
	^ aSlide element
		priority: (self priorityFor: #highlighterFor:);
		element: [ GtPager
				createWrappedOn: (GtCoder forMethod: GtSmaCCParserStyler class >> #carpStyler:) ]
]

{ #category : #accessing }
CarpEsugSlideShow >> ingredientsFor: aSlide [
	<gtSlide>
	
	^ (aSlide paragraph)
		priority: (self priorityFor: #ingredientsFor:);
		subtitleWithFormat: (self asSubtitle: 'Ingredients');
		paragraphWithFormat:
				(self
						asText:
							'
• One SmaCC parser
• One syntax highlighter
• One LanguageLink integration
• One custom snippet type
• A handful of weekends
• Views to taste
')
]

{ #category : #accessing }
CarpEsugSlideShow >> languageLinkFor: aSlide [
	<gtSlide>
	^ aSlide element
		priority: (self priorityFor: #languageLinkFor:);
		element: [ GtPager createWrappedOn: (GtCoder forMethod: LanguageLinkSettings class>>#carpDefaultSettings) ]
]

{ #category : #accessing }
CarpEsugSlideShow >> motivationFor: aSlide [
	<gtSlide>
	
	^ (aSlide paragraph)
		priority: (self priorityFor: #motivationFor:);
		subtitleWithFormat: (self asSubtitle: 'Why?');
		paragraphWithFormat:
				(self
						asText:
							'
• IDEs done right are delightful
• But we don’t spend the time
• So we resort to text editors
• We read text, we write text, we think in text
')
]

{ #category : #accessing }
CarpEsugSlideShow >> pages [
	<gtExample>
	^ #(
		titleSlideFor:
		motivationFor:
		revealFor:
		carpAppetizerFor:
		carpAppetizerExpandedFor:
		carpAppetizerTwoFor:
		carpAppetizerTwoExpandedFor:
		carpDebuggerFor:
		carpDefFor:
		carpMotivationFor:
		carpBookFor:
		ingredientsFor:
		parserFor:
		highlighterFor:
		languageLinkFor:
		snippetFor:
		woahFor:
		phewFor:
		takeawayFor:
		blastFor:
	)
]

{ #category : #accessing }
CarpEsugSlideShow >> parserFor: aSlide [
	<gtSlide>
	^ aSlide element
		priority: (self priorityFor: #parserFor:);
		element: [ GtPager createWrappedOn: (GtCoder forClass: CarpParser) ]
]

{ #category : #accessing }
CarpEsugSlideShow >> phewFor: aSlide [
	<gtSlide>
	
	^ (aSlide title)
		priority: (self priorityFor: #phewFor:);
		titleBottomPadding: 30;
		titleWithFormat: (self asTitle: 'But was it?');
		subtitleWithFormat: (self asSubtitle: 'We just built an IDE!')
]

{ #category : #accessing }
CarpEsugSlideShow >> revealFor: aSlide [
	<gtSlide>
	
	^ (aSlide title)
		priority: (self priorityFor: #revealFor:);
		titleBottomPadding: 30;
		titleWithFormat: (self asTitle: 'We can do better.')
]

{ #category : #accessing }
CarpEsugSlideShow >> snippetFor: aSlide [
	<gtSlide>
	^ aSlide element
		priority: (self priorityFor: #snippetFor:);
		element: [ GtPager createWrappedOn: (GtCoder forClass: LeCarpSnippet) ]
]

{ #category : #accessing }
CarpEsugSlideShow >> takeawayFor: aSlide [
	<gtSlide>
	
	^ (aSlide paragraph)
		priority: (self priorityFor: #takeawayFor:);
		subtitleWithFormat: (self asSubtitle: 'Takeaway');
		paragraphWithFormat:
				(self
						asText:
							'
• A non-trivial amount of work goes into building an IDE (duh!)
• Most of it happens not in code, but in thinking about useful interactions and abstractions
• And it can be done by a single father of a toddler in a few rare spare moments
')
]

{ #category : #accessing }
CarpEsugSlideShow >> titleSlideFor: aSlide [
	<gtSlide>
	
	^ (aSlide title)
		priority: (self priorityFor: #titleSlideFor:);
		titleBottomPadding: 30;
		titleWithFormat: (self asTitle: 'Implementing an IDE in GT');
		subtitleWithFormat: (self asBigText: 'Veit Heller (@hellerve)')
]

{ #category : #accessing }
CarpEsugSlideShow >> woahFor: aSlide [
	<gtSlide>
	
	^ (aSlide title)
		priority: (self priorityFor: #woahFor:);
		titleBottomPadding: 30;
		titleWithFormat: (self asTitle: 'That was a lot!')
]
