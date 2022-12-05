Class {
	#name : #CarpPlatform,
	#superclass : #LanguageLinkPlatform,
	#classVars : [
		'RuntimeSourceDirectory'
	],
	#category : #'Carp-Processes'
}

{ #category : #accessing }
CarpPlatform class >> uiManagerClass [
	^ LanguageLinkPharoUiManager
]

{ #category : #hooks }
CarpPlatform class >> weakRegistryClass [
	^ LanguageLinkPharoWeakRegistry
]

{ #category : #accessing }
CarpPlatform >> copyApplicationTo: appFolder application: application [
	"Copy the Carp runtime environment to the specified folder"
	| srcDir cpCommand proc error |

	srcDir := self runtimeSourceDirectoryFor: application.
	srcDir resolve = appFolder resolve ifTrue: [ ^ self ].

	"Copy the runtime directory"
	cpCommand := String streamContents: [ :stream |
		stream
			<< 'cp -a "';
			<< srcDir fullName;
			<< '" "';
			<< appFolder fullName;
			<< '"' ].
	proc := GtSubprocessWithInMemoryOutput new 
		shellCommand: cpCommand;
		runAndWait.
	proc isSuccess ifFalse:
		[ error := LanguageLinkProcessError new
			messageText: 'Unable to install Carp runtime';
			application: application;
			process: proc.
		error signal ].

]

{ #category : #accessing }
CarpPlatform >> ensureApplicationDirectory: application [
	"If the runtimeFolder doesn't exist, attempt to symlink to the respository directory"
	| appFolder |

	application settings workingDirectory exists ifFalse:
		[ appFolder := application settings workingDirectory.
		appFolder exists ifTrue: [ ^ self ].
		self copyApplicationTo: appFolder application: application ].
	self setExecutableFor: application.

]

{ #category : #accessing }
CarpPlatform >> ensureEnvironmentForApp: anApplication [

	self ensureApplicationDirectory: anApplication.
]

{ #category : #accessing }
CarpPlatform >> folderForApplication [
	"Answer the directory where JSLink runs from"

	^ FileLocator imageDirectory / 'carp'
]

{ #category : #accessing }
CarpPlatform >> newRandomName [
	^ 'carp' , UUID new asString36
]

{ #category : #accessing }
CarpPlatform >> runtimeSourceDirectoryFor: aCarpApplication [
	"Answer the source directory containing the runtime files.
	This is the first of:
	1. RuntimeSourceDirectory (if specified)
	2. The git repository copy.
	3. An existing copy in the image directory"
	| fileReference |

	(RuntimeSourceDirectory isNotNil and: [ RuntimeSourceDirectory exists ]) ifTrue: 
		[ ^ RuntimeSourceDirectory ].
	IceRepository registry 
			detect: [ :each | each includesPackageNamed: aCarpApplication class package name ] 
			ifFound: [ :repository | 
					fileReference := repository location / 'carp'.
					fileReference exists ifTrue: [ ^ fileReference ] ]
			ifNone: [ ].
	fileReference := self folderForApplication.
	fileReference exists ifTrue: [ ^ fileReference ].
	self error: 'Unable to locate Carp runtime source'.
]

{ #category : #accessing }
CarpPlatform >> setExecutableFor: application [
	"Copy the Carp runtime environment to the specified folder"
	| chmodCommand proc error appFolderString |

	appFolderString := application settings workingDirectory resolve fullName copyReplaceAll: '"' with: '\"'.
	chmodCommand := String streamContents: [ :stream |
		stream
			<< 'chmod +x "';
			<< appFolderString;
			<< '"/*.sh' ].
	proc := GtSubprocessWithInMemoryOutput new 
		shellCommand: chmodCommand;
		runAndWait.
	proc isSuccess ifFalse:
		[ error := LanguageLinkProcessError new
			messageText: 'Unable to set Carp runtime executable bits';
			application: application;
			process: proc.
		error signal ].

]
