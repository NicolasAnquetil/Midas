"
The browser of a MooseIDE visualization shown by a GLSP client, as a MiAbstractBrowser is for a visualization shown in Pharo. One per client session (see GLSPMooseDiagramModule>>createClientSession:server:clientActionKinds:).

I am the browser of my model (MiAbstractModel>>browser:), which calls me back; my subclasses answer these callbacks, usually by sending the model again to the client (#sendModelToClient). When the client has gone, the model gets a browser without client (#detachFromModel). A browser without client is also what a model has before any client connects (see class>>modelOn:).

I am also the source model of my session: the visualization (the GLSP model factory) draws the model from me.
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

{ #category : 'instance creation' }
GLSPMooseBrowser class >> modelOn: aCollection [
	"A model of the entities of aCollection, with a browser without client: it can be served (GLSPMooseDiagramModule), each client then has its browser"

	| aModel |
	aModel := self newModel.
	self new model: aModel.
	self setEntities: aCollection in: aModel.
	^ aModel
]

{ #category : 'instance creation' }
GLSPMooseBrowser class >> newModel [

	self subclassResponsibility
]

{ #category : 'instance creation' }
GLSPMooseBrowser class >> setEntities: aCollection in: aModel [

	self subclassResponsibility
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
