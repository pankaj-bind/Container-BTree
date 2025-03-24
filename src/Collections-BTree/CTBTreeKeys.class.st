Class {
	#name : 'CTBTreeKeys',
	#superclass : 'Object',
	#category : 'Collections-BTree',
	#package : 'Collections-BTree'
}

{ #category : 'as yet unclassified' }
CTBTreeKeys >> canGrow [
	^ (self at: self size) isNil
]

{ #category : 'as yet unclassified' }
CTBTreeKeys >> canShrink [
	^  (self at: self size // 2 + 1) notNil
]

{ #category : 'as yet unclassified' }
CTBTreeKeys >> emptyCopy [
	^ self class new: self size
]

{ #category : 'as yet unclassified' }
CTBTreeKeys >> findIndexForKey: aMagnitude [
	self withIndexDo:
		[:key :i |
		(key isNil or: [key > aMagnitude]) ifTrue:
			[^ i - 1]].
	^ self size
]

{ #category : 'as yet unclassified' }
CTBTreeKeys >> first [
	^ self at: 1
]

{ #category : 'as yet unclassified' }
CTBTreeKeys >> lastIndex [
	self withIndexDo:
		[:key :i |
		key isNil ifTrue:
			[^ i - 1]].
	^ self size
]

{ #category : 'as yet unclassified' }
CTBTreeKeys >> shiftLeftTo: index [
	index to: self size - 1 by: 1 do:
		[:i |
		self at: i put: (self at: i+1)].
	self at: self size put: nil.
]

{ #category : 'as yet unclassified' }
CTBTreeKeys >> shiftRightFrom: index [
	self size to: index+1 by: -1 do:
		[:i |
		self at: i put: (self at: i - 1)]
]

{ #category : 'as yet unclassified' }
CTBTreeKeys >> withIndexDo: aBlock [
	1 to: self size do: [:i | aBlock value: (self at: i) value: i]
]