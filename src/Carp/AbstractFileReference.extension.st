Extension { #name : #AbstractFileReference }

{ #category : #'*Carp' }
AbstractFileReference >> gtCarpFor: aView [

	<gtView>
	self isFile ifFalse: [ ^ aView empty ].
	self path extension = 'carp' ifFalse: [ ^ aView empty ].
	[ self readStreamDo: [ :s | s next: 1000 ] ]
		on: ZnInvalidUTF8
		do: [ ^ aView empty ].
	^ aView explicit
		  title: 'Carp' translated;
		  priority: 50;
		  stencil: [ 
		  	(GtCarpCoderModel code: self contents) asElement matchParent ];
		  actionStencil: [ :tab | 
			  BrButton new
				  aptitude: BrGlamorousButtonWithIconAptitude;
				  label: 'Save';
				  icon: BrGlamorousVectorIcons accept;
				  action: [ 
					  | newContents |
					  newContents := tab viewContentElement children first children
						                 second children first children first editor text asString.
					  (self fullName , '.backup') asFileReference ensureDelete.
					  self copyTo: (self fullName , '.backup') asFileReference.
					  self
						  ensureDelete;
						  writeStreamDo: [ :s | s nextPutAll: newContents ] ] ]
]
