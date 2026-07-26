"
I am a live Carp value served by a session's value host over the remote
phlow protocol.

Unlike my superclass I keep the two worlds apart, the way LanguageLink
proxies do: my inspector has a switch between the **Carp** tool (the value's
views, declared and computed by the value host) and the **Proxy** tool (the
local Pharo object).
"
Class {
	#name : #CarpRemoteValue,
	#superclass : #GtPhlowRustRemoteObject,
	#category : #'Carp-Execution'
}

{ #category : #accessing }
CarpRemoteValue >> carpSession [
	^ client carpSession
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
					stream << (self rustValueType ifEmpty: [ 'a Carp value' ]) ] ];
		build
]

{ #category : #inspecting }
CarpRemoteValue >> gtViewsFor: aView inContext: aContext [
	"Plain local views only; the value's remote views live in the Carp
	inspector tool (see gtDefaultInspectorTool). This deliberately skips the
	superclass' merge of remote views into the local ones."

	<return: #GtPhlowLabelledView>
	^ GtPhlowLabelledViewBuilder new
		object: self;
		view: aView;
		context: aContext;
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
