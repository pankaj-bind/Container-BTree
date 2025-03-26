"
I provide a way to efficiently store and access date intervals. I am capable of answering the question, ""What events lie within a given date range."" 
"
Class {
	#name : 'CTDateTree',
	#superclass : 'Collection',
	#instVars : [
		'startTimes',
		'endTimes',
		'events'
	],
	#category : 'Collections-BTree',
	#package : 'Collections-BTree'
}

{ #category : 'accessing' }
CTDateTree >> at: aTimepan [
	^ self at: aTimepan ifAbsent: [ self error: aTimepan printString, ' not found' ]
]

{ #category : 'accessing' }
CTDateTree >> at: aTimespan ifAbsent: aBlock [
	^ events at: aTimespan ifAbsent: aBlock
]

{ #category : 'accessing' }
CTDateTree >> at: aTimespan ifAbsentPut: exceptionBlock [
	^ self at: aTimespan ifAbsent: [ self at: aTimespan put: exceptionBlock value ].
]

{ #category : 'adding' }
CTDateTree >> at: aTimespan put: anObject [
	| timespans |
	timespans := startTimes at: aTimespan start ifAbsentPut: [ Set new ].
	timespans add: aTimespan.
	timespans := endTimes at: aTimespan end ifAbsentPut: [ Set new ].
	timespans add: aTimespan.
	events at: aTimespan put: anObject.
	^ anObject
]

{ #category : 'enumerating' }
CTDateTree >> between: startDateAndTime and: endDateAndTime [
	"I return all events between a given start date and end date."
	
	| values |
	values := CTTreeSet new.
	self between: startDateAndTime and: endDateAndTime keysAndValuesDo: [ :key :val | values add: val ].
	^ values
]

{ #category : 'enumerating' }
CTDateTree >> between: startDateAndTime and: endDateAndTime keysAndValuesDo: aBlock [
	| startOrLater endOrEarlier |

	"This adds stuff really slowly; I'm not sure what to do about that yet"
	startOrLater := CTTreeSet new.
	endOrEarlier := CTTreeSet new.
	startTimes from: DateAndTime epoch to: endDateAndTime do: [ :ea | endOrEarlier addAll: ea ].
	"Kluge to make the ranges work."
	endTimes from: startDateAndTime to: (DateAndTime year: 2029 day: 1) do: [ :ea | startOrLater addAll: ea ].
	(startOrLater intersection: endOrEarlier) do: [ :ea | aBlock value: ea value: (self at: ea) ].
]

{ #category : 'enumerating' }
CTDateTree >> do: aBlock [
	events do: aBlock.
]

{ #category : 'enumerating' }
CTDateTree >> during: aTimespan [
	"Return all events occuring within a given timespan"
	
	^ self between: aTimespan start and: aTimespan end
]

{ #category : 'accessing' }
CTDateTree >> endTimes [
	^ endTimes
]

{ #category : 'accessing' }
CTDateTree >> first [
	| timespans |
	timespans := startTimes first 
		asSortedCollection: [ :a :b | a start <= b start ].
	^ events 
		at: timespans first
		ifAbsent: [ self errorEmptyCollection ]
]

{ #category : 'initialize-release' }
CTDateTree >> initialize [
	startTimes := CTBTree new.
	endTimes := CTBTree new.
	events := Dictionary new
]

{ #category : 'accessing' }
CTDateTree >> keys [
	| keys |
	keys := Set new.
	self keysAndValuesDo: [:k :v | keys add: k].
	^ keys
]

{ #category : 'enumerating' }
CTDateTree >> keysAndValuesDo: aBlock [
	events keysAndValuesDo: aBlock.
]

{ #category : 'accessing' }
CTDateTree >> last [
	| timespans |
	timespans := endTimes last 
		asSortedCollection: [ :a :b | a end <= b end ].
	^ events 
		at: timespans last
		ifAbsent: [ self errorEmptyCollection ]
]

{ #category : 'adding' }
CTDateTree >> removeKey: aTimespan [
	self removeKey: aTimespan ifAbsent: [ self error: aTimespan printString, ' not found' ].
]

{ #category : 'adding' }
CTDateTree >> removeKey: aTimespan ifAbsent: exceptionBlock [
	| set |
	events removeKey: aTimespan ifAbsent: [^ exceptionBlock].
	
	"If we got here, we should be able to remove the start and end caches too."
	set := (startTimes at: aTimespan start) remove: aTimespan; yourself.
	set isEmpty ifTrue: [ startTimes removeKey: aTimespan start ].
	set := (endTimes at: aTimespan end) remove: aTimespan; yourself.
	set isEmpty ifTrue: [ endTimes removeKey: aTimespan end ].
]

{ #category : 'accessing' }
CTDateTree >> startTimes [
	^ startTimes
]

{ #category : 'enumerating' }
CTDateTree >> within: aDuration of: aDateAndTime [
	"Returns all events within the given duration from the given date, in either direction."
	
	^ self between: (aDateAndTime - aDuration) and: (aDateAndTime + aDuration)
]