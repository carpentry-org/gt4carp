"
I am a live Carp value that is one number, one flag, one character — a value
whose whole content is what it prints.

The host has nothing to show for me beyond that print string, so what I add
is the other direction: {{gtMethod:name=CarpRemoteScalar>>#asPharoValue}}
answers the value as the image understands it, and my subclasses say how to
read it. That is what makes a Carp value usable from Pharo code — counting
an array's elements, charting them, comparing them with something else in
the image.
"
Class {
	#name : #CarpRemoteScalar,
	#superclass : #CarpRemoteValue,
	#category : #'Carp-Execution'
}

{ #category : #converting }
CarpRemoteScalar >> asPharoValue [
	"The value as Pharo would hold it. Subclasses read the print string,
	which for a scalar is the value written out."

	^ self subclassResponsibility
]

{ #category : #inspecting }
CarpRemoteScalar >> gtValueFor: aView [
	<gtView>
	^ aView explicit
		title: 'Value';
		priority: 1;
		stencil: [ BrLabel new
				aptitude: (BrGlamorousLabelAptitude new glamorousCodeFont fontSize: 16);
				padding: (BlInsets all: 12);
				text: self printString ]
]

{ #category : #inspecting }
CarpRemoteScalar >> gtPharoValueFor: aView [
	"What the image makes of me, so the difference between the two is
	visible when there is one."

	<gtView>
	^ aView forward
		title: 'In Pharo';
		priority: 4;
		object: [ self asPharoValue ];
		view: #gtPrintFor:
]
