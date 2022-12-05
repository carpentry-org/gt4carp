Class {
	#name : #CarpStylerUtilities,
	#superclass : #Object,
	#category : #'Carp-Styler'
}

{ #category : #accessing }
CarpStylerUtilities class >> colorAndHighlightParenthesesLeft: aLeftIndex right: aRightIndex atNestingLevel: aNestingLevel inText: aText [
	self 
		highlightParenthesesLeft: aLeftIndex
		right: aRightIndex
		inText: aText.
	self 
		colorParenthesesLeft: aLeftIndex
		right: aRightIndex
		atNestingLevel: aNestingLevel
		inText: aText
]

{ #category : #accessing }
CarpStylerUtilities class >> colorParenthesesLeft: aLeftIndex right: aRightIndex atNestingLevel: aNestingLevel inText: aText [
	| color |
	color := self parenthesesColorAt: aNestingLevel.
	(aText
		from: aLeftIndex
		to: aLeftIndex)
		foreground: color.
	(aText
		from: aRightIndex
		to: aRightIndex)
		foreground: color
]

{ #category : #accessing }
CarpStylerUtilities class >> highlightParenthesesLeft: aLeftIndex right: aRightIndex inText: aText [ 
	| theParanthesesMarker cursorEnterAction cursorLeaveAction |
	
	theParanthesesMarker := BrTextInvisibleMarkerAttribute new.
	aText
		attribute: theParanthesesMarker
		from: aLeftIndex
		to: aRightIndex.

	cursorEnterAction := [ :aTextEditor |
		aTextEditor text
			findAttribute: theParanthesesMarker
			indicesDo: [ :aParanthesesStart :aParanthesesEnd |
				aTextEditor text
					attribute: (GtPharoParenthesesHighlightAttribute paint: BrGlamorousColors neutralBackgroundColor)
					from: aParanthesesStart
					to: aParanthesesEnd ] ].

	cursorLeaveAction := [ :aTextEditor | 
		aTextEditor text
			findAttribute: theParanthesesMarker
			indicesDo: [ :aParanthesesStart :aParanthesesEnd |
				(aTextEditor text
					from: aParanthesesStart
					to: aParanthesesEnd)
						clearAttributesOfClass: GtPharoParenthesesHighlightAttribute ] ].

	(aText
		from: aLeftIndex
		to: aLeftIndex)
		onCursorEnter: cursorEnterAction
		leave: cursorLeaveAction.

	(aText
		from: aRightIndex
		to: aRightIndex)
		onCursorEnter: cursorEnterAction
		leave: cursorLeaveAction
]

{ #category : #accessing }
CarpStylerUtilities class >> parenthesesColorAt: anIndex [
	| colors |
	colors := self parenthesesColors.
	^ colors at: (anIndex - 1) \\ colors size + 1
]

{ #category : #accessing }
CarpStylerUtilities class >> parenthesesColors [
	| colors |
	colors := BrGlamorousColors distinctTenStrongColors allButFirst allButLast
		collect: [ :each | each twiceDarker ].
	^ colors
]
