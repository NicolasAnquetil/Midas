"
The browser of a MooseIDE visualization shown by a GLSP client, as a MiAbstractBrowser is for a visualization shown in Pharo. One per client session, created with it (see GLSPMooseDiagramModule>>createClientSession:server:clientActionKinds:), with its own model (see class>>on:session:).

I am the browser of my model (MiAbstractModel>>browser:), which calls me back; my subclasses answer these callbacks, usually by sending the model again to the client (#sendModelToClient).

I am also the source model of my session: the visualization (the GLSP model factory) draws the model from me.

My class side says what is specific to my diagram, for GLSPMooseDiagramModule: diagramType, gmodelFactory, actionHandlers and the type hints. It also builds my diagram module (diagramModuleOn:) and serves it alone (serve:onPort:).
"
Class {
	#name : 'GLSPMooseBrowser',
	#superclass : 'Object',
	#instVars : [
		'model',
		'session'
	],
	#category : 'MooseIDE-Visualization-GLSP',
	#package : 'MooseIDE-Visualization',
	#tag : 'GLSP'
}

{ #category : 'diagram' }
GLSPMooseBrowser class >> actionHandlers [
	"The handlers of what the client of my diagram sends, beside the standard requests"

	^ #(  )
]

{ #category : 'serving' }
GLSPMooseBrowser class >> diagramModuleOn: aCollection [
	"My diagram of the entities of aCollection (a MooseGroup), to register in a GLSP server"

	^ GLSPMooseDiagramModule browserClass: self entities: aCollection
]

{ #category : 'diagram' }
GLSPMooseBrowser class >> diagramType [
	"The GLSP diagram type of my diagram, chosen by the client"

	self subclassResponsibility
]

{ #category : 'diagram' }
GLSPMooseBrowser class >> edgeTypeHints [
	"What the user can do with the edges of my diagram; nil: GLSP's defaults"

	^ nil
]

{ #category : 'diagram' }
GLSPMooseBrowser class >> gmodelFactory [
	"The visualization drawing my model for the client (a GLSPGModelFactory)"

	self subclassResponsibility
]

{ #category : 'instance creation' }
GLSPMooseBrowser class >> newModel [

	self subclassResponsibility
]

{ #category : 'instance creation' }
GLSPMooseBrowser class >> on: aCollection session: aClientSession [
	"The browser of aClientSession, with its own model of the entities of aCollection, as a MooseIDE browser in Pharo has its own model.
	Building the model already calls me back: nothing is sent to the client, I am not yet the source model of the session (see #sendModelToClient)"

	| browser aModel |
	browser := self new.
	browser session: aClientSession.
	aModel := self newModel.
	browser model: aModel.
	self setEntities: aCollection in: aModel.
	^ browser
]

{ #category : 'serving' }
GLSPMooseBrowser class >> serve: aCollection onPort: aPortNumber [
	"Serve my diagram of the entities of aCollection (a MooseGroup) alone. Answer the launcher (send it #stop when done).
	Several diagrams on one port: GLSPMooseDiagramModule class>>serveAll:onPort:"

	^ GLSPMooseDiagramModule serveAll: { (self diagramModuleOn: aCollection) } onPort: aPortNumber
]

{ #category : 'instance creation' }
GLSPMooseBrowser class >> setEntities: aCollection in: aModel [

	self subclassResponsibility
]

{ #category : 'diagram' }
GLSPMooseBrowser class >> shapeTypeHints [
	"What the user can do with the nodes of my diagram; nil: GLSP's defaults"

	^ nil
]

{ #category : 'accessing' }
GLSPMooseBrowser >> application [
	"Models ask it for their queries and settings"

	^ MiApplication current
]

{ #category : 'accessing' }
GLSPMooseBrowser >> model [

	^ model
]

{ #category : 'accessing' }
GLSPMooseBrowser >> model: aModel [
	"I become the browser of aModel: it calls me back"

	model := aModel.
	aModel browser: self
]

{ #category : 'client' }
GLSPMooseBrowser >> sendModelToClient [
	"The model changed: draw it again and send it to the client. Not while the model is being built (I am not yet the source model of my session), nor once my client has gone"

	session modelState sourceModel == self ifFalse: [ ^ self ].
	session updateGModel.
	session server ifNil: [ ^ self ].
	[ session sendToClient: self updateModelAction ]
		on: NetworkError
		do: [ :error | "The client has gone: nobody to send to" ]
]

{ #category : 'accessing' }
GLSPMooseBrowser >> session [

	^ session
]

{ #category : 'accessing' }
GLSPMooseBrowser >> session: aClientSession [

	session := aClientSession
]

{ #category : 'accessing' }
GLSPMooseBrowser >> title [

	^ self class name
]

{ #category : 'client' }
GLSPMooseBrowser >> updateModelAction [

	^ GLSPUpdateModelAction newRoot: session modelState root
]
