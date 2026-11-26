"
Butterfly visualization.
"
Class {
	#name : 'MiButterflyMapVisualization',
	#superclass : 'MiAbstractHierarchicalVisualization',
	#category : 'MooseIDE-Roassal-ButterflyMap-Visualization',
	#package : 'MooseIDE-Roassal-ButterflyMap',
	#tag : 'Visualization'
}

{ #category : 'running' }
MiButterflyMapVisualization >> buildInCanvas: aCanvas [

	owner specModel currentEntity ifNil: [ ^ self ].
	aCanvas @ RSCanvasController new noLegend.

	builder := MiButterflyMapBuilder new
		           mapModel: owner specModel;
		           container: aCanvas;
		           yourself.
	builder build
]

{ #category : 'running' }
MiButterflyMapVisualization >> update [

	self refresh
]
