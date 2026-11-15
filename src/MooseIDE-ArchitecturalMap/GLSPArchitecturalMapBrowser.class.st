"
The browser of an architectural map shown by a GLSP client (one per client session), as MiArchitecturalMapBrowser is for a map shown in Pharo.

It is the browser of its MiArchitecturalMapModel (MiAbstractModel>>browser:), which calls it back: #runVisualization sends the map again to the client (after a change of the settings), #application gives the current MiApplication. A browser without client (see class>>mapModelOn:) is what the model has when no client is connected.

It is also the source model of its session: GLSPArchitecturalMapVisualization draws the map from it.
"
Class {
	#name : 'GLSPArchitecturalMapBrowser',
	#superclass : 'Object',
	#instVars : [
		'mapModel',
		'session'
	],
	#category : 'MooseIDE-ArchitecturalMap-GLSP',
	#package : 'MooseIDE-ArchitecturalMap',
	#tag : 'GLSP'
}

{ #category : 'instance creation' }
GLSPArchitecturalMapBrowser class >> mapModelOn: aCollection [
	"An architectural map model of aCollection (a MooseGroup), with a browser without client: it can be served (GLSPArchitecturalMapDiagramModule class>>serve:onPort:), each client then has its browser"

	| model |
	model := MiArchitecturalMapModel new.
	self new mapModel: model.
	model entities: aCollection.
	^ model
]

{ #category : 'accessing' }
GLSPArchitecturalMapBrowser >> application [
	"The model asks it for its queries and settings"

	^ MiApplication current
]

{ #category : 'callbacks from the model' }
GLSPArchitecturalMapBrowser >> detachFromModel [
	"My client has gone: the model gets a browser without client (MiArchitecturalMapModel needs one)"

	(mapModel notNil and: [ mapModel browser == self ]) ifTrue: [ self class new mapModel: mapModel ]
]

{ #category : 'accessing' }
GLSPArchitecturalMapBrowser >> mapModel [

	^ mapModel
]

{ #category : 'accessing' }
GLSPArchitecturalMapBrowser >> mapModel: aMapModel [
	"I become the browser of aMapModel: it calls me back"

	mapModel := aMapModel.
	aMapModel browser: self
]

{ #category : 'callbacks from the model' }
GLSPArchitecturalMapBrowser >> runVisualization [
	"The map changed (MiArchitecturalMapModel>>updateFromConfiguration:): send it again to the client. If the client has gone, I am no longer the browser of the model"

	session ifNil: [ ^ self ].
	session modelState sourceModel == self ifFalse: [ ^ self ].
	session updateGModel.
	session server ifNil: [ ^ self ].
	[ session sendToClient: (GLSPUpdateModelAction newRoot: session modelState root) ]
		on: NetworkError
		do: [ :error | self detachFromModel ]
]

{ #category : 'callbacks from the model' }
GLSPArchitecturalMapBrowser >> selectRelatedTo: anEntity [
	"Nothing is selected in a GLSP client from Pharo"

	
]

{ #category : 'accessing' }
GLSPArchitecturalMapBrowser >> session [

	^ session
]

{ #category : 'accessing' }
GLSPArchitecturalMapBrowser >> session: aClientSession [

	session := aClientSession
]

{ #category : 'accessing' }
GLSPArchitecturalMapBrowser >> title [

	^ 'Architectural map (GLSP)'
]
