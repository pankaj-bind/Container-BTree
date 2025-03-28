Class {
	#name : 'CTBTreeLeafNode',
	#superclass : 'CTBTreeNode',
	#type : 'variable',
	#category : 'Collections-BTree',
	#package : 'Collections-BTree'
}

{ #category : 'as yet unclassified' }
CTBTreeLeafNode >> childrenDo: aBlock [
	"no children"
]

{ #category : 'as yet unclassified' }
CTBTreeLeafNode >> commonKeysWith: aNode keysAndValuesDo: aBlock flip: aBoolean [
	| index key block leaf advanceKey last |

	aNode firstKey ifNil: [^ self].

	block := aBoolean ifTrue: [[:k :v1 :v2 | aBlock value: k value: v2 value: v1]] ifFalse: [aBlock].

	index := 0.
	advanceKey :=
		[index := index + 1.
		index > self size ifTrue: [^ self].
		key := keys at: index.
		key ifNil: [^ self]].
	last := self lastKey.
	
	advanceKey value.
	[key < aNode firstKey] whileTrue: advanceKey.
		
	[leaf := aNode existingLeafForKey: key.
	leaf lastKey < key ifTrue: advanceKey ifFalse:
		[leaf keysAndValuesDo:
			[:otherKey :otherValue |
			otherKey > last ifTrue: [^ self].
			[key < otherKey] whileTrue: advanceKey.
			key = otherKey ifTrue: [block value: key value: (self at: index) value: otherValue]].
		key > leaf lastKey ifFalse: advanceKey]] repeat
]

{ #category : 'as yet unclassified' }
CTBTreeLeafNode >> depth [
	^ 1
]

{ #category : 'as yet unclassified' }
CTBTreeLeafNode >> existingLeafForKey: aMagnitude [
       ^ self
]

{ #category : 'as yet unclassified' }
CTBTreeLeafNode >> first [
	^ self values first
]

{ #category : 'as yet unclassified' }
CTBTreeLeafNode >> isLeaf [
	^ true
]

{ #category : 'as yet unclassified' }
CTBTreeLeafNode >> keys [
	^ Array streamContents: [:s | self keysDo: [:ea | s nextPut: ea]]
]

{ #category : 'as yet unclassified' }
CTBTreeLeafNode >> last [
	^ self values last
]

{ #category : 'as yet unclassified' }
CTBTreeLeafNode >> lastKey [
	| last |
	last := nil.
	self keysDo: [:k | last := k].
	^ last
]

{ #category : 'as yet unclassified' }
CTBTreeLeafNode >> leafForKey: aMagnitude [
	^ self
]

{ #category : 'as yet unclassified' }
CTBTreeLeafNode >> leavesFrom: start to: end do: aBlock [
	aBlock value: self
]

{ #category : 'as yet unclassified' }
CTBTreeLeafNode >> valueForKey: aMagnitude ifAbsent: errorBlock [
	| i |
	i := keys findIndexForKey: aMagnitude.
	^ (i > 0 and: [(keys at: i) = aMagnitude])
		ifTrue: [self at: i]
		ifFalse: [errorBlock value]
]

{ #category : 'as yet unclassified' }
CTBTreeLeafNode >> valueForKey: aMagnitude ifPresent: aBlock [
	^ aBlock value: (self valueForKey: aMagnitude ifAbsent: [^ nil])
]