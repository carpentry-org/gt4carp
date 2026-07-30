"
I am the coder view model of Carp snippets. Like
{{gtClass:name=GtPharoSnippetCoderViewModel}} I exist to provide the
language's completion strategy to the editor.
"
Class {
	#name : #GtCarpSnippetCoderViewModel,
	#superclass : #GtSourceCoderViewModel,
	#category : #'Carp-Coder'
}

{ #category : #accessing }
GtCarpSnippetCoderViewModel >> newCompletionStrategy [
	^ CarpCompletionStrategy new coder: self coderModel
]
