Class {
	#name : #CarpFile,
	#superclass : #Object,
	#instVars : [
		'fileName',
		'contents'
	],
	#category : #'Carp-IDE'
}

{ #category : #accessing }
CarpFile >> contents [

	^ contents
]

{ #category : #accessing }
CarpFile >> contents: aString [
	contents := aString
]

{ #category : #accessing }
CarpFile >> fileName: aFileName [
	fileName := aFileName
]

{ #category : #accessing }
CarpFile >> for: aFileName [
	self fileName: aFileName.
	self contents: (CarpParser parse: aFileName asFileReference contents).
]
