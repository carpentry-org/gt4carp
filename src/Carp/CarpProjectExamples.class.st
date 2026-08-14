"
Examples for the project model. They work on a scratch repository written
to a temporary directory, so they exercise the real path — the server walks
the load graph, definitions carry file spans, and editing writes bytes back
— without touching anything you care about.

They need a carp server, which the client starts on demand.
"
Class {
	#name : #CarpProjectExamples,
	#superclass : #Object,
	#instVars : [
		'directory'
	],
	#category : #'Carp-Project'
}

{ #category : #accessing }
CarpProjectExamples >> directory [
	"A scratch repository: an entry file that loads one module file."

	directory ifNotNil: [ ^ directory ].
	directory := FileLocator temp / ('carp-project-example-' , UUID new asString36).
	directory ensureCreateDirectory.
	(directory / 'main.carp')
		writeStreamDo: [ :stream |
			stream
				nextPutAll: '(load "shapes.carp")';
				lf;
				nextPutAll: '(Project.config "title" "example")';
				lf ].
	(directory / 'shapes.carp')
		writeStreamDo: [ :stream |
			stream
				nextPutAll: '(defmodule Shapes';
				lf;
				nextPutAll: '  (deftype Circle [radius Double])';
				lf;
				lf;
				nextPutAll: '  (doc area "the area of a circle.")';
				lf;
				nextPutAll: '  (private area)';
				lf;
				nextPutAll: '  (defn area [c]';
				lf;
				nextPutAll: '    (* 3.14159 (* @(Circle.radius c) @(Circle.radius c))))';
				lf;
				lf;
				nextPutAll: '  (meta-set! a-unit-circle "example" true)';
				lf;
				nextPutAll: '  (defn a-unit-circle []';
				lf;
				nextPutAll: '    (Circle.init 1.0))';
				lf;
				nextPutAll: ')';
				lf ].
	^ directory
]

{ #category : #examples }
CarpProjectExamples >> project [
	"The scratch repository as a project: its load order, files and
	definitions, read through the server."

	<gtExample>
	<return: #CarpProject>
	| project |
	project := CarpProject onRoot: self directory fullName.
	self assert: project projectFiles size equals: 2.
	self assert: (project moduleNames includes: 'Shapes').
	^ project
]

{ #category : #examples }
CarpProjectExamples >> definitionsCarryTheirSpans [
	"Every definition slices exactly its own text out of its file, which is
	what editing in place depends on."

	<gtExample>
	<return: #CarpProject>
	| project |
	project := self project.
	project definitions
		do: [ :each | self assert: (each source beginsWith: '(' , each head) ].
	^ project
]

{ #category : #examples }
CarpProjectExamples >> definitionsOwnTheirAnnotations [
	"What is said about a definition belongs to it: its documentation, its
	visibility, and whether it is an example are read from the forms that
	name it, and those forms are not definitions of their own."

	<gtExample>
	<return: #CarpProject>
	| project area example |
	project := self project.
	area := project definitionNamed: 'Shapes.area'.
	self assert: area documentation equals: 'the area of a circle.'.
	self assert: area isPrivate.
	self assert: area isExample not.
	example := project definitionNamed: 'Shapes.a-unit-circle'.
	self assert: example isExample.
	self assert: example kind equals: #example.
	self assert: (project definitionNamed: 'Shapes.Circle') kind equals: #type.
	self assert: (project definitions noneSatisfy: [ :each | each head = 'doc' ]).
	^ project
]

{ #category : #examples }
CarpProjectExamples >> documentationIsWrittenBackAndTakenAway [
	"Editing documentation writes the (doc …) form into the file — creating
	one where there was none — and emptying it takes the form away without
	disturbing anything around it."

	<gtExample>
	<return: #CarpProject>
	| project before |
	project := self project.
	before := (project definitionNamed: 'Shapes.area') file contents.
	(project definitionNamed: 'Shapes.diameter')
		ifNil: [ (project moduleNamed: 'Shapes')
				addDefinition: '(defn diameter [c]
    (* 2.0 @(Circle.radius c)))'.
			project reload.
			before := (project definitionNamed: 'Shapes.area') file contents ].
	(project definitionNamed: 'Shapes.diameter') saveDocumentation: 'twice the radius.'.
	project reload.
	self
		assert: (project definitionNamed: 'Shapes.diameter') documentation
		equals: 'twice the radius.'.
	(project definitionNamed: 'Shapes.diameter') saveDocumentation: ''.
	project reload.
	self assert: (project definitionNamed: 'Shapes.diameter') documentation equals: ''.
	self assert: (project definitionNamed: 'Shapes.area') file contents equals: before.
	^ project
]

{ #category : #examples }
CarpProjectExamples >> savingADefinitionRewritesItsFile [
	"Saving replaces a definition's bytes and leaves everything around it —
	its doc form, its neighbours, the module's parens — untouched."

	<gtExample>
	<return: #CarpProject>
	| project definition |
	project := self project.
	definition := project definitionNamed: 'Shapes.area'.
	definition save: '(defn area [c]
    (let [r @(Circle.radius c)]
      (* 3.14159 (* r r))))'.
	self assert: (definition file contents includesSubstring: '(doc area "the area of a circle.")').
	self assert: (definition file contents includesSubstring: '(let [r @(Circle.radius c)]').
	self assert: definition source equals: definition source trimBoth.
	^ project
]

{ #category : #examples }
CarpProjectExamples >> addingAndDeletingRoundTrips [
	"A definition added to a module and then deleted leaves the file exactly
	as it was."

	<gtExample>
	<return: #CarpProject>
	| project before after |
	project := self project.
	before := (project definitionNamed: 'Shapes.area') file contents.
	(project moduleNamed: 'Shapes') addDefinition: '(defn diameter [c]
    (* 2.0 @(Circle.radius c)))'.
	project reload.
	self assert: (project definitionNamed: 'Shapes.diameter') notNil.
	(project definitionNamed: 'Shapes.diameter') delete.
	project reload.
	self assert: (project definitionNamed: 'Shapes.diameter') isNil.
	after := (project definitionNamed: 'Shapes.area') file contents.
	self assert: after equals: before.
	^ project
]
