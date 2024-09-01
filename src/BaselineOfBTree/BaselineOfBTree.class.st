Class {
	#name : 'BaselineOfBTree',
	#superclass : 'BaselineOf',
	#instVars : [
		'root'
	],
	#category : 'BaselineOfBTree',
	#package : 'BaselineOfBTree'
}

{ #category : 'baselines' }
BaselineOfBTree >> baseline: spec [
	<baseline>
	
	spec for: #common do: [ 
		spec 
			package: 'Collections-BTree';
			package: 'Collections-BTree-Tests' with: [ spec requires: #('Collections-BTree') ].
		
		spec group: 'Core' with: #('Collections-BTree').
		spec group: 'Tests' with: #('Collections-BTree-Tests').
		spec group: 'default' with: #('Core' 'Tests').
	]
]
