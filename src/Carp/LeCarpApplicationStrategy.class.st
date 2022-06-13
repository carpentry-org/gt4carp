Class {
	#name : #LeCarpApplicationStrategy,
	#superclass : #LeExternalServerStrategy,
	#category : #'Carp-Lepiter'
}

{ #category : #accessing }
LeCarpApplicationStrategy class >> strategyName [

	^ #global
]

{ #category : #accessing }
LeCarpApplicationStrategy >> applicationServer [

	content database isDatabase ifFalse: [ ^ nil ].
	CarpApplication uniqueInstance ifNil:
		[ CarpApplication uniqueInstance: (self newCarpApplicationFor: content database) ].
	^ CarpApplication uniqueInstance
]

{ #category : #accessing }
LeCarpApplicationStrategy >> applicationSettings [
	"Answer the settings that will be used by the server.
	This musn't actually start the server as that should be deferred until a snippet is evaluated for the first time."

	^ CarpApplication isRunning ifTrue:
		[ CarpApplication uniqueInstance settings ]
	ifFalse:
		[ self updatedSettings: CarpApplication defaultSettings ]
]

{ #category : #accessing }
LeCarpApplicationStrategy >> newCarpApplicationFor: aLeDatabase [

	^ CarpApplication new initializeWith: 
		(self updatedSettings: LanguageLinkSettings carpDefaultSettings).

]

{ #category : #accessing }
LeCarpApplicationStrategy >> updatedSettings: applicationCarpSettings [
	"Update the supplied settings with the lepiter configuration"

	| lepiterCarpSettings lepiterDatabase carpDir |
	lepiterDatabase := content database.
	(lepiterDatabase isKindOf: LeNullDatabase)
		ifTrue: [ ^ applicationCarpSettings ].
	lepiterCarpSettings := lepiterDatabase properties carpLinkSettings.
	lepiterCarpSettings directory
		ifNotNil: [ :relativeDir | 
			carpDir := lepiterDatabase localStoreRootDirectory resolve: relativeDir.
			applicationCarpSettings workingDirectory: carpDir ].	"lepiterCarpSettings carpPath ifNotNil:
		[ :carpPath | applicationCarpSettings serverExecutable: carpPath ]."
	applicationCarpSettings serverDebugMode: lepiterCarpSettings serverDebugMode.

	^ applicationCarpSettings
]
