"
Experimental: a read-only GLSP diagram ('dsm-diagram') showing a MiStandaloneDSMModel as a matrix (see GLSPDSMGModelFactory).

	launcher := GLSPDSMDiagramModule serve: (MiStandaloneDSMModel on: aMooseGroup) onPort: 5008.
	launcher stop
"
Class {
	#name : 'GLSPDSMDiagramModule',
	#superclass : 'GLSPDiagramModule',
	#instVars : [
		'dsmModel'
	],
	#category : 'MooseIDE-DSM-GLSP',
	#package : 'MooseIDE-DSM',
	#tag : 'GLSP'
}

{ #category : 'examples' }
GLSPDSMDiagramModule class >> exampleServe [
	"Serve the DSM of the packages of the first Moose model on port 5008; inspect the launcher and send it #stop when done"

	<example>
	^ (self serve: (MiStandaloneDSMModel on: MooseModel root allModels first allModelPackages) onPort: 5008) inspect
]

{ #category : 'serving' }
GLSPDSMDiagramModule class >> serve: aDSMModel onPort: aPortNumber [
	"Serve aDSMModel to external GLSP clients over TCP. Answer the launcher (send it #stop when done)"

	^ (GLSPSocketLauncher serverFactory: [
			   GLSPServer new
				   registerDiagramModule: (self new
						    dsmModel: aDSMModel;
						    yourself);
				   yourself ])
		  startOnPort: aPortNumber;
		  yourself
]

{ #category : 'accessing' }
GLSPDSMDiagramModule >> diagramType [

	^ 'dsm-diagram'
]

{ #category : 'accessing' }
GLSPDSMDiagramModule >> dsmModel [

	^ dsmModel
]

{ #category : 'accessing' }
GLSPDSMDiagramModule >> dsmModel: aDSMModel [

	dsmModel := aDSMModel
]

{ #category : 'accessing' }
GLSPDSMDiagramModule >> gmodelFactory [

	^ GLSPDSMGModelFactory new
]

{ #category : 'accessing' }
GLSPDSMDiagramModule >> sourceModelStorage [

	^ GLSPDSMSourceModelStorage new
		  dsmModel: dsmModel;
		  yourself
]
