"
I complete Carp symbols in a coder from the session's warm compiler state:
the server's `complete` command answers every visible global (core and
session definitions) matching the prefix.
"
Class {
	#name : #CarpCompletionStrategy,
	#superclass : #GtStreamedCompletionStrategy,
	#instVars : [
		'coder'
	],
	#category : #'Carp-Coder'
}

{ #category : #accessing }
CarpCompletionStrategy >> coder [
	^ coder
]

{ #category : #accessing }
CarpCompletionStrategy >> coder: aCoder [
	coder := aCoder
]

{ #category : #accessing }
CarpCompletionStrategy >> completionActionStreamFor: aText at: positionInteger requested: isRequested [
	"Build actions from the server's full candidate rows so the popup can
	show kind and scheme, not just the name."

	| prefix |
	prefix := self completionPrefixAt: positionInteger in: aText.
	isRequested
		ifFalse: [ (prefix isNil or: [ prefix size < self minimumPrefixLength ])
				ifTrue: [ ^ #() asAsyncStream ] ].
	prefix := prefix ifNil: [ '' ].
	^ (self completionRowsStartingWith: prefix)
		collect: [ :row |
			GtInsertTextCompletionAction
				labeled: (self labelForRow: row withSearch: prefix)
				completion: ((row at: 'name') allButFirst: prefix size)
				position: positionInteger ]
]

{ #category : #accessing }
CarpCompletionStrategy >> completionRowsStartingWith: aPrefixString [
	aPrefixString isEmpty ifTrue: [ ^ #() asAsyncStream ].
	^ ([ CarpServerClient default
			completePrefix: aPrefixString
			session: coder sessionId ]
			on: Error
			do: [ :e | #() ]) asAsyncStream
]

{ #category : #accessing }
CarpCompletionStrategy >> labelForRow: aRow withSearch: aPrefix [
	"The candidate's name with the matched characters highlighted, its kind
	and (truncated) scheme appended muted."

	| text detail |
	text := self labelFor: (aRow at: 'name') withSearch: aPrefix.
	detail := String
			streamContents: [ :s |
				| kind scheme |
				kind := aRow at: 'kind' ifAbsent: [ '' ].
				scheme := aRow at: 'scheme' ifAbsent: [ '' ].
				(kind isString and: [ kind notEmpty ])
					ifTrue: [ s nextPutAll: ' '; nextPutAll: kind ].
				(scheme isString and: [ scheme notEmpty ])
					ifTrue: [ s nextPutAll: ' '.
						s nextPutAll: (scheme size <= 40
							ifTrue: [ scheme ]
							ifFalse: [ (scheme first: 39) , '…' ]) ] ].
	detail
		ifNotEmpty: [ text
				append: (detail asRopedText glamorousCodeFont
						foreground: BrGlamorousColors disabledButtonTextColor) ].
	^ text
]

{ #category : #accessing }
CarpCompletionStrategy >> isSeparatorCharacter: aCharacter [
	"Carp symbols include -, ., !, ?, arithmetic and comparison characters;
	only whitespace, delimiters and reader sigils separate them."

	^ aCharacter isSeparator
		or: [ '()[]{}";@&~,''' includes: aCharacter ]
]

{ #category : #accessing }
CarpCompletionStrategy >> minimumPrefixLength [
	^ 2
]
