Class {
	#name : 'MiButterflyNodeRemove',
	#superclass : 'MiButterflyNodeMenuItem',
	#category : 'MooseIDE-ButterflyMap-Roassal-Menu',
	#package : 'MooseIDE-ButterflyMap-Roassal',
	#tag : 'Menu'
}

{ #category : 'execution' }
MiButterflyNodeRemove >> execute [

	visualization removeNode: shape
	
]

{ #category : 'accessing' }
MiButterflyNodeRemove >> label [

	^ 'Remove node'
]
