"
I am a live Carp value served by a session's value host over the remote
phlow protocol.

I keep the two worlds apart, the way LanguageLink proxies do: my inspector
has a switch between the **Carp** tool (the value's views, declared and
computed by the value host) and the **Proxy** tool (me, a regular Pharo
object with the standard Raw/Print/Meta views).

When the host marks me auto-releasable, garbage-collecting me releases my
remote reference through {{gtClass:name=CarpValueResourceManager}}.
"
Class {
	#name : #CarpRemoteValue,
	#superclass : #Object,
	#instVars : [
		'id',
		'printString',
		'valueType',
		'referenceCount',
		'shouldAutoRelease',
		'client'
	],
	#category : #'Carp-Execution'
}

{ #category : #'instance creation' }
CarpRemoteValue class >> fromDictionary: aDictionary client: aClient [
	"Hydrate through the proxy class specializing the value's Carp type, the
	way LanguageLink proxies dispatch on remoteClassName; the receiver
	itself is the fallback."

	| proxyClass |
	proxyClass := self allSubclasses
			detect: [ :each | each remoteTypeName = (aDictionary at: 'object_type') ]
			ifNone: [ self ].
	^ proxyClass new
		id: (aDictionary at: 'id');
		valueType: (aDictionary at: 'object_type');
		printString: (aDictionary at: 'print_string');
		referenceCount: (aDictionary at: 'reference_count');
		client: aClient;
		autoRelease: (aDictionary at: 'should_auto_release')
]

{ #category : #'instance creation' }
CarpRemoteValue class >> remoteTypeName [
	"Subclasses answer the Carp type name they specialize (a deftype name
	such as 'Grid'); the base proxies every type."

	^ nil
]

{ #category : #finalization }
CarpRemoteValue class >> finalizeResourceData: aResourceData [
	| anId aClient |
	anId := aResourceData first.
	aClient := aResourceData second.
	[ aClient releaseObject: anId ]
		on: Error
		do: [ :anError | "host already gone" ]
]

{ #category : #finalization }
CarpRemoteValue >> autoRelease: aBoolean [
	shouldAutoRelease := aBoolean.
	shouldAutoRelease ifFalse: [ ^ self ].
	CarpValueResourceManager addResource: self
]

{ #category : #accessing }
CarpRemoteValue >> carpSession [
	^ client carpSession
]

{ #category : #accessing }
CarpRemoteValue >> client [
	^ client
]

{ #category : #accessing }
CarpRemoteValue >> client: aClient [
	client := aClient
]

{ #category : #inspecting }
CarpRemoteValue >> gtDefaultInspectorTool [
	^ GtPhlowCompositeTool new
		addTool: ((GtInspectorTool
				forObject: self
				viewSelector: #gtRemoteInspectorContentFor:)
				name: 'Carp';
				playgroundPageStrategy: CarpInspectorPlaygroundPageStrategy new;
				withLabelAndIconAptitude);
		addTool: ((GtInspectorTool
				forObject: self
				viewSelector: #gtViewsFor:inContext:)
				name: 'Proxy';
				withLabelAndIconAptitude)
]

{ #category : #inspecting }
CarpRemoteValue >> gtActionsForRemoteSideInContext: aContext [
	^ #()
]

{ #category : #printing }
CarpRemoteValue >> gtInspectorTitleString [
	| limitedString limit |
	limit := 1000.
	limitedString := String
			streamContents: [ :s | self gtInspectorTitleStringOn: s ]
			limitedTo: limit.
	limitedString size < limit ifTrue: [ ^ limitedString ].
	^ limitedString , ' ...'
]

{ #category : #printing }
CarpRemoteValue >> gtInspectorTitleStringOn: aStream [
	aStream
		nextPutAll: self valueType;
		nextPutAll: ' (';
		nextPutAll: self printString;
		nextPutAll: ')'
]

{ #category : #inspecting }
CarpRemoteValue >> gtRemoteInspectorContentFor: aView [
	"The wrapper view containing the value's own views, served by the host."

	<return: #GtPhlowLabelledView>
	^ GtPhlowLabelledViewBuilder new
		object: self;
		view: aView;
		context: GtPhlowContext new;
		viewsSelector: #gtViewsForRemoteSideInContext:;
		actionsSelector: #gtActionsForRemoteSideInContext:;
		titleComputation: [ String
				streamContents: [ :stream |
					stream << (self valueType ifEmpty: [ 'a Carp value' ]) ] ];
		build
]

{ #category : #inspecting }
CarpRemoteValue >> gtViewsForRemoteSideInContext: aContext [
	| views |
	views := (self remoteViewsFor: GtPhlowEmptyView new inContext: aContext)
			asOrderedCollection.
	GtPhlowUtility sortByPriority: views.
	^ views
]

{ #category : #accessing }
CarpRemoteValue >> id [
	^ id
]

{ #category : #accessing }
CarpRemoteValue >> id: anInteger [
	id := anInteger
]

{ #category : #printing }
CarpRemoteValue >> printOn: aStream [
	aStream nextPutAll: (printString ifNil: [ 'an unhydrated Carp value' ])
]

{ #category : #accessing }
CarpRemoteValue >> printString: aString [
	printString := aString
]

{ #category : #accessing }
CarpRemoteValue >> referenceCount [
	^ referenceCount
]

{ #category : #accessing }
CarpRemoteValue >> referenceCount: anInteger [
	referenceCount := anInteger
]

{ #category : #inspecting }
CarpRemoteValue >> remoteViewsFor: aView inContext: aContext [
	^ client remoteViewsOf: id for: aView inContext: aContext
]

{ #category : #finalization }
CarpRemoteValue >> resourceData [
	^ {id. client}
]

{ #category : #accessing }
CarpRemoteValue >> valueType [
	^ valueType ifNil: [ '' ]
]

{ #category : #accessing }
CarpRemoteValue >> valueType: aString [
	valueType := aString
]
