Extension { #name : #LeLocalStore }

{ #category : #'*Carp' }
LeLocalStore >> carpLinkSettings [
	"Answer the initialised LeCarpLinkSettings for this database"
	<return: #LeJSLinkSettings>

	^ LeJSLinkSettings new dbProperties: self
]
