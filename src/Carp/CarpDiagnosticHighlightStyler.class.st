"
I mark the forms the compiler rejected: each diagnostic from the coder's
annotation cache underlines its span in red, with the phase and message in
a tooltip.

A cell that does not check is not an error to the annotate command — it
answers its diagnostics like any other report — so this runs on the same
asynchronously refreshed cache as {{gtClass:name=CarpTypeAdornmentStyler}}
and marks nothing while that cache is stale.
"
Class {
	#name : #CarpDiagnosticHighlightStyler,
	#superclass : #GtCoderAstStyler,
	#category : #'Carp-Coder'
}

{ #category : #comparing }
CarpDiagnosticHighlightStyler >> = anObject [
	^ self class == anObject class
]

{ #category : #comparing }
CarpDiagnosticHighlightStyler >> hash [
	^ self class hash
]

{ #category : #accessing }
CarpDiagnosticHighlightStyler >> messageOf: aDiagnostic [
	| phase message |
	message := aDiagnostic at: 'message' ifAbsent: [ '' ].
	phase := aDiagnostic at: 'phase' ifAbsent: [ '' ].
	^ phase isEmpty
		ifTrue: [ message ]
		ifFalse: [ phase , ': ' , message ]
]

{ #category : #accessing }
CarpDiagnosticHighlightStyler >> style: aText ast: theAst [
	| coder annotations diagnostics string byteMap |
	coder := self coderViewModel ifNotNil: [ :aViewModel | aViewModel coderModel ].
	(coder isKindOf: GtCarpCoderModel) ifFalse: [ ^ self ].
	annotations := coder typeAdornmentAnnotations.
	annotations ifNil: [ ^ self ].
	diagnostics := annotations diagnostics.
	diagnostics ifEmpty: [ ^ self ].
	string := aText asString.
	byteMap := CarpStylerUtilities charPositionsByByteOffsetIn: string.
	diagnostics
		do: [ :each |
			[ | from to |
			from := self
					characterAt: (each at: 'start' ifAbsent: [ nil ])
					in: byteMap.
			to := self characterAt: (each at: 'end' ifAbsent: [ nil ]) in: byteMap.
			(from notNil and: [ to notNil and: [ from <= string size ] ])
				ifTrue: [ | stop |
					stop := ((to - 1) max: from) min: string size.
					(aText from: from to: stop)
						underlineColor: BrGlamorousColors errorBackgroundColor twiceDarker thickness: 2;
						attribute: (self tooltipAttributeFor: each) ] ]
				on: Error
				do: [ :e |  ] ]
]

{ #category : #accessing }
CarpDiagnosticHighlightStyler >> characterAt: aByteOffset in: aByteToCharMap [
	"Spans are half-open UTF-8 byte ranges; answer nil for an offset that is
	not a character boundary of this text (a stale span, say)."

	aByteOffset ifNil: [ ^ nil ].
	^ aByteToCharMap at: aByteOffset asInteger ifAbsent: [ nil ]
]

{ #category : #accessing }
CarpDiagnosticHighlightStyler >> tooltipAttributeFor: aDiagnostic [
	^ BrTextTooltipAttribute new text: (self messageOf: aDiagnostic)
]
