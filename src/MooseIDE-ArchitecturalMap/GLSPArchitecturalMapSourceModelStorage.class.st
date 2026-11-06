"
I install a given MiStandaloneArchitecturalMapModel as the source model, ignoring the sourceUri. Saving is not supported.
"
Class {
	#name : 'GLSPArchitecturalMapSourceModelStorage',
	#superclass : 'GLSPSourceModelStorage',
	#instVars : [
		'mapModel'
	],
	#category : 'MooseIDE-ArchitecturalMap-GLSP',
	#package : 'MooseIDE-ArchitecturalMap',
	#tag : 'GLSP'
}

{ #category : 'persistence' }
GLSPArchitecturalMapSourceModelStorage >> loadSourceModel: aModelState [

	aModelState sourceModel: mapModel
]

{ #category : 'accessing' }
GLSPArchitecturalMapSourceModelStorage >> mapModel: aMapModel [

	mapModel := aMapModel
]

{ #category : 'persistence' }
GLSPArchitecturalMapSourceModelStorage >> saveSourceModel: aModelState to: anUri [

	GLSPServerError signal: 'The architectural map diagram is read-only'
]
