Class {
	#name : #GtCarpFormatter,
	#superclass : #GtFormatter,
	#traits : 'TCarpExpressionNodeVisitor',
	#classTraits : 'TCarpExpressionNodeVisitor classTrait',
	#category : #'Carp-Formatting'
}

{ #category : #accessing }
GtCarpFormatter >> defaultIndentBy [
	^ 2
]

{ #category : #accessing }
GtCarpFormatter >> defaultMaxWidth [
	^ 80
]

{ #category : #accessing }
GtCarpFormatter >> visitArray: aList [
	| res |
	res := OrderedCollection
			withAll: {GtIndentationToCurrent new.
					'['}.
	aList expressions
		ifEmpty: [ res add: ']' ]
		ifNotEmpty: [ res addAll: (self visit: aList expressions first).
			aList expressions
				allButFirstDo: [ :expression | 
					res
						add: GtSoftBreak new;
						addAll: (self visit: expression) ].
			res add: ']' ].
	res add: GtDedentation new.
	^ res
]

{ #category : #accessing }
GtCarpFormatter >> visitCallableDefinition: aList [
	| res |
	res := OrderedCollection new.
	res add: ' '.
	res addAll: (self visit: aList expressions second).
	res add: ' '.
	res addAll: (self visit: aList expressions third).
	res add: GtHardBreak new.
	4
		to: aList expressions size
		do: [ :index | 
			index > 4 ifTrue: [ res add: GtSoftBreak new ].
			res addAll: (self visit: (aList expressions at: index)) ].
	^ res
]

{ #category : #accessing }
GtCarpFormatter >> visitCase: aList [
	| res |
	res := OrderedCollection new.
	res add: ' '.
	res addAll: (self visit: aList expressions second).
	res add: GtHardBreak new.
	((aList expressions allButFirst: 2) groupsOf: 2)
		do: [ :aGroup | 
			res addAll: (self visit: aGroup first).
			aGroup size > 1
				ifTrue: [ res
						add: GtIndentation new;
						add: GtHardBreak new;
						addAll: (self visit: aGroup second);
						add: GtDedentation new;
						add: GtHardBreak new ] ].
	[ res last isKindOf: GtLineBreak ] whileTrue: [ res removeLast ].
	^ res
]

{ #category : #accessing }
GtCarpFormatter >> visitCond: aList [ 
	| res |
	res := OrderedCollection new.
	res add: GtHardBreak new.	
	(aList expressions allButFirst groupsOf: 2)
		do: [ :aGroup | 
			res
				addAll: (self visit: aGroup first);
				add: GtIndentation new;
				add: GtHardBreak new;
				addAll: (self visit: aGroup second);
				add: GtDedentation new;
				add: GtHardBreak new ].
	[ res last isKindOf: GtLineBreak ] whileTrue: [ res removeLast ].
	^ res
]

{ #category : #accessing }
GtCarpFormatter >> visitDefinition: aList [
	| res |
	res := OrderedCollection new.
	res add: ' '.
	res addAll: (self visit: aList expressions second).
	3
		to: aList expressions size
		do: [ :index | 
			res
				add: GtSoftBreak new;
				addAll: (self visit: (aList expressions at: index)) ].
	^ res
]

{ #category : #generated }
GtCarpFormatter >> visitDeref: aDeref [
	^ (OrderedCollection with: '@')
		addAll: (self visit: aDeref value);
		yourself
]

{ #category : #accessing }
GtCarpFormatter >> visitDo: aList [
	| res |
	res := OrderedCollection new.
	2
		to: aList expressions size
		do: [ :index | 
			res
				add: GtHardBreak new;
				addAll: (self visit: (aList expressions at: index)) ].
	[ res last isKindOf: GtLineBreak ] whileTrue: [ res removeLast ].
	^ res
]

{ #category : #accessing }
GtCarpFormatter >> visitFn: aList [ 
	| res |
	res := OrderedCollection new.
	res add: ' '.
	res addAll: (self visit: aList expressions second).
	res add: GtHardBreak new.
	3
		to: aList expressions size
		do: [ :index | 
			index > 4 ifTrue: [ res add: GtSoftBreak new ].
			res addAll: (self visit: (aList expressions at: index)) ].
	^ res
]

{ #category : #accessing }
GtCarpFormatter >> visitLet: aList [
	| res |
	res := OrderedCollection new.
	res add: ' '.
	res addAll: (self visitLetArray: aList expressions second).
	3
		to: aList expressions size
		do: [ :index | 
			res
				add: GtHardBreak new;
				addAll: (self visit: (aList expressions at: index)) ].
	[ res last isKindOf: GtLineBreak ] whileTrue: [ res removeLast ].
	^ res
]

{ #category : #accessing }
GtCarpFormatter >> visitLetArray: aList [
	| res |
	res := OrderedCollection
			withAll: {GtIndentationToCurrent new.
					'['}.
	(aList expressions groupsOf: 2)
		do: [ :aGroup | 
			res
				addAll: (self visit: aGroup first);
				add: ' ';
				addAll: (self visit: aGroup second);
				add: GtHardBreak new ].
	[ res last isKindOf: GtLineBreak ] whileTrue: [ res removeLast ].
	res add: ']'.
	res add: GtDedentation new.
	^ res
]

{ #category : #accessing }
GtCarpFormatter >> visitList: aList [
	| res |
	res := OrderedCollection
			withAll: {GtIndentation new.
					'('}.
	aList expressions ifNotEmpty: [ res addAll: (self visitListBody: aList) ].
	aList isModuleDefinition ifFalse: [ res add: ')' ].
	res add: GtDedentation new.
	aList isModuleDefinition ifTrue: [ res add: ')' ].
	aList isDefinition
		ifTrue: [ res addAll: {GtHardBreak new } ].
	^ res
]

{ #category : #accessing }
GtCarpFormatter >> visitListBody: aList [
	| res |
	res := OrderedCollection new.
	res addAll: (self visit: aList expressions first).
	aList isCallableDefinition
		ifTrue: [ ^ res
				addAll: (self visitCallableDefinition: aList);
				yourself ].
	aList isFn
		ifTrue: [ ^ res
				addAll: (self visitFn: aList);
				yourself ].
	aList isDefinition
		ifTrue: [ ^ res
				addAll: (self visitDefinition: aList);
				yourself ].
	aList isModuleDefinition
		ifTrue: [ ^ res
				addAll: (self visitModuleDefinition: aList);
				yourself ].
	aList isLet
		ifTrue: [ ^ res
				addAll: (self visitLet: aList);
				yourself ].
	aList isCond
		ifTrue: [ ^ res
				addAll: (self visitCond: aList);
				yourself ].
	aList isCase
		ifTrue: [ ^ res
				addAll: (self visitCase: aList);
				yourself ].
	aList isLoop
		ifTrue: [ ^ res
				addAll: (self visitLoop: aList);
				yourself ].
	aList isDo
		ifTrue: [ ^ res
				addAll: (self visitDo: aList);
				yourself ].
	aList expressions
		allButFirstDo: [ :expression | 
			res
				add: (aList expressions size > 4
						ifTrue: [ GtHardBreak new ]
						ifFalse: [ GtSoftBreak new ]);
				addAll: (self visit: expression) ].
	^ res
]

{ #category : #accessing }
GtCarpFormatter >> visitLoop: aList [
	| res |
	res := OrderedCollection new.
	res add: ' '.
	res addAll: (self visit: aList expressions second).
	3
		to: aList expressions size
		do: [ :index | 
			res
				add: GtHardBreak new;
				addAll: (self visit: (aList expressions at: index)) ].
	[ res last isKindOf: GtLineBreak ] whileTrue: [ res removeLast ].
	^ res
]

{ #category : #accessing }
GtCarpFormatter >> visitModuleDefinition: aList [
	| res |
	res := OrderedCollection new.
	res add: ' '.
	res addAll: (self visit: aList expressions second).
	3
		to: aList expressions size
		do: [ :index | 
			res
				add: GtHardBreak new;
				addAll: (self visit: (aList expressions at: index)) ].
	[ res last isKindOf: GtLineBreak ] whileTrue: [ res removeLast ].
	^ res
]

{ #category : #generated }
GtCarpFormatter >> visitModuleOrType: aModuleOrType [

	^ { aModuleOrType toPharo }
]

{ #category : #generated }
GtCarpFormatter >> visitNumber: aNumber [

	^ { aNumber value source }
]

{ #category : #generated }
GtCarpFormatter >> visitQuote: aQuote [

	^ (OrderedCollection with: '''')
		addAll: (self visit: aQuote value);
		yourself
]

{ #category : #generated }
GtCarpFormatter >> visitRef: aRef [

	^ (OrderedCollection with: '&')
		addAll: (self visit: aRef value);
		yourself
]

{ #category : #generated }
GtCarpFormatter >> visitRefCall: aRefCall [

	^ (OrderedCollection with: '~')
		addAll: (self visit: aRefCall value);
		yourself
]

{ #category : #generated }
GtCarpFormatter >> visitStart: aStart [
	^ aStart expressions
		flatCollect: [ :expression | 
			(self visit: expression)
				add: GtHardBreak new;
				add: GtHardBreak new;
				yourself ]
]

{ #category : #generated }
GtCarpFormatter >> visitString: aString [

	^ { aString value source }
]

{ #category : #generated }
GtCarpFormatter >> visitVariable: aVariable [

	^ { aVariable value source }
]
