"
One form that says something about a definition rather than defining
anything: `(doc f ""…"")`, `(sig f …)`, `(private f)`, `(implements str f)`,
`(meta-set! f ""example"" true)`. In Carp these are ordinary top-level forms
that name their subject, so a definition does not contain them — it is
followed or preceded by them, and {{gtClass:name=CarpSourceDefinition}} owns
the ones that name it.

The span is what makes an annotation editable and removable: rewriting a
doc string means replacing exactly those bytes, and deleting a definition
means taking its annotations with it.
"
Class {
	#name : #CarpAnnotation,
	#superclass : #Object,
	#instVars : [
		'head',
		'key',
		'value',
		'start',
		'stop'
	],
	#category : #'Carp-Project'
}

{ #category : #'instance creation' }
CarpAnnotation class >> fromDictionary: aDictionary [
	^ self new
		head: (aDictionary at: 'head' ifAbsent: [ '' ]);
		key: (aDictionary at: 'key' ifAbsent: [ '' ]);
		value: (aDictionary at: 'value' ifAbsent: [ '' ]);
		start: (aDictionary at: 'start' ifAbsent: [ 0 ]) asInteger;
		stop: (aDictionary at: 'end' ifAbsent: [ 0 ]) asInteger;
		yourself
]

{ #category : #accessing }
CarpAnnotation >> head [
	^ head ifNil: [ '' ]
]

{ #category : #accessing }
CarpAnnotation >> head: aString [
	head := aString
]

{ #category : #testing }
CarpAnnotation >> isFlag [
	"Whether the annotation says something by being there at all, rather than
	by the value it carries."

	^ #('private' 'hidden' 'example') includes: self key
]

{ #category : #accessing }
CarpAnnotation >> key [
	^ key ifNil: [ '' ]
]

{ #category : #accessing }
CarpAnnotation >> key: aString [
	key := aString
]

{ #category : #printing }
CarpAnnotation >> printOn: aStream [
	aStream nextPutAll: self key.
	self isFlag ifTrue: [ ^ self ].
	aStream
		nextPutAll: ': ';
		nextPutAll: self value
]

{ #category : #accessing }
CarpAnnotation >> source [
	"The form as written."

	^ ''
]

{ #category : #accessing }
CarpAnnotation >> start [
	^ start ifNil: [ 0 ]
]

{ #category : #accessing }
CarpAnnotation >> start: anInteger [
	start := anInteger
]

{ #category : #accessing }
CarpAnnotation >> stop [
	^ stop ifNil: [ 0 ]
]

{ #category : #accessing }
CarpAnnotation >> stop: anInteger [
	stop := anInteger
]

{ #category : #accessing }
CarpAnnotation >> value [
	^ value ifNil: [ '' ]
]

{ #category : #accessing }
CarpAnnotation >> value: aString [
	value := aString
]
