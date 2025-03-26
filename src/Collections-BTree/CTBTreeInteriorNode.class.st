Class {
	#name : 'CTBTreeInteriorNode',
	#superclass : 'CTBTreeNode',
	#type : 'variable',
	#category : 'Collections-BTree',
	#package : 'Collections-BTree'
}

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> childForKey: aMagnitude [
	| index |
	index := keys findIndexForKey: aMagnitude.
	index = 0 ifTrue:
		[keys at: 1 put: aMagnitude.
		^ self at: 1].
	^ self at: index
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> childrenDo: aBlock [
	self valuesDo: aBlock
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> commonKeysWith: aNode keysAndValuesDo: aBlock flip: aBoolean [
	| index |
	aNode firstKey < self firstKey
		ifTrue: [ ^ aNode
				commonKeysWith: self
				keysAndValuesDo: aBlock
				flip: aBoolean not ].
	index := (keys findIndexForKey: aNode firstKey) max: 1.
	index to: self size do: [ :i | 
		(self at: i)
			ifNotNil: [ :c | c commonKeysWith: aNode keysAndValuesDo: aBlock flip: aBoolean ] ]
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> depth [
	^ 1 + self firstChild depth
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> existingChildForKey: aMagnitude [
       | index |
       index := keys findIndexForKey: aMagnitude.
       index = 0
               ifTrue: [^ nil]
               ifFalse: [^ self at: index].
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> existingLeafForKey: aMagnitude [
       | child |
       child := self existingChildForKey: aMagnitude.
       ^ child ifNotNil: [child existingLeafForKey: aMagnitude]
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> first [
	self childrenDo: [ :node | ^ node first ].
	self error: 'this tree is empty'
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> firstChild [
	self childrenDo: [:ea | ^ ea].
	self error: 'No children'.
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> insertKey: aMagnitude value: anObject at: index [
	super insertKey: aMagnitude value: anObject at: index.
	anObject parent: self
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> isLeaf [
	^ false
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> last [
	| child |
	child := nil.
	self childrenDo: [ :node | child := node ].
	child isNil ifTrue: [ self error: 'this tree is empty' ].
	^ child last
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> leafForKey: aMagnitude [
	^ (self childForKey: aMagnitude) leafForKey: aMagnitude
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> leavesFrom: start to: end do: aBlock [
	| startIndex endIndex |
	startIndex := start ifNil: [1] ifNotNil: [(keys findIndexForKey: start) max: 1].
	endIndex := end ifNil: [keys lastIndex] ifNotNil: [keys findIndexForKey: end].
	startIndex to: endIndex do: [:i | (self at: i) leavesFrom: start to: end do: aBlock]
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> nextSiblingForChild: aNode [
	| index |
	index := keys findIndexForKey: aNode firstKey.
	^ (index = self size or: [(keys at: index+1) isNil]) 
		ifTrue: [index = 1 ifFalse: [self at: index - 1] ifTrue: [nil]]
		ifFalse: [self at: index + 1]
]

{ #category : 'as yet unclassified' }
CTBTreeInteriorNode >> updateKey: oldMagnitude to: newMagnitude [
       keys withIndexDo:
               [:key :i |
               key = oldMagnitude ifTrue:
                       [(i = 1 and: [parent notNil]) ifTrue:
                               [parent updateKey: oldMagnitude to: newMagnitude].
                       ^ keys at: i put: newMagnitude]].
       self error: 'No such key'
]