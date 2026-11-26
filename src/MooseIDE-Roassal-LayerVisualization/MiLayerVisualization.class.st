"
I am a roassal presenter for the MiLayerVisualizationBrowser.
I have a canvas and I use a builder (MiLayerVisualizationBuilder).
"
Class {
	#name : 'MiLayerVisualization',
	#superclass : 'MiAbstractHierarchicalVisualization',
	#category : 'MooseIDE-Roassal-LayerVisualization-Visualization',
	#package : 'MooseIDE-Roassal-LayerVisualization',
	#tag : 'Visualization'
}

{ #category : 'initialization' }
MiLayerVisualization >> buildInCanvas: aCanvas [

	owner specModel ifNil: [ ^ self ].

	builder := MiLayerVisualizationBuilder new
		           mapModel: owner specModel;
		           container: aCanvas;
		           yourself.

	builder build
]
