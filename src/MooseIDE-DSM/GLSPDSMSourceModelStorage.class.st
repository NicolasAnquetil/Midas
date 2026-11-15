"
I install a given MiStandaloneDSMModel as the source model, ignoring the sourceUri. Saving is not supported.
"
Class {
	#name : 'GLSPDSMSourceModelStorage',
	#superclass : 'GLSPSourceModelStorage',
	#instVars : [
		'dsmModel'
	],
	#category : 'MooseIDE-DSM-GLSP',
	#package : 'MooseIDE-DSM',
	#tag : 'GLSP'
}

{ #category : 'accessing' }
GLSPDSMSourceModelStorage >> dsmModel: aDSMModel [

	dsmModel := aDSMModel
]

{ #category : 'accessing' }
GLSPDSMSourceModelStorage >> loadSourceModel: aModelState [
	"The source model is the browser of the session (see GLSPDSMDiagramModule>>createClientSession:server:clientActionKinds:)"

	aModelState sourceModel ifNil: [
			aModelState sourceModel: (GLSPDSMBrowser new
					 dsmModel: dsmModel;
					 yourself) ]
]

{ #category : 'accessing' }
GLSPDSMSourceModelStorage >> saveSourceModel: aModelState to: anUri [

	GLSPServerError signal: 'The DSM diagram is read-only'
]
