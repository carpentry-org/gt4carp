"
I render an inferred type inline in a Carp coder, appended after a
top-level form — dim, part of the editor, and clickable: selecting me dives
into the {{gtClass:name=CarpDefinition}} behind the type.
"
Class {
	#name : #CarpTypeAdornmentAttribute,
	#superclass : #BrTextAdornmentAttribute,
	#instVars : [
		'label',
		'definition'
	],
	#category : #'Carp-Coder'
}

{ #category : #comparing }
CarpTypeAdornmentAttribute >> = anObject [
	^ self class == anObject class and: [ label = anObject label ]
]

{ #category : #accessing }
CarpTypeAdornmentAttribute >> definition [
	^ definition
]

{ #category : #accessing }
CarpTypeAdornmentAttribute >> definition: aCarpDefinition [
	definition := aCarpDefinition
]

{ #category : #accessing }
CarpTypeAdornmentAttribute >> doAffect: aTBrTextEditorTextualPiece in: anEditorElement [
	<return: #SequenceableCollection of: #BlElement>
	| element |
	element := BlTextElement new
			labelMeasurement;
			"a bare BlTextElement gets inlined as paragraph TEXT by
			BrTextEditorParagraphElement>>#buildParagraph, shifting all cursor
			and selection indices by the label length; a non-nil aptitude
			routes it down the placeholder (charLength: 0) path instead"
			aptitude: BrAptitude new;
			text: (label asRopedText
					glamorousCodeFont;
					foreground: BrGlamorousColors disabledButtonTextColor;
					yourself);
			yourself.
	definition
		ifNotNil: [ element
				addEventHandler: (BlEventHandler
						on: BlClickEvent
						do: [ :anEvent |
							anEvent consumed: true.
							anEvent currentTarget phlow spawnObject: definition ]) ].
	^ {element}
]

{ #category : #comparing }
CarpTypeAdornmentAttribute >> hash [
	^ label hash
]

{ #category : #initialization }
CarpTypeAdornmentAttribute >> initialize [
	super initialize.
	self beAppend
]

{ #category : #accessing }
CarpTypeAdornmentAttribute >> label [
	^ label
]

{ #category : #accessing }
CarpTypeAdornmentAttribute >> label: aString [
	label := aString
]
