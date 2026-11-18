"
A read-only GLSP diagram of MooseIDE, showing the entities of a MooseGroup. Each client session gets its own browser (my #browserClass, a GLSPMooseBrowser) with its own model (e.g. a MiDSMBrowserModel), as each MooseIDE browser in Pharo has its own model: each displayed diagram has its model.

My subclasses say what is specific to their diagram: #diagramType, #gmodelFactory (the visualization) and #browserClass.

Several diagrams can be served on one port, each client choosing its diagram type:
	launcher := GLSPMooseDiagramModule
		serveAll: { GLSPArchitecturalMapDiagramModule on: aMooseGroup. GLSPDSMDiagramModule on: aMooseGroup }
		onPort: 5007.
	launcher stop

One diagram: GLSPDSMDiagramModule serve: aMooseGroup onPort: 5007
"
Class {
	#name : 'GLSPMooseDiagramModule',
	#superclass : 'GLSPDiagramModule',
	#instVars : [
		'entities'
	],
	#category : 'MooseIDE-Visualization-GLSP',
	#package : 'MooseIDE-Visualization',
	#tag : 'GLSP'
}

{ #category : 'instance creation' }
GLSPMooseDiagramModule class >> on: aCollection [
	"My diagram of the entities of aCollection (a MooseGroup)"

	^ self new
		  entities: aCollection;
		  yourself
]

{ #category : 'serving' }
GLSPMooseDiagramModule class >> serve: aCollection onPort: aPortNumber [
	"Serve my diagram of the entities of aCollection (a MooseGroup) alone. Answer the launcher (send it #stop when done)"

	^ self serveAll: { (self on: aCollection) } onPort: aPortNumber
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
	"The GLSPMooseBrowser subclass of my diagram"

	self subclassResponsibility
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> createClientSession: anId server: aServer clientActionKinds: aCollection [
	"Each client session has its browser with its own model, as each MooseIDE browser in Pharo has its own"

	| session |
	session := super createClientSession: anId server: aServer clientActionKinds: aCollection.
	session modelState sourceModel: ((self browserClass on: entities)
			 session: session;
			 yourself).
	^ session
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
GLSPMooseDiagramModule >> sourceModelStorage [

	^ GLSPMooseSourceModelStorage new
]
