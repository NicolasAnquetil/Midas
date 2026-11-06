"
Experimental: a read-only GLSP diagram ('archmap-diagram') showing the root nodes of a MiStandaloneArchitecturalMapModel, laid out by Roassal, with their aggregated dependencies.
	GLSPArchitecturalMapDiagramModule openOn: (MiStandaloneArchitecturalMapModel new entities: aMooseGroup)
"
Class {
	#name : 'GLSPArchitecturalMapDiagramModule',
	#superclass : 'GLSPDiagramModule',
	#instVars : [
		'mapModel'
	],
	#category : 'MooseIDE-ArchitecturalMap-GLSP',
	#package : 'MooseIDE-ArchitecturalMap',
	#tag : 'GLSP'
}

{ #category : 'opening' }
GLSPArchitecturalMapDiagramModule class >> example [

	<example>
	^ self openOn: (MiStandaloneArchitecturalMapModel new entities: MooseModel root allModels first allModelPackages)
]

{ #category : 'serving' }
GLSPArchitecturalMapDiagramModule class >> exampleServe [
	"Serve the packages of the first Moose model on port 5007; inspect the launcher and send it #stop when done"

	<example>
	^ (self serve: (MiStandaloneArchitecturalMapModel new entities: MooseModel root allModels first allModelPackages) onPort: 5007)
		  inspect
]

{ #category : 'opening' }
GLSPArchitecturalMapDiagramModule class >> openOn: aMapModel [
	"Serve aMapModel from a GLSP server of this image and open a Bloc editor on it.
	The sourceUri is ignored by the server, but GLSPBlocEditor derives its title from a file:// URL"

	| server client diagram |
	server := GLSPServer new
		          registerDiagramModule: (self new
				           mapModel: aMapModel;
				           yourself);
		          yourself.
	client := GLSPClient loopbackOn: server.
	diagram := client openDiagram: self new diagramType.
	diagram requestModel: 'file:///Architectural-Map'.
	^ GLSPBlocEditor openOn: diagram
]

{ #category : 'serving' }
GLSPArchitecturalMapDiagramModule class >> serve: aMapModel onPort: aPortNumber [
	"Serve aMapModel to external GLSP clients over TCP. Answer the launcher (send it #stop when done)"

	^ (GLSPSocketLauncher serverFactory: [
				   GLSPServer new
					   registerDiagramModule: (self new
							    mapModel: aMapModel;
							    yourself);
					   yourself ])
		  startOnPort: aPortNumber;
		  yourself
]

{ #category : 'accessing' }
GLSPArchitecturalMapDiagramModule >> diagramType [

	^ 'archmap-diagram'
]

{ #category : 'accessing' }
GLSPArchitecturalMapDiagramModule >> gmodelFactory [

	^ GLSPArchitecturalMapGModelFactory new
]

{ #category : 'accessing' }
GLSPArchitecturalMapDiagramModule >> mapModel [

	^ mapModel
]

{ #category : 'accessing' }
GLSPArchitecturalMapDiagramModule >> mapModel: aMapModel [

	mapModel := aMapModel
]

{ #category : 'accessing' }
GLSPArchitecturalMapDiagramModule >> sourceModelStorage [

	^ GLSPArchitecturalMapSourceModelStorage new
		  mapModel: mapModel;
		  yourself
]
