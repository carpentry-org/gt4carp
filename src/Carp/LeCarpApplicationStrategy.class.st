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
	JSLinkApplication uniqueInstance ifNil:
		[ JSLinkApplication uniqueInstance: (self newJavaScriptApplicationFor: content database) ].
	^ JSLinkApplication uniqueInstance
]

{ #category : #accessing }
LeCarpApplicationStrategy >> applicationSettings [
	"Answer the settings that will be used by the server.
	This musn't actually start the server as that should be deferred until a snippet is evaluated for the first time."

	^ JSLinkApplication isRunning ifTrue:
		[ JSLinkApplication uniqueInstance settings ]
	ifFalse:
		[ self updatedSettings: JSLinkApplication defaultSettings ]
]

{ #category : #accessing }
LeCarpApplicationStrategy >> newJavaScriptApplicationFor: aLeDatabase [

	^ JSLinkApplication new initializeWith: 
		(self updatedSettings: LanguageLinkSettings carpDefaultSettings).

]

{ #category : #accessing }
LeCarpApplicationStrategy >> updatedSettings: applicationCarpSettings [
	"Update the supplied settings with the lepiter configuration"
	| lepiterCarpSettings lepiterDatabase carpDir |

	lepiterDatabase := content database.
	lepiterCarpSettings := lepiterDatabase properties carpLinkSettings.
	lepiterCarpSettings directory ifNotNil:
		[ :relativeDir | 
			carpDir := lepiterDatabase localStoreRootDirectory resolve: relativeDir.
			applicationCarpSettings workingDirectory: carpDir ].
	"lepiterCarpSettings carpPath ifNotNil:
		[ :carpPath | applicationCarpSettings serverExecutable: carpPath ]."
	applicationCarpSettings serverDebugMode: lepiterCarpSettings serverDebugMode.

	^ applicationCarpSettings
]
