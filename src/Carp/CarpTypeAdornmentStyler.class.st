"
I decorate a Carp coder's text with inferred types: each top-level form
gets its type appended inline, from the coder's asynchronously refreshed
annotation cache (see GtCarpCoderModel>>#typeAdornmentAnnotations). When
the cache is stale I style nothing; the coder restyles once fresh types
arrive.
"
Class {
	#name : #CarpTypeAdornmentStyler,
	#superclass : #GtCoderAstStyler,
	#category : #'Carp-Coder'
}

{ #category : #comparing }
CarpTypeAdornmentStyler >> = anObject [
	^ self class == anObject class
]

{ #category : #comparing }
CarpTypeAdornmentStyler >> hash [
	^ self class hash
]

{ #category : #accessing }
CarpTypeAdornmentStyler >> inlineLabelFor: aTypeString [
	"Long types would dominate the line; the full type is one click away."

	^ aTypeString size <= 48
		ifTrue: [ ' : ' , aTypeString ]
		ifFalse: [ ' : ' , (aTypeString first: 47) , '…' ]
]

{ #category : #accessing }
CarpTypeAdornmentStyler >> style: aText ast: theAst [
	| coder annotations byteMap |
	coder := self coderViewModel ifNotNil: [ :aViewModel | aViewModel coderModel ].
	(coder isKindOf: GtCarpCoderModel) ifFalse: [ ^ self ].
	annotations := coder typeAdornmentAnnotations.
	annotations ifNil: [ ^ self ].
	byteMap := nil.
	theAst expressions
		do: [ :each |
			[ | row |
			row := each isDefinition
					ifTrue: [ annotations
							definitionNamed: ([ each definitionVariable value source ]
									on: Error
									do: [ :e | nil ]) ]
					ifFalse: [ annotations definitionNamed: each source trimBoth ].
			row
				ifNotNil: [ aText
						attributes: {CarpTypeAdornmentAttribute new
								label: (self inlineLabelFor: row prettyType);
								definition: row;
								yourself}
						from: each stopPosition
						to: each stopPosition ].
			each isDefinition
				ifTrue: [ | ownerName localRows |
					ownerName := [ each definitionVariable value source ]
							on: Error
							do: [ :e | nil ].
					ownerName
						ifNotNil: [ localRows := annotations localsFor: ownerName.
							(localRows notEmpty
								and: [ localRows first includesKey: 'end' ])
								ifTrue: [ byteMap
										ifNil: [ byteMap := self byteToCharMapFor: aText asString ].
									self
										adornLocalsFrom: localRows
										text: aText
										map: byteMap
										annotations: annotations
										owner: ownerName ]
								ifFalse: [ self
										adornBindersIn: each
										locals: localRows
										text: aText
										annotations: annotations
										owner: ownerName ] ] ] ]
				on: Error
				do: [ :e |  ] ]
]

{ #category : #accessing }
CarpTypeAdornmentStyler >> byteToCharMapFor: aString [
	"UTF-8 byte offset at each character boundary -> 1-based character
	position; the compiler's spans are byte offsets into the cell source."

	| map bytes |
	map := Dictionary new: aString size * 2.
	bytes := 0.
	aString doWithIndex: [ :ch :i |
		map at: bytes put: i.
		bytes := bytes + (self utf8SizeOf: ch) ].
	map at: bytes put: aString size + 1.
	^ map
]

{ #category : #accessing }
CarpTypeAdornmentStyler >> utf8SizeOf: aCharacter [
	| cp |
	cp := aCharacter asInteger.
	cp < 128 ifTrue: [ ^ 1 ].
	cp < 2048 ifTrue: [ ^ 2 ].
	cp < 65536 ifTrue: [ ^ 3 ].
	^ 4
]

{ #category : #accessing }
CarpTypeAdornmentStyler >> adornLocalsFrom: someRows text: aText map: aByteToCharMap annotations: annotations owner: anOwnerName [
	"Anchor each local's adornment by its compiler span (byte offsets into
	the cell), converted to character positions — no source walk needed.
	Rows whose span does not land on a character boundary are skipped."

	someRows do: [ :row |
		[ | endByte boundary |
		endByte := (row at: 'end' ifAbsent: [ nil ]) ifNotNil: [ :v | v asInteger ].
		(endByte isNil or: [ endByte <= 0 ]) ifFalse: [
			boundary := aByteToCharMap at: endByte ifAbsent: [ nil ].
			boundary ifNotNil: [
				aText
					attributes: {CarpTypeAdornmentAttribute new
							label: (self inlineLabelFor: (annotations prettify: (row at: 'type') owner: anOwnerName));
							definition: (CarpDefinition new
									name: (row at: 'name' ifAbsent: [ '' ]);
									type: (row at: 'type');
									annotations: annotations;
									owner: anOwnerName;
									yourself);
							yourself}
					from: boundary - 1
					to: boundary - 1 ] ] ]
			on: Error
			do: [ :e |  ] ]
]

{ #category : #accessing }
CarpTypeAdornmentStyler >> adornBindersIn: aNode locals: aQueue text: aText annotations: annotations owner: anOwnerName [
	"Pair source binder occurrences with the compiler's per-definition
	locals, both in traversal order, matching by name so binders the
	compiler synthesized (or the source spells differently) are skipped."

	(aNode isKindOf: CarpListNode) ifFalse: [ ^ self ].
	aNode expressions ifEmpty: [ ^ self ].
	[ | kids head headName binderNodes |
	kids := aNode expressions.
	head := kids first.
	headName := (head isKindOf: CarpVariableNode)
			ifTrue: [ head source ]
			ifFalse: [ '' ].
	binderNodes := OrderedCollection new.
	(#('defn' 'defn-' 'fn') includes: headName)
		ifTrue: [ (kids detect: [ :k | k isKindOf: CarpArrayNode ] ifNone: [ nil ])
				ifNotNil: [ :params | binderNodes addAll: (params expressions select: [ :b | b isKindOf: CarpVariableNode ]) ] ].
	(#('let' 'let-do') includes: headName)
		ifTrue: [ (kids detect: [ :k | k isKindOf: CarpArrayNode ] ifNone: [ nil ])
				ifNotNil: [ :bindings |
					bindings expressions
						doWithIndex: [ :b :i |
							(i odd and: [ b isKindOf: CarpVariableNode ])
								ifTrue: [ binderNodes add: b ] ] ] ].
	headName = 'for'
		ifTrue: [ (kids detect: [ :k | k isKindOf: CarpArrayNode ] ifNone: [ nil ])
				ifNotNil: [ :spec |
					(spec expressions notEmpty and: [ spec expressions first isKindOf: CarpVariableNode ])
						ifTrue: [ binderNodes add: spec expressions first ] ] ].
	binderNodes
		do: [ :binder |
			(self nextLocalNamed: binder source from: aQueue)
				ifNotNil: [ :row |
					aText
						attributes: {CarpTypeAdornmentAttribute new
								label: (self inlineLabelFor: (annotations prettify: (row at: 'type') owner: anOwnerName));
								definition: (CarpDefinition new
										name: binder source;
										type: (row at: 'type');
										annotations: annotations;
										owner: anOwnerName;
										yourself);
								yourself}
						from: binder stopPosition
						to: binder stopPosition ] ] ]
		on: Error
		do: [ :e |  ].
	aNode expressions
		do: [ :child |
			(child isKindOf: CarpListNode)
				ifTrue: [ self adornBindersIn: child locals: aQueue text: aText annotations: annotations owner: anOwnerName ]
				ifFalse: [ (child isKindOf: CarpArrayNode)
						ifTrue: [ child expressions
								do: [ :grandchild |
									(grandchild isKindOf: CarpListNode)
										ifTrue: [ self adornBindersIn: grandchild locals: aQueue text: aText annotations: annotations owner: anOwnerName ] ] ] ] ]
]

{ #category : #accessing }
CarpTypeAdornmentStyler >> nextLocalNamed: aName from: aQueue [
	"Consume the queue up to the next row with this name; nil (and no
	consumption) when the name does not appear."

	| index row |
	index := aQueue findFirst: [ :each | (each at: 'name') = aName ].
	index = 0 ifTrue: [ ^ nil ].
	row := aQueue at: index.
	index timesRepeat: [ aQueue removeFirst ].
	^ row
]
