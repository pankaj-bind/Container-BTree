Class {
	#name : 'CTBTreeNode',
	#superclass : 'Object',
	#type : 'variable',
	#instVars : [
		'parent',
		'keys'
	],
	#category : 'Collections-BTree',
	#package : 'Collections-BTree'
}

{ #category : 'as yet unclassified' }
CTBTreeNode class >> keys: anArray [
	^ (self new: (anArray size)) keys: anArray
]

{ #category : 'enumerating' }
CTBTreeNode >> allChildrenDo: aBlock [
	self childrenDo:
		[:ea |
		aBlock value: ea.
		ea allChildrenDo: aBlock]
]

{ #category : 'enumerating' }
CTBTreeNode >> allLeavesDo: aBlock [
	self withAllChildrenDo: [:ea | ea isLeaf ifTrue: [aBlock value: ea]]
]

{ #category : 'testing' }
CTBTreeNode >> canGrow [
	^ keys canGrow
]

{ #category : 'testing' }
CTBTreeNode >> canShrink [
	^ keys canShrink
]

{ #category : 'accessing' }
CTBTreeNode >> children [
	^ Array streamContents: [:s | self childrenDo: [:ea | s nextPut: ea]]
]

{ #category : 'enumerating' }
CTBTreeNode >> childrenDo: aBlock [
	self subclassResponsibility
]

{ #category : 'accessing' }
CTBTreeNode >> depth [
	^ parent ifNil: [1] ifNotNil: [1 + parent depth]
]

{ #category : 'private' }
CTBTreeNode >> ensureParent [
	parent ifNil:
		 [self parent: (self interiorNodeClass keys: keys emptyCopy).
		parent insertKey: self firstKey value: self].
	^ parent
]

{ #category : 'accessing' }
CTBTreeNode >> first [
	self subclassResponsibility
]

{ #category : 'accessing' }
CTBTreeNode >> firstKey [
	^ keys first
]

{ #category : 'private' }
CTBTreeNode >> grow [
	| sibling |
	parent ifNotNil:
		[sibling := parent nextSiblingForChild: self.
		sibling ifNil: [self parent: nil. ^ self].
		sibling canShrink
			ifTrue: [self stealFrom: sibling]
			ifFalse: [self mergeWith: sibling]]
]

{ #category : 'inserting' }
CTBTreeNode >> insertKey: aMagnitude value: anObject [
	| index key |
	index := keys findIndexForKey: aMagnitude.
	index = 0 ifTrue:
		[self canGrow
			ifTrue:
				[self shiftRightFrom: 1.
				^ self insertKey: aMagnitude value: anObject at: 1]
			ifFalse:
				[self split.
				^ (parent childForKey: aMagnitude) insertKey: aMagnitude value: anObject]].
	
	key := keys at: index.
	key = aMagnitude ifTrue:
		[^ self insertKey: aMagnitude value: anObject at: index].
	index < self size ifTrue:
		[key := keys at: index + 1.
		key
			ifNil: [^ self insertKey: aMagnitude value: anObject at: index+1]
			ifNotNil:
				[self canGrow ifTrue:
					[self shiftRightFrom: index+1.
					^ self insertKey: aMagnitude value: anObject at: index+1]]].

	"otherwise"
	self split.
	^ (parent childForKey: aMagnitude) insertKey: aMagnitude value: anObject
]

{ #category : 'private' }
CTBTreeNode >> insertKey: aMagnitude value: anObject at: index [
	keys at: index put: aMagnitude.
	self at: index put: anObject
]

{ #category : 'private' }
CTBTreeNode >> interiorNodeClass [
	^ CTBTreeInteriorNode
]

{ #category : 'testing' }
CTBTreeNode >> isLeaf [
	self subclassResponsibility
]

{ #category : 'private' }
CTBTreeNode >> keyArray [
	^ keys
]

{ #category : 'private' }
CTBTreeNode >> keys: anArray [
	keys := anArray
]

{ #category : 'enumerating' }
CTBTreeNode >> keysAndValuesDo: aBlock [
	keys withIndexDo:
		[:key :i |
		key ifNotNil: [aBlock value: key value: (self at: i)]]
]

{ #category : 'enumerating' }
CTBTreeNode >> keysDo: aBlock [
	keys withIndexDo:
		[:key :i |
		key ifNotNil: [aBlock value: key] ifNil: [^ self]]
]

{ #category : 'accessing' }
CTBTreeNode >> last [
	self subclassResponsibility
]

{ #category : 'enumerating' }
CTBTreeNode >> leavesFrom: start to: end do: aBlock [
	self subclassResponsibility
]

{ #category : 'private' }
CTBTreeNode >> mergeWith: aNode [		
	| oldKey |
	oldKey := self firstKey.
	aNode keysAndValuesDo:
		[:k :v |
		self insertKey: k value: v].
	parent removeKey: aNode firstKey.
	parent updateKey: oldKey to: self firstKey.
]

{ #category : 'accessing' }
CTBTreeNode >> parent [
	^ parent
]

{ #category : 'accessing' }
CTBTreeNode >> parent: aBTreeNode [
	parent := aBTreeNode
]

{ #category : 'removing' }
CTBTreeNode >> removeKey: aMagnitude [
	self removeKey: aMagnitude ifAbsent: [self error: aMagnitude printString, ' not found.']
]

{ #category : 'removing' }
CTBTreeNode >> removeKey: aMagnitude ifAbsent: aBlock [
	| index key |
	self canShrink ifFalse: [self grow].
	
	index := keys findIndexForKey: aMagnitude.
	index = 0 ifTrue: [^ aBlock value].
	key := keys at: index.
	key = aMagnitude ifFalse: [^ aBlock value].
	
	self shiftLeftTo: index.
	
	index = 1 ifTrue: [parent ifNotNil: [parent updateKey: key to: self firstKey]]
]

{ #category : 'accessing' }
CTBTreeNode >> root [
	^ parent
		ifNil: [self]
		ifNotNil: [parent root]
]

{ #category : 'private' }
CTBTreeNode >> shiftLeftTo: index [
	keys shiftLeftTo: index.
	index to: self size - 1 by: 1 do:
		[:i |
		self at: i put: (self at: i+1)].
	self at: self size put: nil.
]

{ #category : 'private' }
CTBTreeNode >> shiftRightFrom: index [
	keys shiftRightFrom: index.
	self size to: index+1 by: -1 do:
		[:i |
		self at: i put: (self at: i-1)]
]

{ #category : 'private' }
CTBTreeNode >> split [
	| other midpoint |
	other := self class keys: keys emptyCopy.
	midpoint := self size // 2 + 1.
	midpoint to: self size do:
		[:i |
		other insertKey: (keys at: i) value: (self at: i) at: (i - midpoint + 1).
		keys at: i put: nil.
		self at: i put: nil].
	
	self ensureParent insertKey: other firstKey value: other
]

{ #category : 'private' }
CTBTreeNode >> stealFrom: aNode [
	| key value |
	aNode firstKey > self firstKey
		ifTrue: [value := aNode at: 1. key := aNode firstKey]
		ifFalse:
			[aNode keysAndValuesDo: [:k :v | key := k. value := v].
			parent ifNotNil: [parent updateKey: self firstKey to: key]].
	self insertKey: key value: value.
	aNode removeKey: key
]

{ #category : 'accessing' }
CTBTreeNode >> values [
	^ Array streamContents: [:s | self valuesDo: [:ea | s nextPut: ea]]
]

{ #category : 'enumerating' }
CTBTreeNode >> valuesDo: aBlock [
	self keysAndValuesDo: [:k :v | aBlock value: v]
]

{ #category : 'enumerating' }
CTBTreeNode >> withAllChildrenDo: aBlock [
	aBlock value: self.
	self allChildrenDo: aBlock.
]