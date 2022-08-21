Class {
	#name : #CarpEsugSlideShow,
	#superclass : #PrioritySlideshow,
	#category : #'Carp-Presentations'
}

{ #category : #accessing }
CarpEsugSlideShow >> carpAppetizerFor: aSlide [
	<gtSlide>
	^ aSlide textAndElement
		priority: (self priorityFor: #carpAppetizerFor:);
		newTextWithFormat: (self asHeader: 'Enter gt4carp') bold
				, (self
						asText: '
representing an IDE for a static language');
		element: [ GtPager createWrappedOn: (CarpModuleCoder forModule: self exampleModule) ]
]

{ #category : #accessing }
CarpEsugSlideShow >> carpAppetizerTwoFor: aSlide [
	<gtSlide>
	^ aSlide textAndElement
		priority: (self priorityFor: #carpAppetizerTwoFor:);
		newTextWithFormat: (self asHeader: 'Enter gt4carp') bold
				, (self
						asText: '
... and an integration into Lepiter');
		element: [ GtPager
				createOn: (GtPagerWrapperElement new
						tool: ((GtCarpCoderModel code: self exampleCode)
								carpLinkApplicationStrategy: LeCarpApplicationStrategy new)
								initializeApplication asElement;
						embellisher: (GtPagerPageEmbellisher new extension: GtPagerPageEmbellisherExtension null)) ]
]

{ #category : #accessing }
CarpEsugSlideShow >> carpBookFor: aSlide [
	<gtSlide>
	
	^ (aSlide lepiterPage)
		priority: (self priorityFor: #carpBookFor:);
		pageNamed: 'Adding a Language to Glamorous Toolkit' from: 'Adding a Language to Glamorous Toolkit'
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
		carpAppetizerTwoFor:
		carpDefFor:
		carpMotivationFor:
		carpBookFor:
	)
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
CarpEsugSlideShow >> titleSlideFor: aSlide [
	<gtSlide>
	
	^ (aSlide title)
		priority: (self priorityFor: #titleSlideFor:);
		titleBottomPadding: 30;
		titleWithFormat: (self asTitle: 'Implementing an IDE in GT');
		subtitleWithFormat: (self asBigText: 'Veit Heller (@hellerve)')
]
