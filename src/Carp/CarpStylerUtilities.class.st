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

{ #category : #accessing }
CarpStylerUtilities class >> charPositionsByByteOffsetIn: aString [
	"UTF-8 byte offset at each character boundary -> 1-based character
	position. The compiler reports half-open BYTE spans; the editor indexes
	characters, so every span has to come through here."

	| map bytes |
	map := Dictionary new: aString size * 2.
	bytes := 0.
	aString
		doWithIndex: [ :ch :i |
			map at: bytes put: i.
			bytes := bytes + (self utf8SizeOf: ch) ].
	map at: bytes put: aString size + 1.
	^ map
]

{ #category : #accessing }
CarpStylerUtilities class >> utf8SizeOf: aCharacter [
	| codePoint |
	codePoint := aCharacter asInteger.
	codePoint < 128 ifTrue: [ ^ 1 ].
	codePoint < 2048 ifTrue: [ ^ 2 ].
	codePoint < 65536 ifTrue: [ ^ 3 ].
	^ 4
]
