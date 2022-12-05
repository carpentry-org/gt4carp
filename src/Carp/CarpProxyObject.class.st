Class {
	#name : #CarpProxyObject,
	#superclass : #Object,
	#instVars : [
		'carpVariable',
		'carpType',
		'application'
	],
	#category : #'Carp-Serialization'
}

{ #category : #accessing }
CarpProxyObject >> application: anObject [
	application := anObject
]

{ #category : #accessing }
CarpProxyObject >> carpType: aType [
	carpType := aType
]

{ #category : #accessing }
CarpProxyObject >> carpVariable: aVar [
	carpVariable := aVar
]
