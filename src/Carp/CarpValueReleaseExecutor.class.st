"
I am the finalizer {{gtClass:name=CarpValueResourceManager}} registers for
a remote value: when the proxy is collected (in the same image session I
was created in), I ask the resource class to release the remote reference.
"
Class {
	#name : #CarpValueReleaseExecutor,
	#superclass : #Object,
	#instVars : [
		'session',
		'data',
		'resourceClass'
	],
	#category : #'Carp-Execution'
}

{ #category : #finalization }
CarpValueReleaseExecutor >> finalize [
	session = Smalltalk session ifFalse: [ ^ self ].
	resourceClass finalizeResourceData: data
]

{ #category : #initialization }
CarpValueReleaseExecutor >> initialize [
	super initialize.
	session := Smalltalk session
]

{ #category : #accessing }
CarpValueReleaseExecutor >> resourceClass: aResourceClass data: aData [
	resourceClass := aResourceClass.
	data := aData
]
