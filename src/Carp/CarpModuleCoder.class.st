Class {
	#name : #CarpModuleCoder,
	#superclass : #GtCoderModel,
	#traits : 'TGtCoderTrait',
	#classTraits : 'TGtCoderTrait classTrait',
	#instVars : [
		'module'
	],
	#category : #'Carp-Coder'
}

{ #category : #'instance creation' }
CarpModuleCoder class >> forModule: aCarpModule [
	^ self new module: aCarpModule
]

{ #category : #accessing }
CarpModuleCoder >> asCoderViewModel [
	^ CarpModuleCoderViewModel new coder: self
]

{ #category : #accessing }
CarpModuleCoder >> coderName [
	"Return a short textual name of the coder.
	For example, class coder would return a class name, package coder returns a package name."
	<return: #String>

	^ self module name
]

{ #category : #'instance creation' }
CarpModuleCoder >> module [
	^ module
]

{ #category : #'instance creation' }
CarpModuleCoder >> module: aCarpModule [ 
	module := aCarpModule
]
