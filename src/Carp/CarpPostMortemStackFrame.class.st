Class {
	#name : #CarpPostMortemStackFrame,
	#superclass : #GtJavaScriptPostMortemStackFrame,
	#instVars : [
		'source'
	],
	#category : #'Carp-Debugger'
}

{ #category : #accessing }
CarpPostMortemStackFrame >> source: aString [
	source := aString
]

{ #category : #accessing }
CarpPostMortemStackFrame >> sourceText [
	| mySource text indexes lineNumber |
	file exists
		ifTrue: [ mySource := file contents.
			lineNumber := line ]
		ifFalse: [ ^ source asRopedText
				attribute: (BlTextHighlightAttribute paint: BrGlamorousColors errorBackgroundColor)
						beNotOverwritableByStyler ].
	text := mySource asRopedText.
	indexes := mySource gtIndexOfLineNumber: lineNumber.
	indexes
		ifNotNil: [ (text from: indexes key + column - 1 to: indexes value)
				attribute: (BlTextHighlightAttribute paint: BrGlamorousColors errorBackgroundColor)
						beNotOverwritableByStyler ].
	^ text
]
