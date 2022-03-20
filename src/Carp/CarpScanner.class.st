Class {
	#name : #CarpScanner,
	#superclass : #SmaCCScanner,
	#category : #Carp
}

{ #category : #generated }
CarpScanner >> emptySymbolTokenId [

	^ 35
]

{ #category : #generated }
CarpScanner >> errorTokenId [

	^ 36
]

{ #category : #generated }
CarpScanner >> scan1 [

	[ 
	self step.
	currentCharacter == $" ifTrue: [ ^ self recordAndReportMatch: #( 5 ) ].
	currentCharacter == $\ ifTrue: [ 
		self step.
		^ self scan1 ].
	true ] whileTrue
]

{ #category : #generated }
CarpScanner >> scan2 [

	self step.
	currentCharacter isDigit ifTrue: [ 
		[ 
		self recordMatch: #( 14 ).
		self step.
		currentCharacter == $f ifTrue: [ 
			^ self recordAndReportMatch: #( 14 ) ].
		currentCharacter isDigit ] whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scan3 [

	[ 
	self recordMatch: #( 14 ).
	self step.
	currentCharacter == $. ifTrue: [ ^ self scan2 ].
	currentCharacter isDigit ] whileTrue.
	('bfl' includes: currentCharacter) ifTrue: [ 
		^ self recordAndReportMatch: #( 14 ) ].
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scan4 [

	(self scanForString: 'ac') ifTrue: [ ^ self scan5 ].
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scan5 [

	self step.
	currentCharacter == $e ifTrue: [ 
		^ self recordAndReportMatch: #( 17 ) ].
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scanForToken [

	self step.
	currentCharacter == $" ifTrue: [ ^ self scan1 ].
	currentCharacter == $% ifTrue: [ ^ self scanForTokenX7 ].
	currentCharacter == $& ifTrue: [ ^ self recordAndReportMatch: #( 3 ) ].
	currentCharacter == $( ifTrue: [ ^ self recordAndReportMatch: #( 6 ) ].
	currentCharacter == $) ifTrue: [ ^ self recordAndReportMatch: #( 7 ) ].
	currentCharacter == $, ifTrue: [ 
		^ self recordAndReportMatch: #( 15 ) ].
	currentCharacter == $. ifTrue: [ 
		^ self recordAndReportMatch: #( 11 ) ].
	currentCharacter == $0 ifTrue: [ ^ self scanForTokenX2 ].
	currentCharacter == $; ifTrue: [ ^ self scanForTokenX5 ].
	currentCharacter == $@ ifTrue: [ ^ self recordAndReportMatch: #( 4 ) ].
	currentCharacter == $[ ifTrue: [ 
		^ self recordAndReportMatch: #( 12 ) ].
	^ self scanForTokenX8
]

{ #category : #generated }
CarpScanner >> scanForTokenX1 [

	self step.
	currentCharacter == $b ifTrue: [ 
		self recordMatch: #( 17 ).
		self step.
		currentCharacter == $a ifTrue: [ 
			(self scanForString: 'cksp') ifTrue: [ ^ self scan4 ] ].
		^ self reportLastMatch ].
	currentCharacter == $f ifTrue: [ 
		self recordMatch: #( 17 ).
		self step.
		currentCharacter == $o ifTrue: [ 
			(self scanForString: 'rmfeed') ifTrue: [ 
				^ self recordAndReportMatch: #( 17 ) ] ].
		^ self reportLastMatch ].
	currentCharacter == $n ifTrue: [ 
		self recordMatch: #( 17 ).
		self step.
		currentCharacter == $e ifTrue: [ 
			(self scanForString: 'wlin') ifTrue: [ ^ self scan5 ] ].
		^ self reportLastMatch ].
	currentCharacter == $o ifTrue: [ 
		self recordMatch: #( 17 ).
		self step.
		(currentCharacter between: $0 and: $7) ifTrue: [ 
			self step.
			(currentCharacter between: $0 and: $7) ifTrue: [ 
				self step.
				(currentCharacter between: $0 and: $7) ifTrue: [ 
					^ self recordAndReportMatch: #( 17 ) ] ] ].
		^ self reportLastMatch ].
	currentCharacter == $r ifTrue: [ 
		self recordMatch: #( 17 ).
		self step.
		currentCharacter == $e ifTrue: [ 
			(self scanForString: 'turn') ifTrue: [ 
				^ self recordAndReportMatch: #( 17 ) ] ].
		^ self reportLastMatch ].
	currentCharacter == $s ifTrue: [ 
		self recordMatch: #( 17 ).
		self step.
		currentCharacter == $p ifTrue: [ ^ self scan4 ].
		^ self reportLastMatch ].
	currentCharacter == $t ifTrue: [ 
		self recordMatch: #( 17 ).
		self step.
		currentCharacter == $a ifTrue: [ 
			self step.
			currentCharacter == $b ifTrue: [ 
				^ self recordAndReportMatch: #( 17 ) ] ].
		^ self reportLastMatch ].
	currentCharacter == $u ifTrue: [ ^ self scanForTokenX1X1 ].
	^ self recordAndReportMatch: #( 17 )
]

{ #category : #generated }
CarpScanner >> scanForTokenX1X1 [

	self recordMatch: #( 17 ).
	self step.
	(currentCharacter isDigit or: [ currentCharacter between: $A and: $F ]) 
		ifTrue: [ 
			self step.
			(currentCharacter isDigit or: [ 
				 currentCharacter between: $A and: $F ]) ifTrue: [ 
				self step.
				(currentCharacter isDigit or: [ 
					 currentCharacter between: $A and: $F ]) ifTrue: [ 
					self step.
					(currentCharacter isDigit or: [ 
						 currentCharacter between: $A and: $F ]) ifTrue: [ 
						^ self recordAndReportMatch: #( 17 ) ] ] ] ].
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scanForTokenX2 [

	self recordMatch: #( 14 ).
	self step.
	currentCharacter == $. ifTrue: [ ^ self scan2 ].
	currentCharacter == $b ifTrue: [ 
		self recordMatch: #( 14 ).
		self step.
		(currentCharacter between: $0 and: $1) ifTrue: [ 
			^ self recordAndReportMatch: #( 14 ) ].
		^ self reportLastMatch ].
	currentCharacter == $x ifTrue: [ 
		self step.
		(currentCharacter isDigit or: [ 
			 (currentCharacter between: $A and: $F) or: [ 
				 currentCharacter between: $a and: $f ] ]) ifTrue: [ 
			^ self recordAndReportMatch: #( 14 ) ].
		^ self reportLastMatch ].
	currentCharacter isDigit ifTrue: [ ^ self scan3 ].
	('fl' includes: currentCharacter) ifTrue: [ 
		^ self recordAndReportMatch: #( 14 ) ].
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scanForTokenX3 [

	[ 
	self recordMatch: #( 10 ).
	self step.
	currentCharacter isLowercase or: [ 
		currentCharacter isUppercase or: [ 
			currentCharacter isDigit or: [ 
				('!$' includes: currentCharacter) or: [ 
					(currentCharacter between: $* and: $+) or: [ 
						('-/:' includes: currentCharacter) or: [ 
							(currentCharacter between: $< and: $?) or: [ 
								currentCharacter == $_ ] ] ] ] ] ] ] ] whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scanForTokenX4 [

	[ 
	self recordMatch: #( 9 ).
	self step.
	currentCharacter isLowercase or: [ 
		currentCharacter isUppercase or: [ 
			currentCharacter isDigit or: [ 
				('!$' includes: currentCharacter) or: [ 
					(currentCharacter between: $* and: $+) or: [ 
						('-/:' includes: currentCharacter) or: [ 
							(currentCharacter between: $< and: $?) or: [ 
								currentCharacter == $_ ] ] ] ] ] ] ] ] whileTrue
]

{ #category : #generated }
CarpScanner >> scanForTokenX5 [

	[ 
	self recordMatch: #( 15 ).
	self step.
	currentCharacter <= Character tab or: [ 
		(currentCharacter between: Character pageUp and: Character newPage) 
			or: [ currentCharacter >= (Character value: 14) ] ] ] whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scanForTokenX6 [

	[ 
	self recordMatch: #( 16 ).
	self step.
	currentCharacter isSeparator or: [ 
		currentCharacter == Character pageUp ] ] whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scanForTokenX7 [

	self recordMatch: #( 1 ).
	self step.
	currentCharacter == $@ ifTrue: [ ^ self recordAndReportMatch: #( 2 ) ].
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> scanForTokenX8 [

	currentCharacter == $\ ifTrue: [ ^ self scanForTokenX1 ].
	currentCharacter == $] ifTrue: [ 
		^ self recordAndReportMatch: #( 13 ) ].
	currentCharacter isDigit ifTrue: [ ^ self scan3 ].
	('''`' includes: currentCharacter) ifTrue: [ 
		^ self recordAndReportMatch: #( 8 ) ].
	(currentCharacter isSeparator or: [ 
		 currentCharacter == Character pageUp ]) ifTrue: [ 
		^ self scanForTokenX6 ].
	currentCharacter isUppercase ifTrue: [ ^ self scanForTokenX3 ].
	(currentCharacter isLowercase or: [ 
		 ('!$' includes: currentCharacter) or: [ 
			 (currentCharacter between: $* and: $+) or: [ 
				 ('-/:' includes: currentCharacter) or: [ 
					 (currentCharacter between: $< and: $?) or: [ 
						 currentCharacter == $_ ] ] ] ] ]) ifTrue: [ 
		self scanForTokenX4 ].
	^ self reportLastMatch
]

{ #category : #generated }
CarpScanner >> tokenActions [

	^ #( nil nil nil nil nil nil nil nil nil nil nil nil nil nil #comment
	     #whitespace )
]
