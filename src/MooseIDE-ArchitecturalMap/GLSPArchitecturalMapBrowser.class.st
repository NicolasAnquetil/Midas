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

{ #category : 'instance creation' }
GLSPArchitecturalMapBrowser class >> newModel [

	^ MiArchitecturalMapModel new
]

{ #category : 'instance creation' }
GLSPArchitecturalMapBrowser class >> setEntities: aCollection in: aModel [
	"aCollection: a MooseGroup (its metamodel gives the association types)"

	aModel entities: aCollection
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
