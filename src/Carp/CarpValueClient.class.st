"
I speak the remote phlow HTTP protocol to a Carp value host: object
dictionaries, declarative view specifications, lazy items, tree children
and reference release. The objects and data sources I produce are
{{gtClass:name=CarpRemoteValue}}s and {{gtClass:name=CarpValueDataSource}}s.
"
Class {
	#name : #CarpValueClient,
	#superclass : #Object,
	#instVars : [
		'port',
		'sessionId',
		'serverId',
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

{ #category : #private }
CarpValueClient >> connection [
	^ ZnClient new
		enforceHttpSuccess: false;
		beOneShot;
		accept: ZnMimeType applicationJson;
		host: 'localhost';
		port: port
]

{ #category : #'start-stop' }
CarpValueClient >> connectTo: aNumber [
	port := aNumber.
	sessionId := self retrieveSession.
	serverId := self retrieveServerId
]

{ #category : #accessing }
CarpValueClient >> port [
	^ port
]

{ #category : #'reference management' }
CarpValueClient >> releaseObject: anObjectId [
	^ self connection
		delete: ('session/{1}/objects/{2}' format: {sessionId. anObjectId});
		response
]

{ #category : #accessing }
CarpValueClient >> remoteObjectById: anObjectId [
	^ CarpRemoteValue
		fromDictionary: (self retrieveObject: anObjectId)
		client: self
]

{ #category : #accessing }
CarpValueClient >> remoteViewsOf: anObjectId for: aView inContext: aContext [
	^ (self remoteViewsSpecificationsOf: anObjectId)
		collect: [ :eachViewSpecification |
			| aPhlowView |
			aPhlowView := eachViewSpecification viewFor: aView.
			"only defview views carry source; built-ins must keep their
			default behaviour instead of answering a nil defining method"
			eachViewSpecification phlowDataSource definingMethod
				ifNotNil: [ aPhlowView definingMethodProvider: (GtRemotePhlowDefiningMethodProvider new
							declarativeView: eachViewSpecification).
					aPhlowView autoUpdates removeUpdateOnMethodChanged ].
			aPhlowView ]
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
						viewSource: (eachDictionary at: 'source' ifAbsent: [ '' ]);
						client: self).
			eachView ]
]

{ #category : #private }
CarpValueClient >> retrieveObject: anObjectId [
	^ STONJSON
		fromString: (self connection get: ('objects/{1}' format: {anObjectId})) contents
]

{ #category : #private }
CarpValueClient >> retrievePhlowObjectViews: anObjectId [
	^ STONJSON
		fromString: (self connection get: ('objects/{1}/views' format: {anObjectId})) contents
]

{ #category : #private }
CarpValueClient >> retrieveServerId [
	^ STONJSON fromString: (self connection get: 'id') contents
]

{ #category : #private }
CarpValueClient >> retrieveSession [
	^ STONJSON fromString: (self connection get: 'session') contents
]

{ #category : #private }
CarpValueClient >> retrieveViewChildren: anObjectId methodSelector: aMethodSelector path: aNodePath [
	^ STONJSON
		fromString: (self connection
				get: ('objects/{1}/views/{2}/children/{3}'
						format: {anObjectId.
								aMethodSelector.
								((aNodePath collect: [ :each | each printString ]) joinUsing: ',')})) contents
]

{ #category : #private }
CarpValueClient >> retrieveViewItems: anObjectId methodSelector: aMethodSelector [
	^ STONJSON
		fromString: (self connection
				get: ('objects/{1}/views/{2}/items'
						format: {anObjectId.
								aMethodSelector})) contents
]

{ #category : #private }
CarpValueClient >> retrieveViewSentItem: anInspectedObjectId methodSelector: aMethodSelector selectedObjectId: aSelectedObjectId [
	^ STONJSON
		fromString: (self connection
				get: ('objects/{1}/views/{2}/send/{3}'
						format: {anInspectedObjectId.
								aMethodSelector.
								aSelectedObjectId})) contents
]

{ #category : #accessing }
CarpValueClient >> sessionId [
	^ sessionId
]
