"
A read-only GLSP diagram of MooseIDE, showing the entities of a MooseGroup. One class for every diagram: my browserClass (a GLSPMooseBrowser subclass) says, on its class side, what is specific to the diagram: diagramType, gmodelFactory (the visualization), actionHandlers and the type hints (shapeTypeHints, edgeTypeHints; nil for GLSP's defaults).

Each client session gets its own browser with its own model (e.g. a MiDSMBrowserModel), as each MooseIDE browser in Pharo has its own model: each displayed diagram has its model.

The diagrams are read-only: the sessions get only the standard requests (model, type hints, context actions) and the handlers of the diagram; no operations, undo, redo or save, so the client is not told it can send them.

Several diagrams can be served on one port, each client choosing its diagram type:
	launcher := GLSPMooseDiagramModule
		serveAll: { GLSPArchitecturalMapBrowser diagramModuleOn: aMooseGroup. GLSPDSMBrowser diagramModuleOn: aMooseGroup }
		onPort: 5007.
	launcher stop

One diagram: GLSPDSMBrowser serve: aMooseGroup onPort: 5007
"
Class {
	#name : 'GLSPMooseDiagramModule',
	#superclass : 'GLSPDiagramModule',
	#instVars : [
		'entities',
		'browserClass'
	],
	#category : 'MooseIDE-Visualization-GLSP',
	#package : 'MooseIDE-Visualization',
	#tag : 'GLSP'
}

{ #category : 'instance creation' }
GLSPMooseDiagramModule class >> browserClass: aGLSPMooseBrowserClass entities: aCollection [
	"The diagram of aGLSPMooseBrowserClass showing the entities of aCollection (a MooseGroup)"

	^ self new
		  browserClass: aGLSPMooseBrowserClass;
		  entities: aCollection;
		  yourself
]

{ #category : 'serving' }
GLSPMooseDiagramModule class >> serveAll: aCollectionOfModules onPort: aPortNumber [
	"Serve these diagrams to external GLSP clients over TCP, on one port: each client chooses its diagram type. Answer the launcher (send it #stop when done)"

	^ (GLSPSocketLauncher serverFactory: [
				   | server |
				   server := GLSPServer new.
				   aCollectionOfModules do: [ :each | server registerDiagramModule: each copy ].
				   server ])
		  startOnPort: aPortNumber;
		  yourself
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> browserClass [
	"The GLSPMooseBrowser subclass of my diagram: it says what is specific to the diagram"

	^ browserClass
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> browserClass: aGLSPMooseBrowserClass [

	browserClass := aGLSPMooseBrowserClass
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> createActionHandlers [
	"Only what a read-only diagram uses: no operations, undo, redo or save, so the client is not told it can send them.
	Then the handlers of my diagram"

	^ OrderedCollection new
		  add: GLSPRequestModelActionHandler new;
		  add: GLSPRequestTypeHintsActionHandler new;
		  add: GLSPRequestContextActionsHandler new;
		  addAll: browserClass actionHandlers;
		  yourself
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> createClientSession: anId server: aServer clientActionKinds: aCollection [
	"Each client session has its browser with its own model, as each MooseIDE browser in Pharo has its own"

	| session |
	session := super createClientSession: anId server: aServer clientActionKinds: aCollection.
	session modelState sourceModel: (self browserClass on: entities session: session).
	^ session
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> diagramType [

	^ browserClass diagramType
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> edgeTypeHints [
	"Those of my diagram, else GLSP's defaults"

	^ browserClass edgeTypeHints ifNil: [ super edgeTypeHints ]
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> entities [
	"What my diagram shows (a MooseGroup): each client session draws it from its own model"

	^ entities
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> entities: aCollection [

	entities := aCollection
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> gmodelFactory [

	^ browserClass gmodelFactory
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> shapeTypeHints [
	"Those of my diagram, else GLSP's defaults"

	^ browserClass shapeTypeHints ifNil: [ super shapeTypeHints ]
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> sourceModelStorage [

	^ GLSPMooseSourceModelStorage new
]
