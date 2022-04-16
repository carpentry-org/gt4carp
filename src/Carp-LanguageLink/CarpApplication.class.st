Class {
	#name : #CarpApplication,
	#superclass : #LanguageLinkApplication,
	#instVars : [
		'uniqueInstance'
	],
	#category : #'Carp-LanguageLink'
}

{ #category : #'start-stop' }
CarpApplication class >> start [

	^ self startWith: LanguageLinkSettings jsDefaultSettings.
]

{ #category : #accessing }
CarpApplication >> baseApplication [
	^ CarpApplication
]

{ #category : #accessing }
CarpApplication >> initializeHandlers [
	loggingHandler := LanguageLinkLoggingHandler application: self.
	communicationHandler := LanguageLinkCommunicationHandler application: self.
	processHandler := LanguageLinkServerHandler application: self.
	"executionHandler := CarpExecutionHandler application: self"
]
