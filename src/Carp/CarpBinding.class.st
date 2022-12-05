Class {
	#name : #CarpBinding,
	#superclass : #CarpExpression,
	#instVars : [
		'name'
	],
	#category : #'Carp-IDE'
}

{ #category : #'instance creation' }
CarpBinding class >> def [
	^ CarpStaticVariable new
]

{ #category : #'instance creation' }
CarpBinding class >> defdynamic [
	^ CarpDynamicVariable new
]

{ #category : #'instance creation' }
CarpBinding class >> defmacro [
	^ CarpMacro new
]

{ #category : #'instance creation' }
CarpBinding class >> defn [
	^ CarpStaticFunction new
]

{ #category : #'instance creation' }
CarpBinding class >> defndynamic [
	^ CarpDynamicFunction new
]

{ #category : #accessing }
CarpBinding >> bindingName [
	^ self subclassResponsibility
]

{ #category : #accessing }
CarpBinding >> name [
	^ name
]

{ #category : #accessing }
CarpBinding >> name: aString [
	name := aString
]
