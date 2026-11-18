"
Experimental: a read-only GLSP diagram ('archmap-diagram') showing the root nodes of a MiArchitecturalMapModel, laid out by Roassal, with their aggregated dependencies (see GLSPArchitecturalMapVisualization); each client session has its GLSPArchitecturalMapBrowser (see GLSPMooseDiagramModule).

	launcher := GLSPArchitecturalMapDiagramModule serve: aMooseGroup onPort: 5007.
	launcher stop.
	GLSPArchitecturalMapDiagramModule openOn: aMooseGroup.    ""a Bloc editor in this image""

With the DSM on the same port: GLSPMooseDiagramModule serveAll: { GLSPArchitecturalMapDiagramModule on: aMooseGroup. GLSPDSMDiagramModule on: aMooseGroup } onPort: 5007.
"
Class {
	#name : 'GLSPArchitecturalMapDiagramModule',
	#superclass : 'GLSPMooseDiagramModule',
	#category : 'MooseIDE-ArchitecturalMap-GLSP',
	#package : 'MooseIDE-ArchitecturalMap',
	#tag : 'GLSP'
}

{ #category : 'serving' }
GLSPArchitecturalMapDiagramModule class >> example [

	<example>
	^ self openOn: MooseModel root allModels first allModelPackages
]

{ #category : 'serving' }
GLSPArchitecturalMapDiagramModule class >> exampleServe [
	"Serve the packages of the first Moose model on port 5007; inspect the launcher and send it #stop when done"

	<example>
	^ (self serve: MooseModel root allModels first allModelPackages onPort: 5007) inspect
]

{ #category : 'opening' }
GLSPArchitecturalMapDiagramModule class >> openOn: aCollection [
	"Open a Bloc editor on the architectural map of aCollection (a MooseGroup)"

	^ self openOnModule: (self on: aCollection)
]

{ #category : 'opening' }
GLSPArchitecturalMapDiagramModule class >> openOnModule: aDiagramModule [
	"Serve aDiagramModule from a GLSP server of this image and open a Bloc editor on it.
	The sourceUri is ignored by the server, but GLSPBlocEditor derives its title from a file:// URL"

	| server client diagram |
	server := GLSPServer new
		          registerDiagramModule: aDiagramModule;
		          yourself.
	client := GLSPClient loopbackOn: server.
	diagram := client openDiagram: aDiagramModule diagramType.
	diagram requestModel: 'file:///Architectural-Map'.
	^ GLSPBlocEditor openOn: diagram
]

{ #category : 'accessing' }
GLSPArchitecturalMapDiagramModule >> browserClass [

	^ GLSPArchitecturalMapBrowser
]

{ #category : 'accessing' }
GLSPArchitecturalMapDiagramModule >> createActionHandlers [
	"The user can move and select the nodes"

	^ super createActionHandlers
		  add: GLSPArchitecturalMapChangeBoundsHandler new;
		  add: GLSPArchitecturalMapSelectHandler new;
		  yourself
]

{ #category : 'accessing' }
GLSPArchitecturalMapDiagramModule >> diagramType [

	^ 'archmap-diagram'
]

{ #category : 'accessing' }
GLSPArchitecturalMapDiagramModule >> edgeTypeHints [
	"What the user can do with the dependencies (the client applies it): nothing, they follow their nodes"

	^ { (GLSPEdgeTypeHint new
		   elementTypeId: 'archmap-dependency';
		   repositionable: false;
		   deletable: false;
		   routable: false;
		   yourself) }
]

{ #category : 'accessing' }
GLSPArchitecturalMapDiagramModule >> gmodelFactory [

	^ GLSPArchitecturalMapVisualization new
]

{ #category : 'accessing' }
GLSPArchitecturalMapDiagramModule >> shapeTypeHints [
	"What the user can do with the nodes (the client applies it): only move them"

	^ { (GLSPShapeTypeHint new
		   elementTypeId: 'archmap-node';
		   repositionable: true;
		   resizable: false;
		   deletable: false;
		   reparentable: false;
		   yourself) }
]
