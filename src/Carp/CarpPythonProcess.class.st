Class {
	#name : #CarpPythonProcess,
	#superclass : #CarpProcess,
	#category : #'Carp-Processes'
}

{ #category : #accessing }
CarpPythonProcess class >> program [
	^ 'python'
]

{ #category : #accessing }
CarpPythonProcess >> programFile [
	^ 'src/languagelink.py'
]
