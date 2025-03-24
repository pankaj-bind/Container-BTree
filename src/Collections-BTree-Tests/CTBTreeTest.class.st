Class {
	#name : 'CTBTreeTest',
	#superclass : 'TestCase',
	#category : 'Collections-BTree-Tests',
	#package : 'Collections-BTree-Tests'
}

{ #category : 'asserting' }
CTBTreeTest >> assertConsistent: aBTree [
	| depths root |
	root := aBTree root.
	
	self assert: (root isLeaf or: [root values size between: 2 and: aBTree order]).
	
	root allChildrenDo: [:ea | self assert: (ea values size between: (aBTree order // 2) and: aBTree order)]. 

	depths := Set new.
	root withAllChildrenDo: [:ea | ea isLeaf ifTrue: [depths add: ea depth]].
	self assert: depths size = 1.
]

{ #category : 'asserting' }
CTBTreeTest >> assertSorted: aTree [
	| last |
	last := nil.
	aTree keysAndValuesDo:
		[:k :v |
		last ifNotNil: [self assert: last < k].
		last := k]
]

{ #category : 'private' }
CTBTreeTest >> checkTree: tree array: pairArray [
	pairArray withIndexDo:
		[:pair :i |
		tree at: pair first put: pair second.
		self assert: tree size = i.
		self assertConsistent: tree.
		self assertSorted: tree].
	pairArray shuffled do:
		[:pair |
		self assert: (tree at: pair first) = pair second].
	self assert: tree size = pairArray size.
	self assertConsistent: tree.
	self assertSorted: tree.
	^ tree
]

{ #category : 'private' }
CTBTreeTest >> checkTree: tree items: count [
	| pairArray |
	pairArray := ((1 to: count) collect: [:i | Array with: i asString with: i]) shuffled.
	self checkTree: tree array: pairArray
]

{ #category : 'private' }
CTBTreeTest >> checkTreeWithOrder: order items: count [
	self checkTree: (CTBTree order: order) items: count
]

{ #category : 'tests' }
CTBTreeTest >> testAddAndRetrieveWithSplit [
	self checkTreeWithOrder: 4 items: 5
]

{ #category : 'tests' }
CTBTreeTest >> testAddAndRetrieveWithTwoSplits [
	self checkTreeWithOrder: 4 items: 17
]

{ #category : 'tests' }
CTBTreeTest >> testCommonKeysDifferentValues [
	| large small expectedResults results |
	large := CTBTree new.
	1 to: 1000 by: 2 do: [:i | large at: i put: i].
	small := CTBTree new.
	2 to: 2000 by: 11 do: [:i | small at: i put: i*2].
	
	expectedResults := ((-9 to: 1000 by: 22) allButFirst collect: [:i | Array with: i with: i with: i*2]) asOrderedCollection.
	
	results := OrderedCollection new.
	large commonKeysWith: small keysAndValuesDo:
		[:k :v1 :v2 |
		results add: (Array with: k with: v1 with: v2)].
	self assert: results = expectedResults.
	
	results := OrderedCollection new.
	small commonKeysWith: large keysAndValuesDo:
		[:k :v1 :v2 |
		results add: (Array with: k with: v2 with: v1)].
	self assert: results = expectedResults
]

{ #category : 'tests' }
CTBTreeTest >> testCommonKeysSameValues [
	| large small expectedResults results |
	large := CTBTree new.
	1 to: 1000 by: 2 do: [:i | large at: i put: i].
	small := CTBTree new.
	2 to: 2000 by: 11 do: [:i | small at: i put: i].
	
	expectedResults := ((-9 to: 1000 by: 22) allButFirst collect: [:i | Array with: i with: i with: i]) asOrderedCollection.
	
	results := OrderedCollection new.
	large commonKeysWith: small keysAndValuesDo:
		[:k :v1 :v2 |
		results add: (Array with: k with: v1 with: v2)].
	self assert: results = expectedResults.
	
	results := OrderedCollection new.
	small commonKeysWith: large keysAndValuesDo:
		[:k :v1 :v2 |
		results add: (Array with: k with: v2 with: v1)].
	self assert: results = expectedResults
]

{ #category : 'tests' }
CTBTreeTest >> testEmptyTree [
	self checkTreeWithOrder: 5 items: 0
]

{ #category : 'tests' }
CTBTreeTest >> testFirstLast [
	| tree |
	tree := CTBTree new.
	self should: [tree first] raise: Error.
	self should: [tree last] raise: Error.
	tree at: SmallInteger minVal put: SmallInteger minVal.
	tree at: SmallInteger maxVal put: SmallInteger maxVal.
	10000 timesRepeat: [ 
		tree at: 536870911 atRandom put: nil.
		self assert: tree first = SmallInteger minVal.
		self assert: tree last = SmallInteger maxVal ]
]

{ #category : 'tests' }
CTBTreeTest >> testFound [
	| tree found |
	found := false.
	tree := CTBTree new.
	tree at: 1 put: 'foo'.
	tree
		at: 1
		ifPresent: [:val | 
			self assert: 'foo' equals: val.
			found := true].
	self assert: found
]

{ #category : 'tests' }
CTBTreeTest >> testLargeTree [
	self checkTreeWithOrder: 8 items: 5000
]

{ #category : 'tests' }
CTBTreeTest >> testMissing [
	| tree |
	tree := CTBTree new.
	tree at: 1 put: 'foo'.
	tree at: 2 put: 'bar'.
	self assert: (tree at: 1 ifAbsent: [42]) = 'foo'.
	self assert: (tree at: 2 ifAbsent: [42]) = 'bar'.
	self assert: (tree at: 3 ifAbsent: [42]) = 42.
]

{ #category : 'tests' }
CTBTreeTest >> testMultipleAddAndRetrieve [
	self checkTreeWithOrder: 5 items: 3
]

{ #category : 'tests' }
CTBTreeTest >> testRange [
	| tree keys |
	tree := CTBTree new.
	1 to: 100 by: 2 do: [:ea | tree at: ea put: ea * 2].
	self assert: tree size = 50.
	keys := OrderedCollection new.
	tree from: 12 to: 19 keysAndValuesDo:
		[:k :v |
		self assert: k * 2 = v.
		keys add: k].
	self assert: keys asArray = #(13 15 17 19).
	self assertSorted: tree.
	self assertConsistent: tree.
]

{ #category : 'tests' }
CTBTreeTest >> testRemoval [
	| tree |
	tree := CTBTree new.
	#(a b c d e f g h i j k l) do: [:ea | tree at: ea put: ea, '!'].
	self assert: tree size = 12.
	tree removeKey: #d.
	self assert: tree size = 11.
	self assert: (tree at: #d ifAbsent: [32]) = 32.
	tree removeKey: #k.
	self assert: tree size = 10.
	self assert: (tree at: #k ifAbsent: [32]) = 32.
	self assertSorted: tree.
	self assertConsistent: tree.
]

{ #category : 'tests' }
CTBTreeTest >> testRemoval2 [
	| tree |
	tree := CTBTree new.
	1 to: 15 do: [:i | tree at: i put: i].
	1 to: 15 do: [:i | tree removeKey: i].
	self assert: tree isEmpty
]

{ #category : 'tests' }
CTBTreeTest >> testRemoveAll [
	| tree |
	tree := CTBTree new.
	#(a b c d e f g h i j k l) do: [:ea | tree at: ea put: ea, '!'].
	self assert: tree size = 12.
	#(a b c d e f g h i j k l) shuffled do: [:ea | tree removeKey: ea].
	self assert: tree size = 0.
	self assertSorted: tree.
	self assertConsistent: tree.
]

{ #category : 'tests' }
CTBTreeTest >> testRemoveAllFailing [
	| tree |
	tree := CTBTree new.
	#(a b c d e f g h i j k l) do: [:ea | tree at: ea put: ea, '!'].
	self assert: tree size = 12.
	#(#c #j #g #i #k #l #f #e #d #h #a #b) do: [:ea | tree removeKey: ea].
	self assert: tree size = 0.
	self assertSorted: tree.
	self assertConsistent: tree.
]

{ #category : 'tests' }
CTBTreeTest >> testRemoveLots [
	| tree |
	tree := CTBTree new.
	#(a b c d e f g h i j k l) do: [:ea | tree at: ea put: ea, '!'].
	self assert: tree size = 12.
	#(a c e g i k) shuffled do: [:ea | tree removeKey: ea].
	self assert: tree size = 6.
	self assertSorted: tree.
	self assertConsistent: tree.
]

{ #category : 'tests' }
CTBTreeTest >> testSimpleAddAndRetrieve [
	self checkTreeWithOrder: 5 items: 1
]

{ #category : 'tests' }
CTBTreeTest >> testStoreNil [
	self checkTree: CTBTree new array: {{'x'. 1}. {'y'. nil}}
]

{ #category : 'tests' }
CTBTreeTest >> testStringKeys [
	self checkTree: (CTBTree keys: CTBTreeStringKeys new) items: 100
]