Class {
	#name : #GtCarpRewrite,
	#superclass : #Object,
	#instVars : [
		'comment',
		'from',
		'to'
	],
	#category : #'Carp-Formatting'
}

{ #category : #accessing }
GtCarpRewrite class >> comment: aString from: aString1 to: aString2 [
	^ self new
		comment: aString;
		from: aString1;
		to: aString2
]

{ #category : #accessing }
GtCarpRewrite >> asSmaCCRewrite [
	^ SmaCCRewrite
		comment: self comment
		match: (SmaCCRewriteTreeMatch new source: self from)
		transformation: (SmaCCRewriteStringTransformation new string: self to)
]

{ #category : #accessing }
GtCarpRewrite >> comment [
	^ comment
]

{ #category : #accessing }
GtCarpRewrite >> comment: anObject [
	comment := anObject
]

{ #category : #accessing }
GtCarpRewrite >> from [
	^ from
]

{ #category : #accessing }
GtCarpRewrite >> from: anObject [
	from := anObject
]

{ #category : #accessing }
GtCarpRewrite >> gtCommentFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Comment';
		priority: 1;
		text: [ self comment ]
]

{ #category : #accessing }
GtCarpRewrite >> gtTransformFor: aView [
	<gtView>
	^ aView explicit
		title: 'Transformation';
		priority: 2;
		stencil: [ | overallElement transformElement |
			transformElement := BlElement new
					layout: BlLinearLayout vertical;
					constraintsDo: [ :c | 
						c linear vertical alignCenter.
						c vertical fitContent.
						c horizontal fitContent ];
					addChild: (BrLabel new
							aptitude: BrGlamorousLabelAptitude;
							text: self from asString;
							constraintsDo: [ :c | c linear horizontal alignCenter ]);
					addChild: (BrGlamorousIcons down asElement
							constraintsDo: [ :c | c linear horizontal alignCenter ]);
					addChild: (BrLabel new
							aptitude: BrGlamorousLabelAptitude;
							text: self to asString;
							constraintsDo: [ :c | c linear horizontal alignCenter ]).
			overallElement := BlElement new
					aptitude: BrShadowAptitude new;
					background: Color white;
					margin: (BlInsets all: 20);
					padding: (BlInsets all: 10);
					layout: BlLinearLayout horizontal;
					constraintsDo: [ :c | 
						c vertical fitContent.
						c horizontal fitContent.
						c frame horizontal alignCenter.
						c frame vertical alignCenter ];
					addChild: transformElement.
			BlElement new
				constraintsDo: [ :c | 
					c vertical matchParent.
					c horizontal matchParent ];
				layout: BlFrameLayout new;
				addChild: overallElement ]
]

{ #category : #accessing }
GtCarpRewrite >> to [
	^ to
]

{ #category : #accessing }
GtCarpRewrite >> to: anObject [
	to := anObject
]
