Class {
	#name : 'MiButterflyMenuItemStrategy',
	#superclass : 'HDefaultMenuItemStrategy',
	#category : 'MooseIDE-ButterflyMap-Roassal-Menu',
	#package : 'MooseIDE-ButterflyMap-Roassal',
	#tag : 'Menu'
}

{ #category : 'public' }
MiButterflyMenuItemStrategy >> classFor: aRoassalShape [

	aRoassalShape isShape ifFalse: [ ^ MiButterflyCanvasMenuItem ].
	^ aRoassalShape isNode
		  ifTrue: [
				  (aRoassalShape canvas selectedShapes notEmpty and: [
					   aRoassalShape canvas selectedShapes includes: aRoassalShape ])
					  ifTrue: [ HGroupMenuItem ]
					  ifFalse: [ MiButterflyNodeMenuItem ] ]
		  ifFalse: [ HLineMenuItem ]
]

{ #category : 'public' }
MiButterflyMenuItemStrategy >> menuItemClassesFor: aShape [

	^ (self classFor: aShape) subclasses , { MiButterflyInspectMenuItem }
]
