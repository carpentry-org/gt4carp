"
The view model of a definition coder. Saving is a view-model
responsibility in GT — the save shortcut asks the view model, not the coder
— so this is where writing a definition back is hooked in.
"
Class {
	#name : #GtCarpDefinitionCoderViewModel,
	#superclass : #GtCarpSnippetCoderViewModel,
	#category : #'Carp-Project'
}

{ #category : #accessing }
GtCarpDefinitionCoderViewModel >> save [
	"Write the definition back through its span and commit its file."

	<return: #Boolean>
	^ [ self coderModel acceptSource: self coderModel currentSourceString.
	true ]
		on: Error
		do: [ :e | false ]
]
