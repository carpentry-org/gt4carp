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
					var: (rawObject at: #carpvar)
					application: self application.
	self executionHandler registerObject: proxy.
	^ proxy
]
