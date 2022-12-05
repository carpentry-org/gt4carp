Class {
	#name : #BaselineOfCarp,
	#superclass : #BaselineOf,
	#category : #BaselineOfCarp
}

{ #category : #baseline }
BaselineOfCarp class >> loadLepiter [
	| currentProperties |
	currentProperties := LeDatabasesRegistry defaultLogicalDatabase properties.
	currentProperties
		addRegisteredDirectory: FileLocator imageDirectory / 'pharo-local' / 'iceberg' / 'carpentry-org'
				/ 'gt4carp' / 'lepiter'.

	LeDatabasesRegistry default defaultLogicalDatabase reload
]

{ #category : #baseline }
BaselineOfCarp >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				baseline: 'GToolkit4SmaCC'
				with: [ spec repository: 'github://feenkcom/gt4smacc:main/src' ].
			spec
				baseline: 'GToolkitFormatters'
				with: [ spec repository: 'github://carpentry-org/gtoolkit-formatters:main/src' ].
		spec package: 'Carp' with: [ spec requires: #('GToolkit4SmaCC' 'GToolkitFormatters' 'Carp-Parser') ].
			spec package: 'Carp-AST' with: [ spec requires: #('GToolkit4SmaCC') ].
			spec package: 'Carp-Parser' with: [ spec requires: #('GToolkit4SmaCC' 'Carp-AST') ] ]
]
