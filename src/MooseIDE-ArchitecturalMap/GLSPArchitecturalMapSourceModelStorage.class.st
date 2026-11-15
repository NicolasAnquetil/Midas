"
The source model of a session is its GLSPArchitecturalMapBrowser (see GLSPArchitecturalMapDiagramModule>>createClientSession:server:clientActionKinds:), not read from the sourceUri. Saving is not supported.
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

{ #category : 'accessing' }
GLSPArchitecturalMapSourceModelStorage >> loadSourceModel: aModelState [
	"The source model is the browser of the session (see GLSPArchitecturalMapDiagramModule>>createClientSession:server:clientActionKinds:)"

	aModelState sourceModel ifNil: [
			aModelState sourceModel: (GLSPArchitecturalMapBrowser new
					 mapModel: mapModel;
					 yourself) ]
]

{ #category : 'accessing' }
GLSPArchitecturalMapSourceModelStorage >> mapModel: aMapModel [

	mapModel := aMapModel
]

{ #category : 'persistence' }
GLSPArchitecturalMapSourceModelStorage >> saveSourceModel: aModelState to: anUri [

	GLSPServerError signal: 'The architectural map diagram is read-only'
]
