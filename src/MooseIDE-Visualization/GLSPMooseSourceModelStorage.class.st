"
The storage of the GLSP diagrams of MooseIDE (GLSPMooseDiagramModule): nothing is read, the source model of a session is its browser, set when the session is created; saving is not supported (the diagrams are read-only).
"
Class {
	#name : 'GLSPMooseSourceModelStorage',
	#superclass : 'GLSPSourceModelStorage',
	#category : 'MooseIDE-Visualization-GLSP',
	#package : 'MooseIDE-Visualization',
	#tag : 'GLSP'
}

{ #category : 'accessing' }
GLSPMooseSourceModelStorage >> loadSourceModel: aModelState [
	"Nothing to read: the source model of the session is already its browser (see GLSPMooseDiagramModule>>createClientSession:server:clientActionKinds:)"

	
]

{ #category : 'accessing' }
GLSPMooseSourceModelStorage >> saveSourceModel: aModelState to: anUri [

	GLSPServerError signal: 'This diagram is read-only'
]
