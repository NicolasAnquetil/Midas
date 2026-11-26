Class {
	#name : 'MiClassBlueprintVisualization',
	#superclass : 'MiAbstractVisualization',
	#category : 'MooseIDE-Roassal-ClassBlueprint-Visualization',
	#package : 'MooseIDE-Roassal-ClassBlueprint',
	#tag : 'Visualization'
}

{ #category : 'running' }
MiClassBlueprintVisualization >> buildInCanvas: aCanvas [

	| currentType |
	currentType := owner specModel currentType ifNil: [ ^ self ].

	currentType blueprint
		canvas: aCanvas;
		build.

	^ aCanvas @ RSCanvasController new noLegend
]
