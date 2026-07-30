"
I type the inspector playground page of a Carp notebook session, the way
{{gtClass:name=LePharoClassPageType}} types the playground page of a Pharo
class: one page per session, indexed by the session id.

Like every non-named page type I answer false to saveEmptyPages and
shouldAppearInIndexOrDailyNotes, so an untouched playground page is neither
persisted nor listed in the knowledge base.
"
Class {
	#name : #LeCarpSessionPageType,
	#superclass : #LePageType,
	#instVars : [
		'sessionId'
	],
	#category : #'Carp-Lepiter'
}

{ #category : #'class initialization' }
LeCarpSessionPageType class >> initialize [
	"Databases populate their by-type page storage from LePageType's
	subclasses when they are created; give already-loaded databases a
	storage bucket for the receiver."

	LeDatabase allInstances
		do: [ :each | [ each populatePageTypes ] on: Error do: [ :e |  ] ]
]

{ #category : #'lepiter store' }
LeCarpSessionPageType class >> leJsonV4AttributeMapping [
	^ super leJsonV4AttributeMapping
		add: #sessionId -> #sessionId;
		yourself
]

{ #category : #'lepiter store' }
LeCarpSessionPageType class >> leJsonV4Name [
	^ 'carpSessionPage'
]

{ #category : #'instance creation' }
LeCarpSessionPageType class >> sessionId: aString page: aLePage [
	^ self new
		sessionId: aString;
		page: aLePage
]

{ #category : #comparing }
LeCarpSessionPageType >> = anObject [
	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ sessionId sameContentAs: anObject sessionId
]

{ #category : #accessing }
LeCarpSessionPageType >> databaseKey [
	^ self sessionId
]

{ #category : #comparing }
LeCarpSessionPageType >> hash [
	^ sessionId hash
]

{ #category : #printing }
LeCarpSessionPageType >> printOn: aStream [
	aStream
		<< 'Carp Session Page: ';
		<< (sessionId ifNil: [ '<none>' ])
]

{ #category : #accessing }
LeCarpSessionPageType >> sessionId [
	^ sessionId
]

{ #category : #accessing }
LeCarpSessionPageType >> sessionId: aString [
	sessionId := aString
]

{ #category : #accessing }
LeCarpSessionPageType >> title [
	^ 'Carp session ' , (sessionId ifNil: [ '<none>' ])
]
