Class {
	#name : #CarpApplication,
	#superclass : #LanguageLinkApplication,
	#instVars : [
		'uniqueInstance'
	],
	#category : #'Carp-LanguageLink'
}

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
