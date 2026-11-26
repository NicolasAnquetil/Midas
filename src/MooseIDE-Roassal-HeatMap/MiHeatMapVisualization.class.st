Class {
	#name : 'MiHeatMapVisualization',
	#superclass : 'MiAbstractHierarchicalVisualization',
	#category : 'MooseIDE-Roassal-HeatMap-Visualization',
	#package : 'MooseIDE-Roassal-HeatMap',
	#tag : 'Visualization'
}

{ #category : 'running' }
MiHeatMapVisualization >> buildInCanvas: aCanvas [

	owner specModel entities ifNil: [ ^ self ].
	builder := MiHeatMapBuilder new
		           mapModel: owner specModel;
		           container: aCanvas;
		           yourself.

	builder build.
	builder rootNode expandChildren.

	aCanvas @ RSCanvasController new noLegend
]
