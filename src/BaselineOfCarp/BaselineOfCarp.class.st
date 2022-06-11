Class {
	#name : #BaselineOfCarp,
	#superclass : #BaselineOf,
	#category : #BaselineOfCarp
}

{ #category : #baseline }
BaselineOfCarp >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				baseline: 'GToolkit4SmaCC'
				with: [ spec repository: 'github://feenkcom/gt4smacc:main/src' ].
			spec package: 'Carp' with: [ spec requires: #('GToolkit4SmaCC') ].
			spec package: 'Carp-Parser' with: [ spec requires: #('GToolkit4SmaCC') ].
			spec package: 'Carp-AST' with: [ spec requires: #('GToolkit4SmaCC') ] ]
]
