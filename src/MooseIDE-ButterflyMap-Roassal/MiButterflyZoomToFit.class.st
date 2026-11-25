Class {
	#name : 'MiButterflyZoomToFit',
	#superclass : 'MiButterflyCanvasMenuItem',
	#category : 'MooseIDE-ButterflyMap-Roassal-Menu',
	#package : 'MooseIDE-ButterflyMap-Roassal',
	#tag : 'Menu'
}

{ #category : 'execution' }
MiButterflyZoomToFit >> execute [

	visualization container zoomToFit
]

{ #category : 'accessing' }
MiButterflyZoomToFit >> group [

	^ 1
]

{ #category : 'accessing' }
MiButterflyZoomToFit >> label [

	^ 'ZoomToFit'
]
