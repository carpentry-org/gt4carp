"
A minimal client for the Carp languagelink server (gt4carp/carp/src/languagelink.carp).

Speaks length-prefixed JSON over a plain TCP socket:
	request:  <decimal length>\n<json bytes>
	response: <decimal length>\n<json bytes>

Usage:
	| client |
	client := CarpLLClient host: '127.0.0.1' port: 8765.
	client expand1: '(when true 1)'.  ""=> '(if true 1 ())'""
	client close.
"
Class {
	#name : #CarpLLClient,
	#superclass : #Object,
	#instVars : [
		'host',
		'port',
		'stream',
		'nextId'
	],
	#category : #'Carp-MacroStepper'
}

{ #category : #'instance creation' }
CarpLLClient class >> host: aString port: anInteger [
	^ self new host: aString; port: anInteger; yourself
]

{ #category : #connecting }
CarpLLClient >> close [
	stream ifNotNil: [ stream close. stream := nil ]
]

{ #category : #connecting }
CarpLLClient >> ensureConnected [
	(stream isNil or: [ stream atEnd ])
		ifTrue: [
			stream := ZdcSocketStream openConnectionToHostNamed: host port: port.
			stream binary ].
	^ stream
]

{ #category : #commands }
CarpLLClient >> expand1: formSource [
	"Send one expand-1 request, return the result string or signal CarpLLError."
	| reply |
	reply := self request: { #cmd -> 'expand-1'. #form -> formSource } asDictionary.
	^ self okOrSignal: reply
]

{ #category : #accessing }
CarpLLClient >> host [ ^ host ]

{ #category : #accessing }
CarpLLClient >> host: aString [ host := aString ]

{ #category : #initialization }
CarpLLClient >> initialize [
	super initialize.
	host := '127.0.0.1'.
	port := 8765.
	nextId := 0
]

{ #category : #private }
CarpLLClient >> nextId [
	nextId := nextId + 1.
	^ nextId
]

{ #category : #private }
CarpLLClient >> okOrSignal: replyDict [
	(replyDict includesKey: 'ok') ifTrue: [ ^ replyDict at: 'ok' ].
	(replyDict includesKey: 'error')
		ifTrue: [ ^ CarpLLError signal: (replyDict at: 'error') ].
	^ CarpLLError signal: 'malformed reply: ' , replyDict printString
]

{ #category : #accessing }
CarpLLClient >> port [ ^ port ]

{ #category : #accessing }
CarpLLClient >> port: anInteger [ port := anInteger ]

{ #category : #private }
CarpLLClient >> readFrame [
	"Read one length-prefixed JSON frame from the stream."
	| header n bytes |
	header := self readLine.
	header isEmpty ifTrue: [ ^ CarpLLError signal: 'connection closed' ].
	n := header asInteger.
	n isNil ifTrue: [ ^ CarpLLError signal: 'bad length: ' , header ].
	bytes := stream next: n.
	^ NeoJSONReader fromString: (bytes asString)
]

{ #category : #private }
CarpLLClient >> readLine [
	"Read bytes until newline, return as a String without the newline."
	| out byte |
	out := WriteStream on: String new.
	[ stream atEnd ] whileFalse: [
		byte := stream next.
		byte = 10 "lf" ifTrue: [ ^ out contents ].
		out nextPut: byte asCharacter ].
	^ out contents
]

{ #category : #commands }
CarpLLClient >> request: aDictionary [
	"Send a request, return the decoded reply (a Dictionary)."
	| body framed |
	self ensureConnected.
	body := NeoJSONWriter toString: (aDictionary copy at: #id put: self nextId; yourself).
	framed := body size asString , String lf , body.
	stream nextPutAll: framed asByteArray.
	stream flush.
	^ self readFrame
]

{ #category : #private }
CarpLLClient >> writeFrame: aString [
	"For tests: write a raw frame to the stream."
	| framed |
	framed := aString size asString , String lf , aString.
	stream nextPutAll: framed asByteArray.
	stream flush
]
