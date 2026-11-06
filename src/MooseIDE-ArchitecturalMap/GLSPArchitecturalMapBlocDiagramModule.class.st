"
The architectural map diagram, with its root nodes laid out by Bloc (BlGridLayout) instead of Roassal: see GLSPArchitecturalMapBlocGModelFactory.

Same diagram type as my superclass, so the same clients work:
	GLSPArchitecturalMapBlocDiagramModule serve: aMapModel onPort: 5007
"
Class {
	#name : 'GLSPArchitecturalMapBlocDiagramModule',
	#superclass : 'GLSPArchitecturalMapDiagramModule',
	#category : 'MooseIDE-ArchitecturalMap-GLSP',
	#package : 'MooseIDE-ArchitecturalMap',
	#tag : 'GLSP'
}

{ #category : 'accessing' }
GLSPArchitecturalMapBlocDiagramModule >> gmodelFactory [

	^ GLSPArchitecturalMapBlocGModelFactory new
]
