"
I am one typed Carp definition (or cell expression) from an annotation run:
a name, its inferred type, optionally its source, and a handle back to the
whole environment — which makes me a doorway: my referenced types are
navigable {{gtClass:name=CarpTypeReference}}s.
"
Class {
	#name : #CarpDefinition,
	#superclass : #Object,
	#instVars : [
		'name',
		'type',
		'source',
		'annotations',
		'owner',
		'typeNamesCache',
		'ownershipRows'
	],
	#category : #'Carp-Execution'
}

{ #category : #accessing }
CarpDefinition >> annotations [
	^ annotations
]

{ #category : #accessing }
CarpDefinition >> annotations: aCarpAnnotations [
	annotations := aCarpAnnotations
]

{ #category : #accessing }
CarpDefinition >> gtReferencedTypesFor: aView [
	<gtView>
	self referencedTypeNames ifEmpty: [ ^ aView empty ].
	^ aView columnedList
		title: 'Types';
		priority: 2;
		items: [ self referencedTypes ];
		column: 'Type'
			text: [ :each | each typeName asRopedText glamorousCodeFont ]
			width: 200;
		column: 'Functions over it'
			text: [ :each | each functions size printString ];
		send: [ :each | each ]
]

{ #category : #accessing }
CarpDefinition >> gtLifetimesFor: aView [
	<gtView>
	annotations ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Lifetimes';
		priority: 4;
		items: [ self ownershipRows ];
		column: 'Binding'
			text: [ :each | (each at: 'binding') asRopedText glamorousCodeFont ]
			width: 140;
		column: 'Action'
			text: [ :each | | action | action := each at: 'action'.
				action asRopedText
					glamorousCodeFont;
					foreground: (action = 'delete'
							ifTrue: [ BrGlamorousColors errorBackgroundColor twiceDarker ]
							ifFalse: [ BrGlamorousColors successBackgroundColor twiceDarker ]);
					yourself ]
			width: 90;
		column: 'Target'
			text: [ :each | (each at: 'target' ifAbsent: [ '' ]) asRopedText glamorousCodeFont ]
			width: 120;
		column: 'Type'
			text: [ :each | (annotations prettify: (each at: 'type' ifAbsent: [ '' ])) asRopedText glamorousCodeFont ]
]

{ #category : #accessing }
CarpDefinition >> ownershipRows [
	"The plan events of this definition, in plan order, fetched on demand."

	^ ownershipRows
		ifNil: [ ownershipRows := [ (CarpServerClient default
					ownershipSource: annotations source
					session: annotations session)
					select: [ :each | (each at: 'owner') = name
							or: [ (each at: 'owner') endsWith: '.' , name ] ] ]
				on: CarpServerError
				do: [ :e | #() ] ]
]

{ #category : #accessing }
CarpDefinition >> gtSignatureFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Signature';
		priority: 1;
		text: [ (name , ' : ' , self prettyType) asRopedText glamorousCodeFont fontSize: 14 ]
]

{ #category : #accessing }
CarpDefinition >> gtSourceFor: aView [
	<gtView>
	(source isNil or: [ source isEmpty ]) ifTrue: [ ^ aView empty ].
	^ aView textEditor
		title: 'Source';
		priority: 3;
		styler: CarpParser gtStyler;
		text: [ source asRopedText glamorousCodeFont ]
]

{ #category : #accessing }
CarpDefinition >> name [
	^ name
]

{ #category : #accessing }
CarpDefinition >> name: aString [
	name := aString
]

{ #category : #printing }
CarpDefinition >> printOn: aStream [
	aStream
		nextPutAll: name;
		nextPutAll: ' : ';
		nextPutAll: self prettyType
]

{ #category : #accessing }
CarpDefinition >> owner [
	"The defining scope's name: for locals the enclosing definition, for
	top-level definitions their own name."

	^ owner ifNil: [ name ]
]

{ #category : #accessing }
CarpDefinition >> owner: aName [
	owner := aName
]

{ #category : #accessing }
CarpDefinition >> prettyType [
	^ annotations
		ifNil: [ type ]
		ifNotNil: [ annotations prettify: type owner: self owner ]
]

{ #category : #accessing }
CarpDefinition >> mentionsType: aTypeName [
	^ self referencedTypeNames includes: aTypeName
]

{ #category : #accessing }
CarpDefinition >> referencedTypeNames [
	"Capitalized identifiers in the raw type are named types."

	| names token |
	typeNamesCache ifNotNil: [ ^ typeNamesCache ].
	names := OrderedCollection new.
	token := WriteStream on: String new.
	(type , ' ')
		do: [ :c |
			(c isLetter or: [ c isDigit or: [ c = $. or: [ c = $- ] ] ])
				ifTrue: [ token nextPut: c ]
				ifFalse: [ | t |
					t := token contents.
					token := WriteStream on: String new.
					(t notEmpty and: [ t first isUppercase and: [ (names includes: t) not ] ])
						ifTrue: [ names add: t ] ] ].
	^ typeNamesCache := names
]

{ #category : #accessing }
CarpDefinition >> referencedTypes [
	^ self referencedTypeNames
		collect: [ :each | CarpTypeReference new typeName: each; annotations: annotations; yourself ]
]

{ #category : #accessing }
CarpDefinition >> source [
	^ source
]

{ #category : #accessing }
CarpDefinition >> source: aString [
	source := aString
]

{ #category : #accessing }
CarpDefinition >> type [
	^ type
]

{ #category : #accessing }
CarpDefinition >> type: aString [
	type := aString
]
