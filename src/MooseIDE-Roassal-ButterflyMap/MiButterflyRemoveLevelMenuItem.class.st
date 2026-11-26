Class {
	#name : 'MiButterflyRemoveLevelMenuItem',
	#superclass : 'MiButterflyCanvasMenuItem',
	#category : 'MooseIDE-Roassal-ButterflyMap-Menu',
	#package : 'MooseIDE-Roassal-ButterflyMap',
	#tag : 'Menu'
}

{ #category : 'execution' }
MiButterflyRemoveLevelMenuItem >> execute [

	visualization removeLevel
]

{ #category : 'accessing' }
MiButterflyRemoveLevelMenuItem >> label [

	^ 'Remove external layer'
]

{ #category : 'accessing' }
MiButterflyRemoveLevelMenuItem >> order [

	^ 0
]
