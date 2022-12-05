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

	^ self startWith: LanguageLinkSettings carpDefaultSettings.
]

{ #category : #'class initialization' }
CarpApplication class >> startUp: resuming [
	resuming ifTrue: [ self stop ]
]

{ #category : #accessing }
CarpApplication >> baseApplication [
	^ CarpApplication
]

{ #category : #accessing }
CarpApplication >> debuggerClientFor: anException [
	"Answer the debugger client to be used by the Gt Post Mortem debugger"

	^ CarpPostMortemDebugger new exception: anException
]

{ #category : #accessing }
CarpApplication >> initializeHandlers [
	loggingHandler := LanguageLinkLoggingHandler application: self.
	communicationHandler := LanguageLinkCommunicationHandler application: self.
	processHandler := LanguageLinkServerHandler application: self.
	executionHandler := CarpExecutionHandler application: self
]
