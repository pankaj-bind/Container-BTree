Class {
	#name : 'CTDateTreeTest',
	#superclass : 'TestCase',
	#instVars : [
		'now',
		'sixHours',
		'tomorrow',
		'nextWeek',
		'twoWeeks',
		'threeWeeks',
		'timespans'
	],
	#category : 'Collections-BTree-Tests',
	#package : 'Collections-BTree-Tests'
}

{ #category : 'running' }
CTDateTreeTest >> setUp [
	now := DateAndTime now.
	sixHours := now + 6 hours.
	tomorrow := now + 1 day.
	nextWeek := now + 1 week.
	twoWeeks := now + 2 weeks.
	threeWeeks := now + 3 weeks.
	
	timespans := Set new.
	
	timespans add: (Timespan starting: now ending: nextWeek).
	timespans add: (Timespan starting: nextWeek ending: twoWeeks).
	timespans add: (Timespan starting: now ending: tomorrow).
	timespans add: (Timespan starting: sixHours ending: (sixHours + 6 hours)).
]

{ #category : 'tests' }
CTDateTreeTest >> testAdd [
	| dateRanges timespan |
	dateRanges := CTDateTree new.
	timespan := Timespan starting: now ending: twoWeeks.
	dateRanges at: timespan put: timespan.
	self assert: (dateRanges at: timespan) = timespan
]

{ #category : 'tests' }
CTDateTreeTest >> testClipEndRange [
	| dateRanges returnedDates expectedDates |
	dateRanges := CTDateTree new.
	timespans do: [:ea | dateRanges at: ea put: ea asString].
	expectedDates := timespans select: [:ea | (ea start >= now) and: [ea end <= nextWeek]] thenCollect: [:ea | ea asString].
	returnedDates := (dateRanges between: now and: nextWeek) collect: [:ea | ea asString].
	self assert: (returnedDates intersection: expectedDates) size = expectedDates size
]

{ #category : 'tests' }
CTDateTreeTest >> testClipStartRange [
	| dateRanges returnedDates expectedDates |
	dateRanges := CTDateTree new.
	timespans do: [:ea | dateRanges at: ea put: ea asString].
	expectedDates := timespans select: [:ea | (ea start >= nextWeek) and: [ea end <= twoWeeks]] thenCollect: [:ea | ea asString].
	returnedDates := (dateRanges between: nextWeek and: twoWeeks) collect: [:ea | ea asString].
	self assert: (returnedDates intersection: expectedDates) size = expectedDates size
]

{ #category : 'tests' }
CTDateTreeTest >> testFirstLast [
	| dateRanges |
	dateRanges := CTDateTree new.
	self should: [dateRanges first] raise: Error.
	self should: [dateRanges last] raise: Error.
	dateRanges at: (Timespan starting: tomorrow ending: nextWeek) put: #inner.
	self assert: dateRanges first = #inner.
	self assert: dateRanges last = #inner.
	dateRanges at: (Timespan starting: now ending: twoWeeks) put: #outer.
	self assert: dateRanges first = #outer.
	self assert: dateRanges last = #outer.
	dateRanges at: (Timespan starting: tomorrow ending: threeWeeks) put: #last.
	self assert: dateRanges first = #outer.
	self assert: dateRanges last = #last
]

{ #category : 'tests' }
CTDateTreeTest >> testInclusiveRange [
	| dateRanges returnedDates expectedDates |
	dateRanges := CTDateTree new.
	timespans do: [:ea | dateRanges at: ea put: ea asString].
	expectedDates := timespans collect: [:ea | ea asString].
	returnedDates := (dateRanges between: now and: threeWeeks) collect: [:ea | ea asString].
	self assert: (returnedDates intersection: expectedDates) size = expectedDates size
]

{ #category : 'tests' }
CTDateTreeTest >> testIteration [
	| dateRanges |
	dateRanges := CTDateTree new.
	timespans do: [:ea | dateRanges at: ea put: ea asString].
	dateRanges keysAndValuesDo: [:key :val | self assert: key asString = val]
]

{ #category : 'tests' }
CTDateTreeTest >> testMissing [
	| dateRanges timespan missingTimespan |
	dateRanges := CTDateTree new.
	timespan := Timespan starting: now ending: twoWeeks.
	missingTimespan := Timespan starting: now ending: tomorrow.
	dateRanges at: timespan put: timespan.
	self assert: (dateRanges at: missingTimespan ifAbsent: [false]) = false
]

{ #category : 'tests' }
CTDateTreeTest >> testRemove [
	| dateRanges timespan |
	dateRanges := CTDateTree new.
	timespans do: [:ea | dateRanges at: ea put: ea asString].
	timespan := timespans anyOne.
	self assert: (dateRanges at: timespan) = timespan asString.
	dateRanges removeKey: timespan.
	self assert: (dateRanges at: timespan ifAbsent: [false]) = false
]

{ #category : 'tests' }
CTDateTreeTest >> testWithin [
	| dateRanges duration expected returned |
	dateRanges := CTDateTree new.
	timespans do: [:ea | dateRanges at: ea put: ea asString].
	duration := 12 hours.
	expected := timespans select: [:ea | 
		(ea start >= (sixHours - duration)) and: [ea end <= (sixHours + duration)]] 
		thenCollect: [:ea | ea asString].
	returned := (dateRanges within: duration of: sixHours) collect: [:ea | ea asString].
	self assert: (returned intersection: expected) size = expected size
]