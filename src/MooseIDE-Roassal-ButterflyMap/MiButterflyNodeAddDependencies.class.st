Class {
	#name : 'MiButterflyNodeAddDependencies',
	#superclass : 'MiButterflyNodeMenuItem',
	#category : 'MooseIDE-Roassal-ButterflyMap-Menu',
	#package : 'MooseIDE-Roassal-ButterflyMap',
	#tag : 'Menu'
}

{ #category : 'execution' }
MiButterflyNodeAddDependencies >> execute [

	visualization addNodesFor: shape
]

{ #category : 'accessing' }
MiButterflyNodeAddDependencies >> group [

	^ 3
]

{ #category : 'accessing' }
MiButterflyNodeAddDependencies >> label [

	^ 'Add dependencies'
]
