"
Experimental: a read-only GLSP diagram ('dsm-diagram') showing a MiDSMBrowserModel as a matrix (see GLSPDSMVisualization); each client session has its GLSPDSMBrowser (see GLSPMooseDiagramModule).
When the mouse is over a cell of an SCC, the browser client sends a custom action (GLSPDSMHoverCellAction) and the cells of that SCC are shown red instead of pink (GLSPDSMHoverCellActionHandler).

	launcher := GLSPDSMDiagramModule serve: aMooseGroup onPort: 5007.
	launcher stop

With the architectural map on the same port: GLSPMooseDiagramModule serveAll: { GLSPArchitecturalMapDiagramModule on: aMooseGroup. GLSPDSMDiagramModule on: aMooseGroup } onPort: 5007.
"
Class {
	#name : 'GLSPDSMDiagramModule',
	#superclass : 'GLSPMooseDiagramModule',
	#category : 'MooseIDE-DSM-GLSP',
	#package : 'MooseIDE-DSM',
	#tag : 'GLSP'
}

{ #category : 'examples' }
GLSPDSMDiagramModule class >> exampleServe [
	"Serve the DSM of the packages of the first Moose model on port 5007; inspect the launcher and send it #stop when done"

	<example>
	^ (self serve: MooseModel root allModels first allModelPackages onPort: 5007) inspect
]

{ #category : 'accessing' }
GLSPDSMDiagramModule >> browserClass [

	^ GLSPDSMBrowser
]

{ #category : 'accessing' }
GLSPDSMDiagramModule >> createActionHandlers [
	"Hovering a cell highlights its SCC"

	^ super createActionHandlers
		  add: GLSPDSMHoverCellActionHandler new;
		  yourself
]

{ #category : 'accessing' }
GLSPDSMDiagramModule >> diagramType [

	^ 'dsm-diagram'
]

{ #category : 'accessing' }
GLSPDSMDiagramModule >> gmodelFactory [

	^ GLSPDSMVisualization new
]
