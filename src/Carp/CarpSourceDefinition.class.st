"
One definition in a project file: its qualified name, what defines it
(defn, deftype, …), its documentation, and the byte span it occupies in
that file. The span is what makes this editable later — writing a
definition back means replacing exactly those bytes.

It also owns the {{gtClass:name=CarpAnnotation}}s that name it. In Carp
what is said about a definition — its doc, its declared signature, its
visibility, the interfaces it implements, whether it is an example — is
written as separate top-level forms, so the file has several forms where
the browser shows one thing.
"
Class {
	#name : #CarpSourceDefinition,
	#superclass : #Object,
	#instVars : [
		'name',
		'head',
		'start',
		'stop',
		'documentation',
		'annotations',
		'file'
	],
	#category : #'Carp-Project'
}

{ #category : #'instance creation' }
CarpSourceDefinition class >> fromDictionary: aDictionary in: aFile [
	^ self new
		name: (aDictionary at: 'name' ifAbsent: [ '' ]);
		head: (aDictionary at: 'head' ifAbsent: [ '' ]);
		start: (aDictionary at: 'start' ifAbsent: [ 0 ]) asInteger;
		stop: (aDictionary at: 'end' ifAbsent: [ 0 ]) asInteger;
		documentation: (aDictionary at: 'doc' ifAbsent: [ '' ]);
		annotations: ((aDictionary at: 'annotations' ifAbsent: [ #() ])
				collect: [ :each | CarpAnnotation fromDictionary: each ]);
		file: aFile;
		yourself
]

{ #category : #examples }
CarpSourceDefinition >> exemplifiedNames [
	"What this example is an example of. Two questions answer it, and the
	first one wins: what does it return, and what does it call.

	A `(defn a-unit-circle [] (Circle.init 1.0))` returns a Circle, so it is
	an example of Circle — the same rule GT uses when it reads a return:
	pragma. That says nothing about an example of a function, whose return
	type is usually Double or Bool; there, what identifies the subject is
	that the example calls it. Both are asked, so an example can be an
	example of more than one thing, which is honest: it usually is."

	| names subject |
	self isExample ifFalse: [ ^ #() ].
	names := OrderedCollection new.
	subject := self returnedTypeName.
	subject ifNotNil: [ names add: subject ].
	names addAll: (self calledNames reject: [ :each | names includes: each ]).
	^ names asArray
]

{ #category : #examples }
CarpSourceDefinition >> returnedTypeName [
	"The name of the type this returns, from the session's own view of it —
	the declared signature when there is one, and what the compiler inferred
	otherwise. Answers nil unless the result is a plain named type: an
	example returning Bool or a function is an example of nothing in
	particular."

	| scheme result |
	scheme := self inferredScheme ifNil: [ ^ nil ].
	result := self class resultTypeIn: scheme.
	^ (result notNil and: [ result first isUppercase ])
		ifTrue: [ result ]
		ifFalse: [ nil ]
]

{ #category : #examples }
CarpSourceDefinition >> inferredScheme [
	| project row |
	project := self project ifNil: [ ^ nil ].
	project isSessionLoaded ifFalse: [ ^ nil ].
	row := project environmentRowNamed: self name.
	^ row ifNil: [ nil ] ifNotNil: [ row at: 'type' ifAbsent: [ nil ] ]
]

{ #category : #examples }
CarpSourceDefinition class >> resultTypeIn: aSchemeString [
	"The result of a `(Fn [args] Result)` written as text: the last
	balanced element before the closing paren. Answers nil for anything that
	is not a function type."

	| inner depth pieces current |
	(aSchemeString beginsWith: '(Fn ') ifFalse: [ ^ nil ].
	inner := (aSchemeString allButFirst: 4) allButLast trimBoth.
	depth := 0.
	pieces := OrderedCollection new.
	current := WriteStream on: String new.
	inner
		do: [ :char |
			(char = $( or: [ char = $[ ]) ifTrue: [ depth := depth + 1 ].
			(char = $) or: [ char = $] ]) ifTrue: [ depth := depth - 1 ].
			(char isSeparator and: [ depth = 0 ])
				ifTrue: [ current contents ifNotEmpty: [ :piece | pieces add: piece ].
					current := WriteStream on: String new ]
				ifFalse: [ current nextPut: char ] ].
	current contents ifNotEmpty: [ :piece | pieces add: piece ].
	pieces isEmpty ifTrue: [ ^ nil ].
	^ pieces last
]

{ #category : #examples }
CarpSourceDefinition >> calledNames [
	"Every project definition this one names. Read from the parse tree
	rather than from the text, so a name inside a string or a comment is not
	mistaken for a call; a local that shadows a definition still would be,
	which is worth less than the parser it would take to know better."

	| project known found ast prefix |
	project := self project ifNil: [ ^ #() ].
	known := project definitionsByName.
	found := Set new.
	prefix := self moduleName.
	ast := [ CarpParser parse: self source ] on: Error do: [ :e | nil ].
	ast ifNil: [ ^ #() ].
	ast
		withAllNodesDo: [ :node |
			((node isKindOf: CarpModuleOrTypeNode) or: [ node isKindOf: CarpVariableNode ])
				ifTrue: [ | text qualified |
					text := node source asString trimBoth.
					qualified := (known includesKey: text)
							ifTrue: [ text ]
							ifFalse: [ | inModule |
								inModule := prefix isEmpty
										ifTrue: [ text ]
										ifFalse: [ prefix , '.' , text ].
								(known includesKey: inModule) ifTrue: [ inModule ] ifFalse: [ nil ] ].
					(qualified notNil and: [ qualified ~= self name ])
						ifTrue: [ found add: qualified ] ] ].
	^ found asArray sort
]

{ #category : #accessing }
CarpSourceDefinition >> annotations [
	^ annotations ifNil: [ #() ]
]

{ #category : #accessing }
CarpSourceDefinition >> annotations: aCollection [
	annotations := aCollection asArray
]

{ #category : #accessing }
CarpSourceDefinition >> annotationNamed: aKey [
	^ self annotations detect: [ :each | each key = aKey ] ifNone: [ nil ]
]

{ #category : #accessing }
CarpSourceDefinition >> signature [
	"The signature the author declared, if they declared one. What the
	compiler inferred is a different question, and the session answers it."

	^ (self annotationNamed: 'sig') ifNil: [ '' ] ifNotNil: [ :each | each value ]
]

{ #category : #accessing }
CarpSourceDefinition >> implementedInterfaces [
	^ (self annotations select: [ :each | each key = 'implements' ])
		collect: [ :each | each value ]
]

{ #category : #testing }
CarpSourceDefinition >> isPrivate [
	^ (self annotationNamed: 'private') notNil
]

{ #category : #testing }
CarpSourceDefinition >> isHidden [
	^ (self annotationNamed: 'hidden') notNil
]

{ #category : #testing }
CarpSourceDefinition >> isExample [
	"An example is an ordinary definition that says it is one. Which thing it
	exemplifies is not written down: it is answered by what the example
	returns and what it calls."

	^ (self annotationNamed: 'example') notNil
]

{ #category : #testing }
CarpSourceDefinition >> isType [
	^ #('deftype' 'register-type' 'deftemplate' 'defalias') includes: self head
]

{ #category : #testing }
CarpSourceDefinition >> isInterface [
	^ self head = 'definterface'
]

{ #category : #testing }
CarpSourceDefinition >> isFunction [
	^ #('defn' 'defn-' 'defmacro' 'defndynamic' 'defview') includes: self head
]

{ #category : #accessing }
CarpSourceDefinition >> kind [
	"What this is, in one word — the distinction a reader wants before any
	other: a type is not a function is not a value."

	self isModule ifTrue: [ ^ #module ].
	self isType ifTrue: [ ^ #type ].
	self isInterface ifTrue: [ ^ #interface ].
	self isExample ifTrue: [ ^ #example ].
	self isFunction ifTrue: [ ^ #function ].
	^ #value
]

{ #category : #accessing }
CarpSourceDefinition >> annotationsStart [
	"Where this definition begins once the forms that talk about it are
	counted in — they are part of it, and go where it goes."

	^ self annotations
		inject: self start
		into: [ :earliest :each | earliest min: each start ]
]

{ #category : #accessing }
CarpSourceDefinition >> annotationsStop [
	^ self annotations
		inject: self stop
		into: [ :latest :each | latest max: each stop ]
]

{ #category : #actions }
CarpSourceDefinition >> saveDocumentation: aString [
	"Write the documentation back into the file. An existing (doc …) form is
	replaced through its own span; a definition that had none gets one on the
	line above it, indented as it is; emptying it takes the whole line away
	rather than leaving a blank one behind."

	| text existing shift boundary |
	text := aString trimBoth.
	existing := self annotationNamed: 'doc'.
	existing
		ifNil: [
			text ifEmpty: [ ^ self ].
			boundary := self start.
			shift := self file
					replaceBytesFrom: self start
					to: self start
					with: (self docFormFor: text) , String lf , self indentation.
			self file shiftDefinitionsAfter: boundary - 1 by: shift ]
		ifNotNil: [ :annotation |
			| span |
			text
				ifEmpty: [ span := self file lineOnly: annotation start to: annotation stop.
					boundary := annotation stop.
					shift := self file replaceBytesFrom: span key to: span value with: '' ]
				ifNotEmpty: [ boundary := annotation stop.
					shift := self file
							replaceBytesFrom: annotation start
							to: annotation stop
							with: (self docFormFor: text) ].
			self file shiftDefinitionsAfter: boundary by: shift ].
	documentation := text.
	self file reloadDefinitions.
	self file commit.
	self project ifNotNil: [ :aProject | aProject changed ]
]

{ #category : #private }
CarpSourceDefinition >> indentation [
	"The whitespace this definition sits behind on its line, so a form
	written above it lines up with it."

	| contents index |
	contents := self file contents.
	index := self start.
	[ index > 1 and: [ (contents at: index - 1) ~= Character lf ] ]
		whileTrue: [ index := index - 1 ].
	^ (contents copyFrom: (index max: 1) to: self start) select: [ :each | each isSeparator ]
]

{ #category : #private }
CarpSourceDefinition >> docFormFor: aString [
	"A (doc …) form, one string literal per line, the way Carp's own sources
	are written."

	^ String
		streamContents: [ :aStream |
			aStream
				nextPutAll: '(doc ';
				nextPutAll: self shortName.
			aString lines
				do: [ :line |
					aStream
						nextPutAll: ' ', (String with: $");
						nextPutAll: (line copyReplaceAll: (String with: $") with: '\' , (String with: $"));
						nextPutAll: (String with: $") ].
			aStream nextPut: $) ]
]

{ #category : #accessing }
CarpSourceDefinition >> documentation [
	^ documentation ifNil: [ '' ]
]

{ #category : #accessing }
CarpSourceDefinition >> documentation: aString [
	documentation := aString
]

{ #category : #accessing }
CarpSourceDefinition >> file [
	^ file
]

{ #category : #accessing }
CarpSourceDefinition >> file: aCarpProjectFile [
	file := aCarpProjectFile
]

{ #category : #actions }
CarpSourceDefinition >> gtActionDeleteFor: anAction [
	<gtAction>
	self isModule ifTrue: [ ^ anAction noAction ].
	^ anAction button
		priority: 10;
		icon: BrGlamorousVectorIcons trash;
		tooltip: 'Delete this definition from its file';
		action: [ :aButton | self delete ]
]

{ #category : #accessing }
CarpSourceDefinition >> gtDocumentationFor: aView [
	<gtView>
	self documentation ifEmpty: [ ^ aView empty ].
	^ aView textEditor
		title: 'Documentation';
		priority: 2;
		text: [ self documentation ]
]

{ #category : #accessing }
CarpSourceDefinition >> gtSourceFor: aView [
	"A coder once the project's session is warm, so the definition is typed,
	checked, completed and documented against the rest of the project.
	Before that a coder would annotate against a session that does not hold
	the project and call every project binding unknown, so the source is
	shown plainly instead."

	<gtView>
	self project isSessionLoaded
		ifFalse: [ ^ aView textEditor
				title: 'Source';
				priority: 1;
				aptitude: [ BrGlamorousCodeEditorAptitude ];
				styler: [ CarpParser gtStyler ];
				text: [ self source ] ].
	^ aView explicit
		title: 'Source';
		priority: 1;
		stencil: [ self newCoder asCoderViewModel asElement ]
]

{ #category : #saving }
CarpSourceDefinition >> delete [
	"Cut the definition out of its file, leaving one blank line where it
	was, and commit the file so the session drops it too. Its annotations go
	with it: a (doc …) left behind naming nothing is not a definition the
	compiler will complain about, it is litter."

	| shift boundary span |
	span := self file
			lineSpanAround: self annotationsStart
			to: self annotationsStop.
	boundary := self annotationsStop.
	shift := self file replaceBytesFrom: span key to: span value with: ''.
	self file shiftDefinitionsAfter: boundary by: shift.
	self file removeDefinition: self.
	self file commit.
	self project ifNotNil: [ :aProject | aProject changed ]
]

{ #category : #testing }
CarpSourceDefinition >> isModule [
	^ self head = 'defmodule'
]

{ #category : #saving }
CarpSourceDefinition >> save: aSourceString [
	"Write this definition back through its span and commit the file into the
	session. The file is the truth: the bytes are replaced in place, every
	span after this one shifts by the length change, and the session is told
	about the file as a whole so a rename or a deletion reconciles."

	| shift boundary |
	aSourceString = self source ifTrue: [ ^ self ].
	boundary := stop.
	shift := self file replaceBytesFrom: start to: stop with: aSourceString.
	"shift the definitions below BEFORE moving this one's own end, or the
	boundary they are compared against has already moved"
	self file shiftDefinitionsAfter: boundary by: shift.
	stop := stop + shift.
	self file commit.
	self project ifNotNil: [ :aProject | aProject changed ]
]

{ #category : #accessing }
CarpSourceDefinition >> newCoder [
	"The definition's own text in a coder bound to the project's session,
	which writes back through this definition's span when saved."

	^ GtCarpDefinitionCoderModel on: self
]

{ #category : #accessing }
CarpSourceDefinition >> project [
	^ file ifNil: [ nil ] ifNotNil: [ :aFile | aFile project ]
]

{ #category : #accessing }
CarpSourceDefinition >> head [
	^ head ifNil: [ '' ]
]

{ #category : #accessing }
CarpSourceDefinition >> head: aString [
	head := aString
]

{ #category : #accessing }
CarpSourceDefinition >> moduleName [
	"The module this belongs to: everything before the last dot of the
	qualified name, or empty at the top level."

	| index |
	index := self name lastIndexOf: $..
	^ index = 0
		ifTrue: [ '' ]
		ifFalse: [ self name first: index - 1 ]
]

{ #category : #accessing }
CarpSourceDefinition >> name [
	^ name ifNil: [ '' ]
]

{ #category : #accessing }
CarpSourceDefinition >> name: aString [
	name := aString
]

{ #category : #printing }
CarpSourceDefinition >> printOn: aStream [
	aStream
		nextPutAll: self head;
		nextPutAll: ' ';
		nextPutAll: self name
]

{ #category : #accessing }
CarpSourceDefinition >> shortName [
	"The name without its module prefix."

	| index |
	index := self name lastIndexOf: $..
	^ index = 0
		ifTrue: [ self name ]
		ifFalse: [ self name allButFirst: index ]
]

{ #category : #accessing }
CarpSourceDefinition >> source [
	"The definition's own text, sliced from its file by byte span."

	^ file
		ifNil: [ '' ]
		ifNotNil: [ :aFile | aFile byteSliceFrom: start to: stop ]
]

{ #category : #accessing }
CarpSourceDefinition >> start [
	^ start
]

{ #category : #accessing }
CarpSourceDefinition >> start: anInteger [
	start := anInteger
]

{ #category : #accessing }
CarpSourceDefinition >> stop [
	^ stop
]

{ #category : #accessing }
CarpSourceDefinition >> stop: anInteger [
	stop := anInteger
]
