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
			  BrHorizontalPane new
				  fitContent;
				  alignCenterRight;
				  cellSpacing: 4;
				  addChild: self gtCarpBrowseButton;
				  addChild: (BrButton new
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
								  writeStreamDo: [ :s | s nextPutAll: newContents ] ]);
				  yourself ]
]

{ #category : #'*Carp' }
AbstractFileReference >> gtCarpBrowseButton [
	"Open the project this file belongs to, at this file. A file is where you
	usually arrive — from a search, a diff, a directory — and a definition in
	it is what you actually came to read."

	^ BrButton new
		aptitude: BrGlamorousButtonWithIconAptitude;
		label: 'Browse project';
		icon: BrGlamorousVectorIcons hierarchy;
		action: [ :aButton |
			| project |
			project := [ CarpProject containing: self ]
					on: Error
					do: [ :e | nil ].
			project
				ifNil: [ aButton phlow
						spawnObject: 'no Carp project holds ' , self fullName ]
				ifNotNil: [ aButton phlow
						spawnTool: (project
								asBrowserToolAt: (project definitionInFile: self fullName)) ] ];
		yourself
]
