"
A read-only GLSP diagram of MooseIDE, showing a model of a MooseIDE browser (e.g. a MiDSMBrowserModel). Each client session gets its own browser (my #browserClass, a GLSPMooseBrowser), set as the browser of the model; the model is shared by the sessions.

My subclasses say what is specific to their diagram: #diagramType, #gmodelFactory (the visualization) and #browserClass.

Several diagrams can be served on one port, each client choosing its diagram type:
	launcher := GLSPMooseDiagramModule
		serveAll: { GLSPArchitecturalMapDiagramModule on: aMooseGroup. GLSPDSMDiagramModule on: aMooseGroup }
		onPort: 5007.
	launcher stop

One diagram: GLSPDSMDiagramModule serve: aMooseGroup onPort: 5007 (or serveModel: aModel onPort: 5007).
"
Class {
	#name : 'GLSPMooseDiagramModule',
	#superclass : 'GLSPDiagramModule',
	#instVars : [
		'model'
	],
	#category : 'MooseIDE-Visualization-GLSP',
	#package : 'MooseIDE-Visualization',
	#tag : 'GLSP'
}

{ #category : 'serving' }
GLSPMooseDiagramModule class >> on: aCollection [
	"My diagram of the entities of aCollection (a MooseGroup)"

	^ self new
		  model: (self new browserClass modelOn: aCollection);
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

{ #category : 'serving' }
GLSPMooseDiagramModule class >> serveModel: aModel onPort: aPortNumber [
	"Serve my diagram of aModel (see GLSPMooseBrowser class>>modelOn:) alone. Answer the launcher (send it #stop when done)"

	^ self
		  serveAll: { (self new
				   model: aModel;
				   yourself) }
		  onPort: aPortNumber
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> browserClass [
	"The GLSPMooseBrowser subclass of my diagram"

	self subclassResponsibility
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> createClientSession: anId server: aServer clientActionKinds: aCollection [
	"Each client session has its browser, set in the model"

	| session |
	session := super createClientSession: anId server: aServer clientActionKinds: aCollection.
	session modelState sourceModel: (self browserClass new
			 session: session;
			 model: model;
			 yourself).
	^ session
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> model [

	^ model
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> model: aModel [

	model := aModel
]

{ #category : 'accessing' }
GLSPMooseDiagramModule >> sourceModelStorage [

	^ GLSPMooseSourceModelStorage new
]
