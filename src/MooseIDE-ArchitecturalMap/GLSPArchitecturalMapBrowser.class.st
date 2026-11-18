"
The browser of an architectural map shown by a GLSP client (one per client session, see GLSPMooseBrowser), as MiArchitecturalMapBrowser is for a map shown in Pharo.

The MiArchitecturalMapModel calls it back: #runVisualization sends the map again to the client (after a change of the settings). GLSPArchitecturalMapVisualization draws the map from it.
"
Class {
	#name : 'GLSPArchitecturalMapBrowser',
	#superclass : 'GLSPMooseBrowser',
	#instVars : [
		'movedPositions'
	],
	#category : 'MooseIDE-ArchitecturalMap-GLSP',
	#package : 'MooseIDE-ArchitecturalMap',
	#tag : 'GLSP'
}

{ #category : 'diagram' }
GLSPArchitecturalMapBrowser class >> actionHandlers [
	"The user can move and select the nodes"

	^ {
		  GLSPArchitecturalMapChangeBoundsHandler new.
		  GLSPArchitecturalMapSelectHandler new }
]

{ #category : 'diagram' }
GLSPArchitecturalMapBrowser class >> diagramType [

	^ 'archmap-diagram'
]

{ #category : 'diagram' }
GLSPArchitecturalMapBrowser class >> edgeTypeHints [
	"What the user can do with the dependencies (the client applies it): nothing, they follow their nodes"

	^ { (GLSPEdgeTypeHint new
		   elementTypeId: 'archmap-dependency';
		   repositionable: false;
		   deletable: false;
		   routable: false;
		   yourself) }
]

{ #category : 'examples' }
GLSPArchitecturalMapBrowser class >> example [

	<example>
	^ self openOn: MooseModel root allModels first allModelPackages
]

{ #category : 'examples' }
GLSPArchitecturalMapBrowser class >> exampleServe [
	"Serve the packages of the first Moose model on port 5007; inspect the launcher and send it #stop when done"

	<example>
	^ (self serve: MooseModel root allModels first allModelPackages onPort: 5007) inspect
]

{ #category : 'diagram' }
GLSPArchitecturalMapBrowser class >> gmodelFactory [

	^ GLSPArchitecturalMapVisualization new
]

{ #category : 'instance creation' }
GLSPArchitecturalMapBrowser class >> newModel [

	^ MiArchitecturalMapModel new
]

{ #category : 'opening' }
GLSPArchitecturalMapBrowser class >> openOn: aCollection [
	"Open a Bloc editor on the architectural map of aCollection (a MooseGroup)"

	^ self openOnModule: (self diagramModuleOn: aCollection)
]

{ #category : 'opening' }
GLSPArchitecturalMapBrowser class >> openOnModule: aDiagramModule [
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

{ #category : 'instance creation' }
GLSPArchitecturalMapBrowser class >> setEntities: aCollection in: aModel [
	"aCollection: a MooseGroup (its metamodel gives the association types)"

	aModel entities: aCollection
]

{ #category : 'diagram' }
GLSPArchitecturalMapBrowser class >> shapeTypeHints [
	"What the user can do with the nodes (the client applies it): only move them"

	^ { (GLSPShapeTypeHint new
		   elementTypeId: 'archmap-node';
		   repositionable: true;
		   resizable: false;
		   deletable: false;
		   reparentable: false;
		   yourself) }
]

{ #category : 'selecting' }
GLSPArchitecturalMapBrowser >> entitiesWithNodeIds: aCollectionOfIds [
	"The entities drawn as nodes with these ids (other ids, e.g. of dependencies, are ignored)"

	| visualization |
	visualization := GLSPArchitecturalMapVisualization new.
	^ self mapModel rootNodes select: [ :each | aCollectionOfIds includes: (visualization idFor: each) ]
]

{ #category : 'accessing' }
GLSPArchitecturalMapBrowser >> mapModel [

	^ model
]

{ #category : 'moving' }
GLSPArchitecturalMapBrowser >> moveNodeWithId: anId to: aPoint [

	self movedPositions at: anId put: aPoint
]

{ #category : 'moving' }
GLSPArchitecturalMapBrowser >> movedPositions [
	"The positions where the user put nodes, by node id: they win over the layout of the map"

	^ movedPositions ifNil: [ movedPositions := Dictionary new ]
]

{ #category : 'moving' }
GLSPArchitecturalMapBrowser >> positionOfNodeWithId: anId ifNone: aBlock [
	"Where the user put this node, the value of aBlock if it was not moved"

	^ self movedPositions at: anId ifAbsent: aBlock
]

{ #category : 'updating' }
GLSPArchitecturalMapBrowser >> runVisualization [
	"The map changed (MiArchitecturalMapModel>>updateFromConfiguration:): laid out again, as in Roassal, the moved nodes too"

	movedPositions := nil.
	self sendModelToClient
]

{ #category : 'accessing' }
GLSPArchitecturalMapBrowser >> title [

	^ 'Architectural map (GLSP)'
]
