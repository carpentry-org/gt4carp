Extension { #name : #LeRoamJSONExportVisitor }

{ #category : #'*Carp' }
LeRoamJSONExportVisitor >> visitCarpSnippet: aSnippet [

	^ String streamContents: [ :aStream | 
		  aStream
			  << '```javascript';
			  cr;
			  << aSnippet code;
			  cr;
			  << '```' ]
]
