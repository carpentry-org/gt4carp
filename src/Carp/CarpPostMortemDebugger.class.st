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
CarpPostMortemDebugger >> initialize [

	super initialize.
	frameRegex := '\s+at.+\(([^:]+)\:(\d+)\:(\d+)\)' asRegexIgnoringCase.
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
	| file line column |

	^ (frameRegex search: aString) ifTrue:
		[ file := frameRegex subexpression: 2.
		line := frameRegex subexpression: 3.
		column := frameRegex subexpression: 4.
		CarpPostMortemStackFrame new
				ordinal: ordinal;
				displayString: aString;
				exception: exception;
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

	^ stackFrames ifNil:
		[ ordinal := 1.
		stackFrames := OrderedCollection new.
		exception trace lines do: [ :line | 
			(self stackFrameFromLine: line ordinal: ordinal) ifNotNil: [ :frame | 
				stackFrames add: frame.
				ordinal := ordinal + 1 ] ].
		stackFrames ].

]

{ #category : #accessing }
CarpPostMortemDebugger >> stderr [
	^ exception application stderr
]

{ #category : #accessing }
CarpPostMortemDebugger >> stdout [
	^ exception application stdout
]
