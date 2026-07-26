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
		do: [ | externalDeps |
			"GT images already ship SmaCC and gt4smacc; re-resolving them from
			GitHub chases transitive pins (RemoteRunner) that break. Only declare
			external dependencies that are actually missing from the image."
			externalDeps := OrderedCollection new.
			(Smalltalk globals includesKey: #GtSmaCCCoder)
				ifFalse: [ spec
						baseline: 'GToolkit4SmaCC'
						with: [ spec repository: 'github://feenkcom/gt4smacc:main/src' ].
					externalDeps add: 'GToolkit4SmaCC' ].
			(Smalltalk globals includesKey: #GtFormatter)
				ifFalse: [ spec
						baseline: 'GToolkitFormatters'
						with: [ spec repository: 'github://carpentry-org/gtoolkit-formatters:main/src' ].
					externalDeps add: 'GToolkitFormatters' ].
			spec
				package: 'Carp-AST'
				with: [ spec requires: externalDeps asArray ].
			spec
				package: 'Carp-Parser'
				with: [ spec requires: (externalDeps asArray , #('Carp-AST')) ].
			spec
				package: 'Carp-MacroStepper'
				with: [ spec requires: externalDeps asArray ].
			spec
				package: 'Carp'
				with: [ spec requires: (externalDeps asArray , #('Carp-Parser' 'Carp-MacroStepper')) ] ]
]
