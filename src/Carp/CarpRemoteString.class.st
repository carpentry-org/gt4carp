"
I am a live Carp `String`.

The value host renders a string well enough on its own — the text and its
bytes are Carp-side views. What it cannot do is hand the string to the rest
of GT, so that is what I add: {{gtMethod:name=CarpRemoteString>>#asString}}
answers a Pharo String, and my Text view is that String's, which brings
search, wrapping and the usual editor with it.
"
Class {
	#name : #CarpRemoteString,
	#superclass : #CarpRemoteValue,
	#category : #'Carp-Execution'
}

{ #category : #'instance creation' }
CarpRemoteString class >> remoteTypeName [
	^ 'String'
]

{ #category : #converting }
CarpRemoteString >> asString [
	"The string itself, in the image. A Carp string prints as its contents,
	so the print string is the value."

	^ self printString
]

{ #category : #inspecting }
CarpRemoteString >> gtTextFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Text';
		priority: 2;
		text: [ self asString ]
]

{ #category : #inspecting }
CarpRemoteString >> gtSizeFor: aView [
	<gtView>
	^ aView explicit
		title: 'Size';
		priority: 20;
		stencil: [ BrLabel new
				aptitude: (BrGlamorousLabelAptitude new glamorousCodeFont);
				padding: (BlInsets all: 10);
				text: self asString size printString , ' characters' ]
]
