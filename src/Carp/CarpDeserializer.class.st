Class {
	#name : #CarpDeserializer,
	#superclass : #LanguageLinkDeserializer,
	#category : #'Carp-Serialization'
}

{ #category : #accessing }
CarpDeserializer >> buildProxyFor: rawObject [
	| proxy |
	proxy :=  CarpProxyObject 
					carpType: (rawObject at: #carptype)
					var: (rawObject at: #carpvar) asJSGI
					application: self application.
	self executionHandler registerObject: proxy.
	^ proxy
]

{ #category : #accessing }
CarpDeserializer >> deserialize: anObject [
	^ self new
		deserialize: anObject
]
