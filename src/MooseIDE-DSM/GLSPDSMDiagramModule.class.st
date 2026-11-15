"
Experimental: a read-only GLSP diagram ('dsm-diagram') showing a MiDSMBrowserModel as a matrix (see GLSPDSMVisualization).
When the mouse is over a cell of an SCC, the browser client sends a custom action (GLSPDSMHoverCellAction) and the cells of that SCC are shown red instead of pink (GLSPDSMHoverCellActionHandler). Each client session has its own GLSPDSMBrowser, set as the browser of the DSM model.

	launcher := GLSPDSMDiagramModule serve: aMooseGroup onPort: 5008.
	launcher stop

or, to keep the model: model := GLSPDSMBrowser dsmModelOn: aMooseGroup, then GLSPDSMDiagramModule serveModel: model onPort: 5008.
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

{ #category : 'serving' }
GLSPDSMDiagramModule class >> exampleServe [
	"Serve the DSM of the packages of the first Moose model on port 5008; inspect the launcher and send it #stop when done"

	<example>
	^ (self serve: MooseModel root allModels first allModelPackages onPort: 5008) inspect
]

{ #category : 'serving' }
GLSPDSMDiagramModule class >> serve: aCollection onPort: aPortNumber [
	"Serve the DSM of the entities of aCollection to external GLSP clients over TCP. Answer the launcher (send it #stop when done)"

	^ self serveModel: (GLSPDSMBrowser dsmModelOn: aCollection) onPort: aPortNumber
]

{ #category : 'serving' }
GLSPDSMDiagramModule class >> serveModel: aDSMModel onPort: aPortNumber [
	"Serve aDSMModel (a MiDSMBrowserModel, see GLSPDSMBrowser class>>dsmModelOn:) to external GLSP clients over TCP; each client gets its GLSPDSMBrowser. Answer the launcher (send it #stop when done)"

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
GLSPDSMDiagramModule >> createActionHandlers [
	"Hovering a cell highlights its SCC"

	^ super createActionHandlers
		  add: GLSPDSMHoverCellActionHandler new;
		  yourself
]

{ #category : 'accessing' }
GLSPDSMDiagramModule >> createClientSession: anId server: aServer clientActionKinds: aCollection [
	"Each client session has its browser, set in the DSM model"

	| session |
	session := super createClientSession: anId server: aServer clientActionKinds: aCollection.
	session modelState sourceModel: (GLSPDSMBrowser new
			 session: session;
			 dsmModel: dsmModel;
			 yourself).
	^ session
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

	^ GLSPDSMVisualization new
]

{ #category : 'accessing' }
GLSPDSMDiagramModule >> sourceModelStorage [

	^ GLSPDSMSourceModelStorage new
		  dsmModel: dsmModel;
		  yourself
]
