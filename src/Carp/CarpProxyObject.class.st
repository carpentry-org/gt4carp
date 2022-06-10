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
CarpProxyObject class >> carpType: aType var: aVar application: application [
	^ self new
		carpVariable: aVar;
		carpType: aType;
		application: application;
		yourself
]

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
