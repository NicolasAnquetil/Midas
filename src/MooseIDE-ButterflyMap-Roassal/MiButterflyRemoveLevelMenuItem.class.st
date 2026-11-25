Class {
	#name : 'MiButterflyRemoveLevelMenuItem',
	#superclass : 'MiButterflyCanvasMenuItem',
	#category : 'MooseIDE-ButterflyMap-Roassal-Menu',
	#package : 'MooseIDE-ButterflyMap-Roassal',
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
