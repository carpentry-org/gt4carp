Class {
	#name : #CarpPostMortemDebugger,
	#superclass : #Object,
	#instVars : [
		'exception',
		'stackFrames',
		'frameRegex'
	],
	#category : #'Carp-Debugger'
}

{ #category : #accessing }
CarpPostMortemDebugger >> exception [
	^ exception
]

{ #category : #accessing }
CarpPostMortemDebugger >> exception: anException [
	exception := anException
]

{ #category : #accessing }
CarpPostMortemDebugger >> findTrace: inputLines [
	| lines |
	lines := inputLines asOrderedCollection.
	[ lines isNotEmpty and: [ (lines first = 'Traceback:') not ] ]
		whileTrue: [ lines removeFirst ].
	^ lines
]

{ #category : #accessing }
CarpPostMortemDebugger >> initialize [

	super initialize.
	frameRegex := '(.*)\s+at\s+([^:]+)\:(\d+)\:(\d+)\.' asRegexIgnoringCase.
]

{ #category : #accessing }
CarpPostMortemDebugger >> sourceStyler [
	"Answer the styler used by the source code editor for this exception"

	^ CarpParser gtStyler
]

{ #category : #accessing }
CarpPostMortemDebugger >> stackFrameFromLine: aString ordinal: ordinal [
	"Answer a frame if the supplied string contains a valid file and line number, or nil"
	<return: #GtPythonPostMortemStackFrame or: nil>
	| file line column source |

	^ (frameRegex search: aString) ifTrue:
		[ source := frameRegex subexpression: 2.
		file := frameRegex subexpression: 3.
		line := frameRegex subexpression: 4.
		column := frameRegex subexpression: 5.
		CarpPostMortemStackFrame new
				ordinal: ordinal;
				displayString: aString;
				exception: exception;
				source: source;
				file: file asFileReference;
				line: line asNumber;
				column: column asNumber ]
	ifFalse:
		[ nil ]

]

{ #category : #accessing }
CarpPostMortemDebugger >> stackFrames [
	"Answer a ordered collection of stack frames.
	This is called many times by the debugger, so cache"

	| ordinal |
	^ stackFrames
		ifNil: [ ordinal := 1.
			stackFrames := OrderedCollection new.
			(self findTrace: exception trace lines)
				do: [ :line | 
					(self stackFrameFromLine: line ordinal: ordinal)
						ifNotNil: [ :frame | 
							stackFrames add: frame.
							ordinal := ordinal + 1 ] ].
			(exception trace lines last beginsWith: '[RUNTIME ERROR]')
				ifTrue: [ stackFrames
						add: (CarpPostMortemStackFrame new
								ordinal: 1;
								displayString: exception trace lines last;
								exception: exception;
								source: exception trace lines last;
								file: 'REPL' asFileReference;
								line: 0;
								column: 0) ].
			stackFrames ]
]

{ #category : #accessing }
CarpPostMortemDebugger >> stderr [
	^ exception application stderr
]

{ #category : #accessing }
CarpPostMortemDebugger >> stdout [
	^ exception application stdout
]
