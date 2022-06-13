Class {
	#name : #CarpPostMortemStackFrame,
	#superclass : #GtJavaScriptPostMortemStackFrame,
	#instVars : [
		'source'
	],
	#category : #'Carp-Debugger'
}

{ #category : #accessing }
CarpPostMortemStackFrame >> source: aString [
	source := aString
]

{ #category : #accessing }
CarpPostMortemStackFrame >> sourceText [
	^ source
]
