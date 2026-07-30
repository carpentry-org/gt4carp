"
I visualize the lifetime of the binding under the cursor, semantically:

- the binder is underlined green (birth);
- borrowing uses (&x) are underlined blue, copying uses (@&x) teal;
- a bare use of an owned value is a MOVE — underlined red, and the
  lifetime wash ends there, because ownership does;
- when nothing moves an owned value, it dies at scope exit: the wash runs
  to the scope's closing delimiter, which gets a red end-of-life mark.

Unmanaged values (Int, Double, …) just get their occurrences marked gray —
they are copied, not owned, and have no lifetime story.

Classification is syntactic (parse tree) plus the binding's inferred type
from the coder's annotation cache; no server round-trip on hover.
"
Class {
	#name : #CarpLifetimeHighlightStyler,
	#superclass : #GtCoderAstStyler,
	#category : #'Carp-Coder'
}

{ #category : #comparing }
CarpLifetimeHighlightStyler >> = anObject [
	^ self class == anObject class
]

{ #category : #accessing }
CarpLifetimeHighlightStyler >> binderFramesOf: aNode [
	"name -> binder node pairs introduced by this form, or empty."

	| kids head headName frame |
	frame := OrderedCollection new.
	(aNode isKindOf: CarpListNode) ifFalse: [ ^ frame ].
	kids := aNode expressions.
	kids ifEmpty: [ ^ frame ].
	head := kids first.
	headName := (head isKindOf: CarpVariableNode)
			ifTrue: [ head source ]
			ifFalse: [ '' ].
	(#('defn' 'defn-' 'fn') includes: headName)
		ifTrue: [ (kids detect: [ :k | k isKindOf: CarpArrayNode ] ifNone: [ nil ])
				ifNotNil: [ :params |
					params expressions
						do: [ :b | (b isKindOf: CarpVariableNode) ifTrue: [ frame add: b source -> b ] ] ] ].
	(#('let' 'let-do') includes: headName)
		ifTrue: [ (kids detect: [ :k | k isKindOf: CarpArrayNode ] ifNone: [ nil ])
				ifNotNil: [ :bindings |
					bindings expressions
						doWithIndex: [ :b :i |
							(i odd and: [ b isKindOf: CarpVariableNode ])
								ifTrue: [ frame add: b source -> b ] ] ] ].
	headName = 'for'
		ifTrue: [ (kids detect: [ :k | k isKindOf: CarpArrayNode ] ifNone: [ nil ])
				ifNotNil: [ :spec |
					(spec expressions notEmpty and: [ spec expressions first isKindOf: CarpVariableNode ])
						ifTrue: [ frame add: spec expressions first source -> spec expressions first ] ] ].
	^ frame
]

{ #category : #accessing }
CarpLifetimeHighlightStyler >> findBindingFor: aCursor in: aNode scopes: aScopeStack [
	"Answer name -> (binder -> scope) for the identifier under the cursor,
	resolved through the innermost enclosing binding frame."

	| frame |
	((aNode isKindOf: CarpVariableNode)
		and: [ aNode startPosition <= aCursor and: [ aCursor <= (aNode stopPosition + 1) ] ])
		ifTrue: [ aScopeStack reverseDo: [ :assoc |
				(assoc value anySatisfy: [ :pair | pair key = aNode source ])
					ifTrue: [ | binder |
						binder := (assoc value detect: [ :pair | pair key = aNode source ]) value.
						^ aNode source -> (binder -> assoc key) ] ].
			^ nil ].
	frame := self binderFramesOf: aNode.
	frame ifNotEmpty: [ aScopeStack addLast: aNode -> frame ].
	aNode children
		do: [ :child |
			(child startPosition <= aCursor and: [ aCursor <= (child stopPosition + 1) ])
				ifTrue: [ (self findBindingFor: aCursor in: child scopes: aScopeStack)
						ifNotNil: [ :found | ^ found ] ] ].
	frame ifNotEmpty: [ aScopeStack removeLast ].
	^ nil
]

{ #category : #comparing }
CarpLifetimeHighlightStyler >> hash [
	^ self class hash
]

{ #category : #accessing }
CarpLifetimeHighlightStyler >> occurrencesOf: aName in: aNode kind: aKind into: aCollection [
	"Collect name occurrences as node -> kind, where kind is #move for bare
	uses, #borrow under &, #copy under @&."

	| childKind |
	(aNode isKindOf: CarpVariableNode)
		ifTrue: [ aNode source = aName ifTrue: [ aCollection add: aNode -> aKind ].
			^ self ].
	childKind := aKind.
	(aNode isKindOf: CarpDerefNode) ifTrue: [ childKind := #copy ].
	((aNode isKindOf: CarpRefNode) and: [ aKind ~= #copy ])
		ifTrue: [ childKind := #borrow ].
	aNode children
		do: [ :child | self occurrencesOf: aName in: child kind: childKind into: aCollection ]
]

{ #category : #accessing }
CarpLifetimeHighlightStyler >> style: aText ast: theAst [
	| coder hoverPosition |
	coder := self coderViewModel ifNotNil: [ :vm | vm coderModel ].
	(coder isKindOf: GtCarpCoderModel) ifFalse: [ ^ self ].
	theAst expressions
		do: [ :top | [ self attachHoverIn: top coder: coder text: aText ]
				on: Error
				do: [ :e |  ] ].
	hoverPosition := coder lifetimeHoverPosition.
	hoverPosition ifNil: [ ^ self ].
	theAst expressions
		do: [ :top |
			(top startPosition <= hoverPosition and: [ hoverPosition <= (top stopPosition + 1) ])
				ifTrue: [ [ self styleLifetimeAt: hoverPosition in: top text: aText ]
						on: Error
						do: [ :e |  ] ] ]
]

{ #category : #accessing }
CarpLifetimeHighlightStyler >> attachHoverIn: aNode coder: aCoder text: aText [
	(aNode isKindOf: CarpVariableNode)
		ifTrue: [ | position |
			position := aNode startPosition.
			(aText from: aNode startPosition to: aNode stopPosition)
				attribute: (BrTextHoverDynamicAttribute new
						enterAction: [ :t :el :ed :event | aCoder lifetimeHoverAt: position ];
						leaveAction: [ :t :el :ed :event | aCoder lifetimeHoverAt: nil ];
						yourself).
			^ self ].
	aNode children
		do: [ :child | self attachHoverIn: child coder: aCoder text: aText ]
]

{ #category : #accessing }
CarpLifetimeHighlightStyler >> styleLifetimeAt: aCursor in: aTopNode text: aText [
	| found name binder scope occurrences managed bindingType firstMove washEnd |
	found := self findBindingFor: aCursor in: aTopNode scopes: OrderedCollection new.
	found ifNil: [ ^ self ].
	name := found key.
	binder := found value key.
	scope := found value value.
	bindingType := self typeOf: name inDefinition: aTopNode.
	managed := self isManagedType: bindingType.
	occurrences := OrderedCollection new.
	self occurrencesOf: name in: scope kind: #move into: occurrences.
	occurrences := occurrences reject: [ :assoc | assoc key == binder ].
	managed
		ifFalse: [ "no ownership story: gray occurrence marks only"
			(aText from: binder startPosition to: binder stopPosition)
				underlineColor: (Color gray alpha: 0.6) thickness: 2.
			occurrences
				do: [ :assoc |
					(aText from: assoc key startPosition to: assoc key stopPosition)
						underlineColor: (Color gray alpha: 0.6) thickness: 2 ].
			^ self ].
	firstMove := occurrences detect: [ :assoc | assoc value == #move ] ifNone: [ nil ].
	washEnd := firstMove
			ifNil: [ scope stopPosition ]
			ifNotNil: [ firstMove key stopPosition ].
	(aText from: binder startPosition to: washEnd)
		background: (Color red alpha: 0.09).
	(aText from: binder startPosition to: binder stopPosition)
		underlineColor: (Color green muchDarker alpha: 0.8) thickness: 2.
	occurrences
		do: [ :assoc |
			| color |
			color := assoc value == #move
					ifTrue: [ Color red alpha: 0.85 ]
					ifFalse: [ assoc value == #copy
							ifTrue: [ (Color r: 0 g: 0.55 b: 0.55) alpha: 0.85 ]
							ifFalse: [ Color blue alpha: 0.55 ] ].
			(aText from: assoc key startPosition to: assoc key stopPosition)
				underlineColor: color thickness: 2 ].
	"no move: the owned value dies at scope exit — mark the closing delimiter"
	firstMove
		ifNil: [ (aText from: scope stopPosition to: scope stopPosition)
				underlineColor: (Color red alpha: 0.9) thickness: 3 ]
]

{ #category : #accessing }
CarpLifetimeHighlightStyler >> typeOf: aName inDefinition: aTopNode [
	"The binding's inferred type from the coder's annotation cache, or nil."

	| coder annotations ownerName |
	coder := self coderViewModel ifNotNil: [ :vm | vm coderModel ].
	(coder isKindOf: GtCarpCoderModel) ifFalse: [ ^ nil ].
	annotations := coder typeAdornmentAnnotations.
	annotations ifNil: [ ^ nil ].
	ownerName := [ aTopNode definitionVariable value source ] on: Error do: [ :e | nil ].
	ownerName ifNil: [ ^ nil ].
	^ (annotations localsFor: ownerName)
		detect: [ :row | (row at: 'name') = aName ]
		ifNone: [ nil ]
]

{ #category : #accessing }
CarpLifetimeHighlightStyler >> isManagedType: aRowOrNil [
	"Owned values have a delete; approximate from the type spelling. When
	the type is unknown (stale cache) assume owned — the visual is honest
	more often than not."

	| type |
	aRowOrNil ifNil: [ ^ true ].
	type := aRowOrNil at: 'type' ifAbsent: [ ^ true ].
	(type beginsWith: '(Ref ') ifTrue: [ ^ false ].
	(type beginsWith: '(Fn ') ifTrue: [ ^ false ].
	(#('Int' 'Long' 'Float' 'Double' 'Bool' 'Char' 'Byte' '()' 'Unit') includes: type)
		ifTrue: [ ^ false ].
	(type beginsWith: 't') ifTrue: [ (type allSatisfy: [ :c | c isLetter or: [ c isDigit ] ]) ifTrue: [ ^ false ] ].
	^ true
]
