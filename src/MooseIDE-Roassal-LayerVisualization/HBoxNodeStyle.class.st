Class {
	#name : 'HBoxNodeStyle',
	#superclass : 'HBorderAndTitleStyle',
	#category : 'MooseIDE-Roassal-LayerVisualization-Visualization',
	#package : 'MooseIDE-Roassal-LayerVisualization',
	#tag : 'Visualization'
}

{ #category : 'building' }
HBoxNodeStyle >> layoutOn: aGroupOfShapes parent: anHNode [
	aGroupOfShapes ifEmpty: [ ^ self ].
	
	self relayout: aGroupOfShapes parent: anHNode.
	
	
]
