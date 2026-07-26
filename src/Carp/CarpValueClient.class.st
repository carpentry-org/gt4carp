"
I speak the remote phlow protocol to a Carp value host, exactly like my
superclass speaks it to a Rust phlow server — but the objects and data
sources I produce are {{gtClass:name=CarpRemoteValue}}s, which carry the
Carp/Proxy inspector switch.
"
Class {
	#name : #CarpValueClient,
	#superclass : #GtPhlowRemoteRustClient,
	#instVars : [
		'carpSession'
	],
	#category : #'Carp-Execution'
}

{ #category : #accessing }
CarpValueClient >> carpSession [
	^ carpSession
]

{ #category : #accessing }
CarpValueClient >> carpSession: aString [
	carpSession := aString
]

{ #category : #accessing }
CarpValueClient >> remoteObjectById: anObjectId [
	^ CarpRemoteValue
		fromDictionary: (self retrieveObject: anObjectId)
		client: self
]

{ #category : #accessing }
CarpValueClient >> remoteViewsSpecificationsOf: anObjectId [
	^ (self retrievePhlowObjectViews: anObjectId)
		collect: [ :eachDictionary |
			| eachView |
			eachView := GtPhlowViewSpecification fromDictionary: eachDictionary.
			eachView
				phlowDataSource: (CarpValueDataSource new
						objectId: anObjectId;
						methodSelector: eachView methodSelector;
						client: self).
			eachView ]
]
