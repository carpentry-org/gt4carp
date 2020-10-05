Class {
	#name : #CarpScanner,
	#superclass : #SmaCCScanner,
	#category : #Carp
}

{ #category : #generated }
CarpScanner >> emptySymbolTokenId [
	^ 26
]

{ #category : #generated }
CarpScanner >> errorTokenId [
	^ 27
]

{ #category : #generated }
CarpScanner >> scan1 [
	[ self step.
	currentCharacter == $"
		ifTrue: [ ^ self recordAndReportMatch: #(1) ].
	currentCharacter == $\
		ifTrue: [ self step.
			(currentCharacter <= Character tab
				or: [ (currentCharacter between: Character pageUp and: Character newPage)
						or: [ currentCharacter >= (Character value: 14) ] ])
				ifTrue: [ ^ self scan2 ].
			^ self reportLastMatch ].
	true ] whileTrue
]

{ #category : #generated }
CarpScanner >> scan2 [
	[ self step.
	currentCharacter == $"
		ifTrue: [ [ self recordMatch: #(1).
			self step.
			currentCharacter == $" ] whileTrue.
			(currentCharacter == Character lf
				or: [ currentCharacter == Character cr ])
				ifTrue: [ ^ self scan1 ].
			^ self scan2 ].
	(currentCharacter == Character lf
		or: [ currentCharacter == Character cr ])
		ifTrue: [ ^ self scan1 ].
	true ] whileTrue
]

{ #category : #generated }
CarpScanner >> scan3 [
	self step.
	currentCharacter isDigit
		ifTrue: [ [ self recordMatch: #(11).
			self step.
			currentCharacter == $f
				ifTrue: [ ^ self recordAndReportMatch: #(11) ].
			currentCharacter isDigit ] whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scan4 [
	[ self recordMatch: #(11).
	self step.
	currentCharacter == $.
		ifTrue: [ ^ self scan3 ].
	currentCharacter isDigit ] whileTrue.
	('bfl' includes: currentCharacter)
		ifTrue: [ ^ self recordAndReportMatch: #(11) ].
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scanForToken [
	self step.
	currentCharacter == $"
		ifTrue: [ ^ self scan1 ].
	currentCharacter == $'
		ifTrue: [ ^ self recordAndReportMatch: #(4) ].
	currentCharacter == $(
		ifTrue: [ ^ self recordAndReportMatch: #(2) ].
	currentCharacter == $)
		ifTrue: [ ^ self recordAndReportMatch: #(3) ].
	currentCharacter == $.
		ifTrue: [ ^ self recordAndReportMatch: #(8) ].
	^ self scanForTokenX5
]

{ #category : #generated }
CarpScanner >> scanForTokenX1 [
	self recordMatch: #(11).
	self step.
	currentCharacter == $.
		ifTrue: [ ^ self scan3 ].
	currentCharacter == $b
		ifTrue: [ self recordMatch: #(11).
			self step.
			(currentCharacter between: $0 and: $1)
				ifTrue: [ ^ self recordAndReportMatch: #(11) ].
			^ self reportLastMatch ].
	currentCharacter == $x
		ifTrue: [ self step.
			(currentCharacter isDigit
				or: [ (currentCharacter between: $A and: $F)
						or: [ currentCharacter between: $a and: $f ] ])
				ifTrue: [ ^ self recordAndReportMatch: #(11) ].
			^ self reportLastMatch ].
	currentCharacter isDigit
		ifTrue: [ ^ self scan4 ].
	('fl' includes: currentCharacter)
		ifTrue: [ ^ self recordAndReportMatch: #(11) ].
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scanForTokenX2 [
	[ self recordMatch: #(6).
	self step.
	currentCharacter isLowercase
		or: [ currentCharacter isDigit
				or: [ ('!$' includes: currentCharacter)
						or: [ (currentCharacter between: $* and: $+)
								or: [ ('/:' includes: currentCharacter)
										or: [ (currentCharacter between: $< and: $?)
												or: [ currentCharacter == $_ ] ] ] ] ] ] ] whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scanForTokenX3 [
	[ self recordMatch: #(5).
	self step.
	currentCharacter isLowercase
		or: [ currentCharacter isDigit
				or: [ ('!$' includes: currentCharacter)
						or: [ (currentCharacter between: $* and: $+)
								or: [ ('/:' includes: currentCharacter)
										or: [ (currentCharacter between: $< and: $?)
												or: [ currentCharacter == $_ ] ] ] ] ] ] ] whileTrue
]

{ #category : #generated }
CarpScanner >> scanForTokenX4 [
	[ self recordMatch: #(7).
	self step.
	currentCharacter isSpaceSeparator or: [ currentCharacter == $, ] ]
		whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scanForTokenX5 [
	currentCharacter == $0
		ifTrue:
			[ ^ self scanForTokenX1 ].
	currentCharacter == $[
		ifTrue: [ ^ self recordAndReportMatch: #(9) ].
	currentCharacter == $]
		ifTrue: [ ^ self recordAndReportMatch: #(10) ].
	currentCharacter isDigit
		ifTrue: [ ^ self scan4 ].
	(currentCharacter isSpaceSeparator or: [ currentCharacter == $, ])
		ifTrue:
			[ ^ self scanForTokenX4 ].
	currentCharacter isUppercase
		ifTrue:
			[ ^ self scanForTokenX2 ].
	(currentCharacter isLowercase
		or: [ ('!$' includes: currentCharacter)
				or: [ (currentCharacter between: $* and: $+)
						or: [ ('/:' includes: currentCharacter)
								or: [ (currentCharacter between: $< and: $?)
										or: [ currentCharacter == $_ ] ] ] ] ])
		ifTrue:
			[ self scanForTokenX3 ].
	^ self reportLastMatch
]
