Class {
	#name : #CarpFile,
	#superclass : #Object,
	#instVars : [
		'fileName',
		'contents'
	],
	#category : #'Carp-IDE'
}

{ #category : #example }
CarpFile class >> coreLoadStatements [

	<gtExample>
	| loadStatements files carpFiles cFiles aDict nodes loadNodes s contents |
	"the load statements in carp"
	loadStatements := { 'load'. 'load-once'. 'system-include' }.

	"get all the carp and c files in the standard library (assumes that there is a carp directory in the home folder"
	files := (FileLocator home / 'carp/core') children.
	carpFiles := files select: [ :aFile | aFile extension = 'carp' ].
	cFiles := files select: [ :aFile | aFile extension = 'h' ].

	"get a mapping from all files to all the files they load"
	aDict := Dictionary new.

	carpFiles do: [ :aCarpFile | 
		contents := CarpParser parse: aCarpFile contents.

		nodes := OrderedCollection new.
		contents allNodesOfType: CarpListNode do: [ :c | nodes add: c ].

		loadNodes := nodes select: [ :aNode | 
			             aNode expressions size > 0 and: [ 
				              (aNode expressions first isKindOf: CarpVariableNode)  
				             and: [ 
				             loadStatements includes:
					             aNode expressions first value value ] ] ].

		aDict at: aCarpFile basename put: (loadNodes collect: [ :aNode | 
				 s := aNode expressions second value value.
				 s copyFrom: 2 to: s size - 1 ]) ].

	cFiles do: [ :aCFile | 
		aDict at: aCFile basename put: OrderedCollection new ].

	^ aDict

]

{ #category : #'instance creation' }
CarpFile class >> for: aFileName [
	^ self new for: aFileName
]

{ #category : #accessing }
CarpFile >> contents [

	^ contents
]

{ #category : #accessing }
CarpFile >> contents: aString [
	contents := aString
]

{ #category : #accessing }
CarpFile >> fileName: aFileName [
	fileName := aFileName
]

{ #category : #accessing }
CarpFile >> for: aFileName [
	self fileName: aFileName.
	self contents: (CarpParser parse: aFileName asFileReference contents).
]
