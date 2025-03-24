Class {
	#name : 'CTTSTreeNode',
	#superclass : 'Object',
	#instVars : [
		'key',
		'value',
		'low',
		'high',
		'equal'
	],
	#category : 'Collections-BTree',
	#package : 'Collections-BTree'
}

{ #category : 'as yet unclassified' }
CTTSTreeNode class >> key: aCharacter [
	^ self basicNew initializeWithKey: aCharacter
]

{ #category : 'private' }
CTTSTreeNode >> canBeCulled [
	^ self value isNil and: [ low isNil and: [ equal isNil and: [ high isNil ] ] ]
]

{ #category : 'private' }
CTTSTreeNode >> cullNode: aNode [
	low == aNode ifTrue: [^ low := nil].
	equal == aNode ifTrue: [^ equal := nil].
	high == aNode ifTrue: [^ high := nil]
]

{ #category : 'private' }
CTTSTreeNode >> do: aBlock [
	self nodesDo: [ :ea | ea value ifNotNil: aBlock ]
]

{ #category : 'private' }
CTTSTreeNode >> initializeWithKey: aCharacter [
	key := aCharacter
]

{ #category : 'private' }
CTTSTreeNode >> keysAndValuesDo: aBlock prefix: aString [
	| fullKey |
	fullKey := aString copyWith: key.
	value ifNotNil: [aBlock value: fullKey value: value].
	low ifNotNil: [low keysAndValuesDo: aBlock prefix: aString].
	equal ifNotNil: [equal keysAndValuesDo: aBlock prefix: fullKey].
	high ifNotNil: [high keysAndValuesDo: aBlock prefix: aString]
]

{ #category : 'private' }
CTTSTreeNode >> lookupString: aString startingAt: i [
	| char |
	char := aString at: i.
	char = key
		ifTrue:
			[aString size = i
				ifTrue: [^ value]
				ifFalse: [^ equal ifNotNil: [equal lookupString: aString startingAt: i+1]]]
		ifFalse:
			[char < key
				ifTrue: [^ low ifNotNil: [low lookupString: aString startingAt: i]]
				ifFalse: [^ high ifNotNil: [high lookupString: aString startingAt: i]]]
]

{ #category : 'private' }
CTTSTreeNode >> lookupString: aString startingAt: i insert: anObject [
	self
		lookupString: aString
		startingAt: i
		whenFound: [self value: anObject]
		whenNil: [:c | self newNodeWithKey: c]
		recurseWith: [:node :j | node lookupString: aString startingAt: j insert: anObject]
]

{ #category : 'private' }
CTTSTreeNode >> lookupString: aString startingAt: i whenFound: foundBlock whenNil: nilBlock recurseWith: recurseBlock [
	| char |
	char := aString at: i.
	char = key
		ifTrue:
			[aString size = i
				ifTrue: [foundBlock value]
				ifFalse: [equal ifNil: [equal := nilBlock value: (aString at: i+1)].
						 recurseBlock value: equal value: i+1]]
		ifFalse:
			[char < key
				ifTrue: [low ifNil: [low := nilBlock value: char].
						recurseBlock value: low value: i]
				ifFalse: [high ifNil: [high := nilBlock value: char].
						recurseBlock value: high value: i]]
]

{ #category : 'private' }
CTTSTreeNode >> matchesForPrefix: aString startingAt: i do: aBlock [
	self
		lookupString: aString
		startingAt: i
		whenFound: [value ifNotNil: [aBlock value: value].  equal ifNotNil: [equal do: aBlock]]
		whenNil: [:c | ^ self]
		recurseWith: [:n :j | n matchesForPrefix: aString startingAt: j do: aBlock]
]

{ #category : 'private' }
CTTSTreeNode >> matchesForString: aString startingAt: i distance: d do: aBlock nodesDo: nodeBlock [
	
	| char d2 |
	nodeBlock value: self.
	d < 0 ifTrue: [^ self].
	
	char := aString at: i.
	(d > 0 or: [char < key])
		ifTrue: [low ifNotNil: [low matchesForString: aString startingAt: i distance: d do: aBlock nodesDo: nodeBlock]].
		
	d2 := char = key ifTrue: [d] ifFalse: [d-1].
	(i + d2 = aString size and: [value notNil]) ifTrue: [aBlock value: value].
	equal ifNotNil: [equal matchesForString: aString startingAt: (i+1 min: aString size) distance: d2 do: aBlock nodesDo: nodeBlock].
	
	(d > 0 or: [char > key])
		ifTrue: [high ifNotNil: [high matchesForString: aString startingAt: i distance: d do: aBlock nodesDo: nodeBlock]]
]

{ #category : 'private' }
CTTSTreeNode >> newNodeWithKey: aCharacter [
	^ self class key: aCharacter
]

{ #category : 'private' }
CTTSTreeNode >> nodesDo: aBlock [
	aBlock value: self.
	low ifNotNil: [low nodesDo: aBlock].
	equal ifNotNil: [equal nodesDo: aBlock].
	high ifNotNil: [high nodesDo: aBlock]
]

{ #category : 'private' }
CTTSTreeNode >> removeString: aString startingAt: i [
	| val |
	self
		lookupString: aString
		startingAt: i
		whenFound: [val := self value. self value: nil]
		whenNil: [:c | ^ nil]
		recurseWith:
			[:node :j |
			val := node removeString: aString startingAt: j.
			node canBeCulled ifTrue:
				[self cullNode: node]].
	^ val
]

{ #category : 'private' }
CTTSTreeNode >> value [
	^ value
]

{ #category : 'private' }
CTTSTreeNode >> value: anObject [
	value := anObject
]