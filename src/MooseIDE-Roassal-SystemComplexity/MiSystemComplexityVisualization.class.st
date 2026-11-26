Class {
	#name : 'MiSystemComplexityVisualization',
	#superclass : 'MiAbstractHierarchicalVisualization',
	#category : 'MooseIDE-Roassal-SystemComplexity-Visualization',
	#package : 'MooseIDE-Roassal-SystemComplexity',
	#tag : 'Visualization'
}

{ #category : 'running' }
MiSystemComplexityVisualization >> buildInCanvas: canvas [

	self specModel ifNil: [ ^ self ].

	builder := MiSystemComplexityBuilder new
		           container: canvas;
		           mapModel: self specModel;
		           yourself.

	builder build.

	^ canvas @ RSCanvasController new noLegend
]

{ #category : 'accessing' }
MiSystemComplexityVisualization >> specModel [

	^ self owner specModel
]
