"
The browser of a MooseIDE visualization shown by a GLSP client, as a MiAbstractBrowser is for a visualization shown in Pharo. One per client session (see GLSPMooseDiagramModule>>createClientSession:server:clientActionKinds:), with its own model (see class>>on:).

I am the browser of my model (MiAbstractModel>>browser:), which calls me back; my subclasses answer these callbacks, usually by sending the model again to the client (#sendModelToClient). When the client has gone, the model gets a browser without client (#detachFromModel). Before the diagram module gives me my session, I am a browser without client (see class>>modelOn:).

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
GLSPMooseBrowser class >> modelOn: aCollection [
	"A model of the entities of aCollection, with a browser without client"

	^ (self on: aCollection) model
]

{ #category : 'instance creation' }
GLSPMooseBrowser class >> newModel [

	self subclassResponsibility
]

{ #category : 'instance creation' }
GLSPMooseBrowser class >> on: aCollection [
	"A browser with its own model of the entities of aCollection, as a MooseIDE browser in Pharo has its own model"

	| browser aModel |
	browser := self new.
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

{ #category : 'client' }
GLSPMooseBrowser >> detachFromModel [
	"My client has gone: the model gets a browser without client (MooseIDE models need one)"

	(model notNil and: [ model browser == self ]) ifTrue: [ self class new model: model ]
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
	"The model changed: draw it again and send it to the client. If the client has gone, I am no longer the browser of the model"

	session ifNil: [ ^ self ].
	session modelState sourceModel == self ifFalse: [ ^ self ].
	session updateGModel.
	session server ifNil: [ ^ self ].
	[ session sendToClient: self updateModelAction ]
		on: NetworkError
		do: [ :error | self detachFromModel ]
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
