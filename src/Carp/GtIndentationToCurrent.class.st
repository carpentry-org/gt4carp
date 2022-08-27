Class {
	#name : #GtIndentationToCurrent,
	#superclass : #GtIndentation,
	#category : #'Carp-Formatting'
}

{ #category : #accessing }
GtIndentationToCurrent >> addToFormatter: aFormatter withNextSize: aNumber [
	aFormatter indentToCurrent
]
