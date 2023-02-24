Class {
	#name : #GtCarpRewrite,
	#superclass : #Object,
	#instVars : [
		'comment',
		'from',
		'to'
	],
	#category : #'Carp-Formatting'
}

{ #category : #accessing }
GtCarpRewrite class >> comment: aString from: aString1 to: aString2 [
	^ self new
		comment: aString;
		from: aString1;
		to: aString2
]

{ #category : #accessing }
GtCarpRewrite >> asSmaCCRewrite [
	^ SmaCCRewrite
		comment: self comment
		match: (SmaCCRewriteTreeMatch new source: self from)
		transformation: (SmaCCRewriteStringTransformation new string: self to)
]

{ #category : #accessing }
GtCarpRewrite >> comment [
	^ comment
]

{ #category : #accessing }
GtCarpRewrite >> comment: anObject [
	comment := anObject
]

{ #category : #accessing }
GtCarpRewrite >> from [
	^ from
]

{ #category : #accessing }
GtCarpRewrite >> from: anObject [
	from := anObject
]

{ #category : #accessing }
GtCarpRewrite >> to [
	^ to
]

{ #category : #accessing }
GtCarpRewrite >> to: anObject [
	to := anObject
]