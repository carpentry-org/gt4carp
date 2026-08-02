"
I am the inferred-type report for a notebook session's definitions plus the
source of one cell — the result of the carp server's annotate command,
backed by carp-compiler's front-half pipeline (expand, resolve, infer).

Type and lifetime variables arrive as solver ids (t8838, lt8833); I rename
them per definition, in order of appearance, to the letters Carp signatures
conventionally use.
"
Class {
	#name : #CarpAnnotations,
	#superclass : #Object,
	#instVars : [
		'session',
		'source',
		'definitions',
		'environment',
		'locals',
		'definitionObjects',
		'environmentObjects',
		'prettifyMappings'
	],
	#category : #'Carp-Execution'
}

{ #category : #accessing }
CarpAnnotations >> definitionRows [
	"The server's rows, as parsed. Prefer #definitions unless you need the
	wire representation."

	^ definitions
]

{ #category : #accessing }
CarpAnnotations >> definitions: aCollection [
	definitions := aCollection
]

{ #category : #accessing }
CarpAnnotations >> definitions [
	"The typed definitions as navigable objects; the rows themselves are a
	transport detail."

	^ definitionObjects
		ifNil: [ definitionObjects := self definitionRows
					collect: [ :each |
						CarpDefinition new
							name: (each at: 'name');
							type: (each at: 'type');
							source: (each at: 'source' ifAbsent: [ '' ]);
							annotations: self;
							yourself ] ]
]

{ #category : #accessing }
CarpAnnotations >> definitionNamed: aNameOrNil [
	"The typed row for a defined name (possibly module-qualified on the
	compiler side) or for a cell expression (keyed by its source text)."

	aNameOrNil ifNil: [ ^ nil ].
	^ self definitions
		detect: [ :each | each name = aNameOrNil
				or: [ each name endsWith: '.' , aNameOrNil ] ]
		ifNone: [ nil ]
]

{ #category : #accessing }
CarpAnnotations >> locals [
	^ locals ifNil: [ #() ]
]

{ #category : #accessing }
CarpAnnotations >> locals: aCollection [
	locals := aCollection
]

{ #category : #accessing }
CarpAnnotations >> localsFor: anOwnerName [
	"The (name, type) rows of one definition's local bindings, in body
	traversal order, as a consumable queue."

	^ (self locals
		select: [ :each | (each at: 'owner') = anOwnerName
				or: [ (each at: 'owner') endsWith: '.' , anOwnerName ] ]) asOrderedCollection
]

{ #category : #accessing }
CarpAnnotations >> environment [
	^ environment ifNil: [ #() ]
]

{ #category : #accessing }
CarpAnnotations >> environment: aCollection [
	environment := aCollection
]

{ #category : #accessing }
CarpAnnotations >> environmentDefinitions [
	^ environmentObjects
		ifNil: [ environmentObjects := self environment
					collect: [ :each |
						CarpDefinition new
							name: (each at: 'name');
							type: (each at: 'type');
							annotations: self;
							yourself ] ]
]

{ #category : #accessing }
CarpAnnotations >> gtEnvironmentFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Environment';
		priority: 2;
		items: [ self environmentDefinitions asSortedCollection: [ :a :b | a name < b name ] ];
		column: 'Name'
			text: [ :each | each name asRopedText glamorousCodeFont ]
			width: 240;
		column: 'Type'
			text: [ :each | each prettyType asRopedText glamorousCodeFont ];
		send: [ :each | each ]
]

{ #category : #accessing }
CarpAnnotations >> gtTypesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Types';
		priority: 1;
		items: [ self definitionObjects ];
		column: 'Definition'
			text: [ :each | each name asRopedText glamorousCodeFont ]
			width: 220;
		column: 'Type'
			text: [ :each | each prettyType asRopedText glamorousCodeFont ];
		send: [ :each | each ]
]

{ #category : #printing }
CarpAnnotations >> printOn: aStream [
	aStream
		nextPutAll: self definitionRows size printString;
		nextPutAll: ' typed definitions in ';
		nextPutAll: (session ifNil: [ '?' ])
]

{ #category : #accessing }
CarpAnnotations >> prettify: aTypeString [
	"Rename solver variable ids (t8838, lt8833) to letters, in order of
	appearance within this one string."

	^ self render: aTypeString mapping: Dictionary new
]

{ #category : #accessing }
CarpAnnotations >> prettify: aTypeString owner: anOwnerNameOrNil [
	"Rename solver variable ids with a mapping SHARED across everything
	belonging to one definition, seeded from the definition's own signature,
	so a local annotated 'b' is the same 'b' as in the signature. Prettifying
	each type in isolation names every first variable 'a', which reads as
	'all these have the same type' when they do not."

	| mapping |
	anOwnerNameOrNil ifNil: [ ^ self prettify: aTypeString ].
	prettifyMappings ifNil: [ prettifyMappings := Dictionary new ].
	mapping := prettifyMappings
			at: anOwnerNameOrNil
			ifAbsentPut: [ | seeded |
				seeded := Dictionary new.
				(self definitionNamed: anOwnerNameOrNil)
					ifNotNil: [ :row | self render: row type mapping: seeded ].
				seeded ].
	^ self render: aTypeString mapping: mapping
]

{ #category : #private }
CarpAnnotations >> render: aTypeString mapping: aMapping [
	| result |
	result := WriteStream on: String new.
	self
		scan: aTypeString
		tokensDo: [ :token :isVar |
			isVar
				ifTrue: [ result
						nextPutAll: (aMapping
								at: token
								ifAbsentPut: [ String with: (Character value: 97 + (aMapping size \\ 26)) ]) ]
				ifFalse: [ result nextPutAll: token ] ].
	^ result contents
]

{ #category : #private }
CarpAnnotations >> scan: aString tokensDo: aBlock [
	"Split into variable tokens (t<digits> or lt<digits>) and everything else."

	| i n |
	i := 1.
	n := aString size.
	[ i <= n ]
		whileTrue: [ | start |
			start := i.
			((aString at: i) = $t or: [ (aString at: i) = $l
					and: [ i < n and: [ (aString at: i + 1) = $t ] ] ])
				ifTrue: [ | j |
					j := i + ((aString at: i) = $l ifTrue: [ 2 ] ifFalse: [ 1 ]).
					(j <= n and: [ (aString at: j) = $- ]) ifTrue: [ j := j + 1 ].
					(j <= n and: [ (aString at: j) isDigit
							and: [ i = 1 or: [ (aString at: i - 1) isLetter not ] ] ])
						ifTrue: [ [ j <= n and: [ (aString at: j) isDigit ] ]
								whileTrue: [ j := j + 1 ].
							aBlock value: (aString copyFrom: start to: j - 1) value: true.
							i := j ]
						ifFalse: [ aBlock value: (aString at: i) asString value: false.
							i := i + 1 ] ]
				ifFalse: [ aBlock value: (aString at: i) asString value: false.
					i := i + 1 ] ]
]

{ #category : #accessing }
CarpAnnotations >> session [
	^ session
]

{ #category : #accessing }
CarpAnnotations >> session: aString [
	session := aString
]

{ #category : #accessing }
CarpAnnotations >> source [
	^ source
]

{ #category : #accessing }
CarpAnnotations >> source: aString [
	source := aString
]
