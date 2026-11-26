Class {
	#name : 'MiButterflyZoomToFit',
	#superclass : 'MiButterflyCanvasMenuItem',
	#category : 'MooseIDE-Roassal-ButterflyMap-Menu',
	#package : 'MooseIDE-Roassal-ButterflyMap',
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
