"
Experimental: a read-only GLSP diagram ('archmap-diagram') showing the root nodes of a MiArchitecturalMapModel, laid out by Roassal, with their aggregated dependencies (see GLSPArchitecturalMapVisualization). Each client session has its own GLSPArchitecturalMapBrowser, set as the browser of the map model.

	launcher := GLSPArchitecturalMapDiagramModule serve: aMooseGroup onPort: 5007.
	launcher stop.
	GLSPArchitecturalMapDiagramModule openOn: aMooseGroup.    ""a Bloc editor in this image""

or, to keep the model: model := GLSPArchitecturalMapBrowser mapModelOn: aMooseGroup, then serveModel:onPort: or openOnModel:.
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

{ #category : 'serving' }
GLSPArchitecturalMapDiagramModule class >> openOn: aCollection [
	"Open a Bloc editor on the architectural map of aCollection (a MooseGroup)"

	^ self openOnModel: (GLSPArchitecturalMapBrowser mapModelOn: aCollection)
]

{ #category : 'serving' }
GLSPArchitecturalMapDiagramModule class >> openOnModel: aMapModel [
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
GLSPArchitecturalMapDiagramModule class >> serve: aCollection onPort: aPortNumber [
	"Serve the architectural map of aCollection (a MooseGroup) to external GLSP clients over TCP. Answer the launcher (send it #stop when done)"

	^ self serveModel: (GLSPArchitecturalMapBrowser mapModelOn: aCollection) onPort: aPortNumber
]

{ #category : 'serving' }
GLSPArchitecturalMapDiagramModule class >> serveModel: aMapModel onPort: aPortNumber [
	"Serve aMapModel (a MiArchitecturalMapModel, see GLSPArchitecturalMapBrowser class>>mapModelOn:) to external GLSP clients over TCP; each client gets its GLSPArchitecturalMapBrowser. Answer the launcher (send it #stop when done)"

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
GLSPArchitecturalMapDiagramModule >> createClientSession: anId server: aServer clientActionKinds: aCollection [
	"Each client session has its browser, set in the map model"

	| session |
	session := super createClientSession: anId server: aServer clientActionKinds: aCollection.
	session modelState sourceModel: (GLSPArchitecturalMapBrowser new
			 session: session;
			 mapModel: mapModel;
			 yourself).
	^ session
]

{ #category : 'accessing' }
GLSPArchitecturalMapDiagramModule >> diagramType [

	^ 'archmap-diagram'
]

{ #category : 'accessing' }
GLSPArchitecturalMapDiagramModule >> gmodelFactory [

	^ GLSPArchitecturalMapVisualization new
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
