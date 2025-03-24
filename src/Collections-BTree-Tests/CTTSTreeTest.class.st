Class {
	#name : 'CTTSTreeTest',
	#superclass : 'TestCase',
	#instVars : [
		'tree',
		'empty'
	],
	#category : 'Collections-BTree-Tests',
	#package : 'Collections-BTree-Tests'
}

{ #category : 'running' }
CTTSTreeTest >> setUp [
	tree := CTTSTree new.
	self words shuffled do: [:ea | tree at: ea put: ea asUppercase].
	empty := CTTSTree new.
]

{ #category : 'accessing' }
CTTSTreeTest >> words [
	"Return a sample list of words for testing."
	^ #('abear' 'abel' 'abeam' 'abelia' 'abelmosk' 'abed' 'abet' 'abracadabra')
]

{ #category : 'tests' }
CTTSTreeTest >> testAt [
	self assert: (tree at: 'abear') = 'ABEAR'.
	self assert: (tree at: 'abelmosk') = 'ABELMOSK'.
	self assert: (tree at: 'abracadabra' ifAbsent: [42]) = 42.
	self assert: (tree at: '' ifAbsent: [42]) = 42.
	self assert: (empty at: 'foo' ifAbsent: [42]) = 42 
]

{ #category : 'tests' }
CTTSTreeTest >> testMatch [
	self assert: (tree matchesForString: 'abea' distance: 1) asSet = #(ABEAM ABEAR ABED ABEL ABET ABE) asSet.
	self assert: (tree matchesForString: 'abel' distance: 2) asSet = #(ABELIA ABEAM ABEAR) asSet.
	self assert: (tree matchesForString: 'abel' distance: 0) = #(ABEL).
	self assert: (tree matchesForString: '' distance: 1) = #().
	self assert: (empty matchesForString: 'foo' distance: 0) = #()
]

{ #category : 'tests' }
CTTSTreeTest >> testAddAndRetrieve [
	| newTree |
	newTree := CTTSTree new.
	newTree at: 'test' put: 'TEST'.
	self assert: (newTree at: 'test') = 'TEST'.
	newTree at: 'testing' put: 'TESTING'.
	self assert: (newTree at: 'testing') = 'TESTING'.
	self assert: (newTree at: 'test') = 'TEST'.
	self assert: (newTree at: 'nonexistent' ifAbsent: [nil]) isNil
]

{ #category : 'tests' }
CTTSTreeTest >> testEmptyString [
	| newTree |
	newTree := CTTSTree new.
	newTree at: '' put: 'EMPTY'.
	self assert: (newTree at: '') = 'EMPTY'.
	newTree at: 'foo' put: 'FOO'.
	self assert: (newTree at: '') = 'EMPTY'.
	self assert: (newTree at: 'foo') = 'FOO'.
	self assert: (newTree at: 'bar' ifAbsent: [nil]) isNil
]

{ #category : 'tests' }
CTTSTreeTest >> testKeysAndValuesDo [
	| keys values expectedKeys expectedValues |
	keys := OrderedCollection new.
	values := OrderedCollection new.
	tree keysAndValuesDo: [:k :v | keys add: k. values add: v].
	
	expectedKeys := self words asOrderedCollection.
	expectedValues := self words collect: [:ea | ea asUppercase] as: OrderedCollection.
	
	self assert: keys asSet = expectedKeys asSet.
	self assert: values asSet = expectedValues asSet.
	
	keys := OrderedCollection new.
	empty keysAndValuesDo: [:k :v | keys add: k].
	self assert: keys isEmpty
]

{ #category : 'tests' }
CTTSTreeTest >> testMatchesForPrefix [
	| matches |
	matches := tree matchesForPrefix: 'abe'.
	self assert: (matches asSet includesAll: #('ABEAM' 'ABEAR' 'ABED' 'ABEL' 'ABELIA' 'ABELMOSK' 'ABET')).
	self assert: matches size = 7.
	
	matches := tree matchesForPrefix: 'abr'.
	self assert: matches asSet = #('ABRACADABRA') asSet.
	
	matches := tree matchesForPrefix: 'xyz'.
	self assert: matches isEmpty.
	
	matches := empty matchesForPrefix: 'abe'.
	self assert: matches isEmpty
]

{ #category : 'tests' }
CTTSTreeTest >> testRemoveKey [
	| newTree |
	newTree := CTTSTree new.
	newTree at: 'foo' put: 'FOO'.
	newTree at: 'foobar' put: 'FOOBAR'.
	
	newTree removeKey: 'foo'.
	self assert: (newTree at: 'foo' ifAbsent: [nil]) isNil.
	self assert: (newTree at: 'foobar') = 'FOOBAR'.
	
	newTree removeKey: 'foobar'.
	self assert: (newTree at: 'foobar' ifAbsent: [nil]) isNil.
	
	self should: [newTree removeKey: 'nonexistent'] raise: Error.
	self assert: (newTree at: 'nonexistent' ifAbsent: [42]) = 42
]

{ #category : 'tests' }
CTTSTreeTest >> testRemoveAll [
	| newTree |
	newTree := CTTSTree new.
	self words do: [:ea | newTree at: ea put: ea asUppercase].
	
	self words do: [:ea | newTree removeKey: ea].
	self words do: [:ea | self assert: (newTree at: ea ifAbsent: [nil]) isNil].
	
	newTree at: '' put: 'EMPTY'.
	newTree removeKey: ''.
	self assert: (newTree at: '' ifAbsent: [nil]) isNil
]

{ #category : 'tests' }
CTTSTreeTest >> testDo [
	| values expectedValues |
	values := OrderedCollection new.
	tree do: [:ea | values add: ea].
	
	expectedValues := self words collect: [:ea | ea asUppercase] as: OrderedCollection.
	self assert: values asSet = expectedValues asSet.
	
	values := OrderedCollection new.
	empty do: [:ea | values add: ea].
	self assert: values isEmpty
]

{ #category : 'tests' }
CTTSTreeTest >> testValues [
	| values expectedValues |
	values := tree values.
	expectedValues := self words collect: [:ea | ea asUppercase].
	self assert: values asSet = expectedValues asSet.
	
	values := empty values.
	self assert: values isEmpty
]

{ #category : 'tests' }
CTTSTreeTest >> testKeys [
	| keys expectedKeys |
	keys := tree keys.
	expectedKeys := self words.
	self assert: keys asSet = expectedKeys asSet.
	
	keys := empty keys.
	self assert: keys isEmpty
]

{ #category : 'tests' }
CTTSTreeTest >> testMatchesForStringWithLimit [
	| matches |
	matches := tree matchesForString: 'abea' distance: 1 limitNodes: 3 do: [:ea | ea].
	self assert: matches size <= 3.
	self assert: (matches allSatisfy: [:ea | #(ABEAM ABEAR ABED ABEL ABET ABE) includes: ea]).
	
	matches := empty matchesForString: 'foo' distance: 1 limitNodes: 5 do: [:ea | ea].
	self assert: matches isEmpty
]