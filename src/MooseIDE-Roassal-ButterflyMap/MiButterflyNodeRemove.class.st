Class {
	#name : 'MiButterflyNodeRemove',
	#superclass : 'MiButterflyNodeMenuItem',
	#category : 'MooseIDE-Roassal-ButterflyMap-Menu',
	#package : 'MooseIDE-Roassal-ButterflyMap',
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
