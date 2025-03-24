Class {
	#name : 'CTBTree',
	#superclass : 'Collection',
	#instVars : [
		'root'
	],
	#category : 'Collections-BTree',
	#package : 'Collections-BTree'
}

{ #category : 'as yet unclassified' }
CTBTree class >> keys: aBTreeKeys [
	^ self basicNew initializeWithKeys: aBTreeKeys
]

{ #category : 'as yet unclassified' }
CTBTree class >> new [
	^ self order: 5
]

{ #category : 'as yet unclassified' }
CTBTree class >> order: aNumber [
	^ self keys: (CTBTreeKeysArray new: aNumber)
]

{ #category : 'accessing' }
CTBTree >> at: aMagnitude [
	^ self at: aMagnitude ifAbsent: [self error: aMagnitude printString, ' not found']
]

{ #category : 'accessing' }
CTBTree >> at: aMagnitude ifAbsent: errorBlock [
       | leaf |
       leaf := root existingLeafForKey: aMagnitude.
       leaf ifNil: [^ errorBlock value].
       ^ leaf valueForKey: aMagnitude ifAbsent: errorBlock
]

{ #category : 'adding' }
CTBTree >> at: aMagnitude ifAbsentPut: aBlock [
	^ self at: aMagnitude ifAbsent: [self at: aMagnitude put: aBlock value]
]

{ #category : 'accessing' }
CTBTree >> at: aMagnitude ifPresent: aBlock [
	| leaf |
	leaf := root existingLeafForKey: aMagnitude.
	leaf ifNil: [ ^ nil ].
	^ leaf valueForKey: aMagnitude ifPresent: aBlock
]

{ #category : 'adding' }
CTBTree >> at: aMagnitude put: anObject [
	| leaf |
	leaf := root leafForKey: aMagnitude.
	leaf insertKey: aMagnitude value: anObject.
	root := leaf root.
	^ anObject
]

{ #category : 'enumerating' }
CTBTree >> commonKeysWith: aTree keysAndValuesDo: aBlock [
	^ aTree depth < self depth
		ifTrue: [aTree root commonKeysWith: root keysAndValuesDo: aBlock flip: true]
		ifFalse: [root commonKeysWith: aTree root keysAndValuesDo: aBlock flip: false]
]

{ #category : 'accessing' }
CTBTree >> depth [
	^ root depth
]

{ #category : 'enumerating' }
CTBTree >> do: aBlock [
	root allLeavesDo: [:ea | ea valuesDo: aBlock]
]

{ #category : 'copying' }
CTBTree >> emptyCopy [
	^ CTBTree keys: root keyArray emptyCopy
]

{ #category : 'accessing' }
CTBTree >> first [
	^ root first
]

{ #category : 'enumerating' }
CTBTree >> from: start do: aBlock [
	self from: start to: nil keysAndValuesDo: [:k :v | aBlock value: v]
]

{ #category : 'enumerating' }
CTBTree >> from: start keysAndValuesDo: aBlock [
	self from: start to: nil keysAndValuesDo: aBlock
]

{ #category : 'enumerating' }
CTBTree >> from: start to: end do: aBlock [
	self from: start to: end keysAndValuesDo: [:k :v | aBlock value: v]
]

{ #category : 'enumerating' }
CTBTree >> from: start to: end keysAndValuesDo: aBlock [
	root leavesFrom: start to: end do:
		[:ea |
		ea keysAndValuesDo:
			[:k :v |
			((start isNil or: [k >= start]) and:
				[end isNil or: [k <= end]]) ifTrue:
					[aBlock value: k value: v]]]
]

{ #category : 'initialize-release' }
CTBTree >> initializeWithKeys: aBTreeKeys [
	aBTreeKeys size > 3 ifFalse: [self error: 'The BTree order must be at least 4'].
	root := CTBTreeLeafNode keys: aBTreeKeys
]

{ #category : 'accessing' }
CTBTree >> keys [
	^ Array streamContents:
		[:s |
		self keysDo: [:k | s nextPut: k]]
]

{ #category : 'enumerating' }
CTBTree >> keysAndValuesDo: aBlock [
	root allLeavesDo: [:ea | ea keysAndValuesDo: aBlock]
]

{ #category : 'enumerating' }
CTBTree >> keysDo: aBlock [
	root allLeavesDo: [:ea | ea keysDo: aBlock]
]

{ #category : 'accessing' }
CTBTree >> last [
	^ root last
]

{ #category : 'accessing' }
CTBTree >> order [
	^ root size
]

{ #category : 'adding' }
CTBTree >> removeKey: aMagnitude [
	^ self removeKey: aMagnitude ifAbsent: [self error: aMagnitude printString, ' not found.']
]

{ #category : 'adding' }
CTBTree >> removeKey: aMagnitude ifAbsent: aBlock [
	| leaf |
	leaf := root existingLeafForKey: aMagnitude.
	leaf ifNil: [^ aBlock value].
	leaf removeKey: aMagnitude ifAbsent: [^ aBlock value].
	root := leaf root
]

{ #category : 'private' }
CTBTree >> root [
	^ root
]

{ #category : 'enumerating' }
CTBTree >> upTo: end do: aBlock [
	self from: nil to: end keysAndValuesDo: [:k :v | aBlock value: v]
]

{ #category : 'enumerating' }
CTBTree >> upTo: end keysAndValuesDo: aBlock [
	self from: nil to: end keysAndValuesDo: aBlock
]

{ #category : 'accessing' }
CTBTree >> values [
	^ Array streamContents:
		[:s |
		self valuesDo: [:k | s nextPut: k]]
]

{ #category : 'enumerating' }
CTBTree >> valuesDo: aBlock [
	root allLeavesDo: [:ea | ea valuesDo: aBlock]
]