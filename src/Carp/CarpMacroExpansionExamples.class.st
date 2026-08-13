"
Examples for the macro stepper. They run against a
{{gtClass:name=CarpMacroExpansionStub}}, so they need no server and no
compiler: what they pin down is the stepping itself — walking into a
subform, replaying history, and the fixpoint.
"
Class {
	#name : #CarpMacroExpansionExamples,
	#superclass : #Object,
	#category : #'Carp-Tools'
}

{ #category : #examples }
CarpMacroExpansionExamples >> expansion [
	"A stepper over a form whose macro sits inside a definition body, which
	is the case a top-level-only expansion never gets to."

	<gtExample>
	<return: #CarpMacroExpansion>
	| stub |
	stub := CarpMacroExpansionStub
			expanding: (Dictionary new
					at: '(when true (println* "x"))' put: '(if true (println* "x") ())';
					at: '(println* "x")' put: '(IO.println (ref (str "x")))';
					yourself).
	stub fullExpansion: '(defn f [] (if true (IO.println (ref (str "x"))) ()))'.
	^ (CarpMacroExpansion
		onSource: '(defn f [] (when true (println* "x")))'
		session: 'examples')
		expander: stub;
		yourself
]

{ #category : #examples }
CarpMacroExpansionExamples >> steppingIntoASubform [
	"The first step rewrites the `when` inside the body and leaves the
	definition around it untouched."

	<gtExample>
	<return: #CarpMacroExpansion>
	| expansion |
	expansion := self expansion.
	self assert: expansion step.
	self assert: expansion current equals: '(defn f [] (if true (println* "x") ()))'.
	^ expansion
]

{ #category : #examples }
CarpMacroExpansionExamples >> steppingToTheFixpoint [
	"Stepping stops when nothing expands any further, and says so."

	<gtExample>
	<return: #CarpMacroExpansion>
	| expansion |
	expansion := self expansion.
	expansion stepToFixpoint.
	self assert: expansion stepCount equals: 2.
	self assert: expansion current equals: '(defn f [] (if true (IO.println (ref (str "x"))) ()))'.
	self assert: expansion isAtFixpoint.
	^ expansion
]

{ #category : #examples }
CarpMacroExpansionExamples >> steppingBackKeepsTheHistory [
	"Back moves through the history rather than discarding it, so stepping
	forward again replays instead of recomputing."

	<gtExample>
	<return: #CarpMacroExpansion>
	| expansion |
	expansion := self steppingToTheFixpoint.
	expansion stepBack.
	self assert: expansion position equals: 2.
	self assert: expansion stepCount equals: 2.
	self assert: expansion step.
	self assert: expansion position equals: 3.
	^ expansion
]

{ #category : #examples }
CarpMacroExpansionExamples >> resetReturnsToTheFormAsWritten [
	<gtExample>
	<return: #CarpMacroExpansion>
	| expansion |
	expansion := self steppingToTheFixpoint.
	expansion reset.
	self assert: expansion position equals: 1.
	self assert: expansion current equals: '(defn f [] (when true (println* "x")))'.
	self assert: expansion stepCount equals: 2.
	^ expansion
]

{ #category : #examples }
CarpMacroExpansionExamples >> diffComparesTheStepWithItsPredecessor [
	<gtExample>
	<return: #CarpMacroExpansion>
	| expansion |
	expansion := self steppingIntoASubform.
	self
		assert: expansion previous
		equals: '(defn f [] (when true (println* "x")))'.
	^ expansion
]
