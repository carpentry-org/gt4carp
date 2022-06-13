Class {
	#name : #CarpCommand,
	#superclass : #LanguageLinkCommand,
	#category : #'Carp-LanguageLink'
}

{ #category : #accessing }
CarpCommand >> codeForRemote [
	^ (Character space join: self instructions) copyReplaceAll: Character cr asString with: Character lf asString
]
