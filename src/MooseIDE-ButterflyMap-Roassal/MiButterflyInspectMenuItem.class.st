Class {
	#name : 'MiButterflyInspectMenuItem',
	#superclass : 'MiButterflyMenuItem',
	#category : 'MooseIDE-ButterflyMap-Roassal-Menu',
	#package : 'MooseIDE-ButterflyMap-Roassal',
	#tag : 'Menu'
}

{ #category : 'testing' }
MiButterflyInspectMenuItem >> canBeExecuted [

	^ shape isShape
]

{ #category : 'execution' }
MiButterflyInspectMenuItem >> execute [

	MiInspectorBrowser inspect: shape model rawModel
]

{ #category : 'accessing' }
MiButterflyInspectMenuItem >> group [ 

	^ 100
]

{ #category : 'accessing' }
MiButterflyInspectMenuItem >> iconName [ 
	
	^ #smallInspectIt
]

{ #category : 'accessing' }
MiButterflyInspectMenuItem >> label [

	^ 'Inpsect'
]

{ #category : 'accessing' }
MiButterflyInspectMenuItem >> order [

	^ 100
]
