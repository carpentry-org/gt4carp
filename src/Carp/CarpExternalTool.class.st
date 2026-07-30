"
I run the standard Carp command-line tools (carp-fmt, angler) on snippet
source. Both are file-based, so I stage the source in a temp file, run the
binary, and clean up.
"
Class {
	#name : #CarpExternalTool,
	#superclass : #Object,
	#category : #'Carp-Tools'
}

{ #category : #accessing }
CarpExternalTool class >> anglerBinary [
	^ (OSEnvironment current at: 'CARP_ANGLER' ifAbsent: [ nil ])
		ifNil: [ '/usr/local/bin/angler' ]
]

{ #category : #accessing }
CarpExternalTool class >> formatterBinary [
	^ (OSEnvironment current at: 'CARP_FMT' ifAbsent: [ nil ])
		ifNil: [ '/usr/local/bin/carp-fmt' ]
]

{ #category : #accessing }
CarpExternalTool class >> format: aSourceString [
	"Answer aSourceString formatted by carp-fmt, or signal an error with the
	tool's diagnostics (e.g. on unparsable source)."

	| output |
	output := self run: self formatterBinary onSource: aSourceString.
	output status isSuccess
		ifFalse: [ ^ self error: (output stderrString
					ifEmpty: [ 'carp-fmt failed' ]
					ifNotEmpty: [ :err | self stripTempPaths: err trimBoth ]) ].
	^ output stdoutString trimRight
]

{ #category : #accessing }
CarpExternalTool class >> lint: aSourceString [
	"Answer angler's findings for aSourceString as CarpLintFinding objects.
	angler exits non-zero when it finds something, so only stderr output
	counts as tool failure."

	| output |
	output := self run: self anglerBinary onSource: aSourceString.
	(output stdoutString isEmpty and: [ output stderrString notEmpty ])
		ifTrue: [ ^ self error: (self stripTempPaths: output stderrString trimBoth) ].
	^ self parseFindings: output stdoutString
]

{ #category : #private }
CarpExternalTool class >> parseFindings: anOutputString [
	"file:line:col: [rule] message, optionally followed by '  at: <form>'."

	| findings |
	findings := OrderedCollection new.
	anOutputString linesDo: [ :line |
		(line beginsWith: '  at: ')
			ifTrue: [ findings ifNotEmpty: [ findings last form: (line allButFirst: 6) ] ]
			ifFalse: [ [ | stream lineNo colNo rest rule |
				stream := line readStream.
				stream upTo: $:.
				lineNo := (stream upTo: $:) asInteger.
				colNo := (stream upTo: $:) asInteger.
				rest := stream upToEnd trimLeft.
				(lineNo notNil and: [ colNo notNil and: [ rest beginsWith: '[' ] ])
					ifTrue: [ rule := (rest copyUpTo: $]) allButFirst.
						findings add: (CarpLintFinding new
								line: lineNo;
								column: colNo;
								rule: rule;
								message: (rest allButFirst: rule size + 2) trimBoth;
								yourself) ] ]
				on: Error
				do: [ :e |  ] ] ].
	^ findings
]

{ #category : #private }
CarpExternalTool class >> stripTempPaths: aMessage [
	"Tool diagnostics prefix each line with the staged temp file's path,
	which means nothing to the snippet author."

	^ (aMessage lines
		collect: [ :line |
			(line includesSubstring: 'carp-tool-')
				ifTrue: [ (line copyAfter: $:) trimLeft ]
				ifFalse: [ line ] ]) asStringWithCr
]

{ #category : #private }
CarpExternalTool class >> run: aBinaryPath onSource: aSourceString [
	| file |
	file := FileLocator temp / ('carp-tool-' , UUID new asString36 , '.carp').
	^ [ file writeStreamDo: [ :ws | ws nextPutAll: aSourceString; lf ].
		GtExternalProcessBuilder new
			command: aBinaryPath;
			args: { file fullName };
			output ]
		ensure: [ file ensureDelete ]
]
