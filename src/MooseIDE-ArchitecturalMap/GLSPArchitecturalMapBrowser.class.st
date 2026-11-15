"
The browser of an architectural map shown by a GLSP client (one per client session, see GLSPMooseBrowser), as MiArchitecturalMapBrowser is for a map shown in Pharo.

The MiArchitecturalMapModel calls it back: #runVisualization sends the map again to the client (after a change of the settings). GLSPArchitecturalMapVisualization draws the map from it.
"
Class {
	#name : 'GLSPArchitecturalMapBrowser',
	#superclass : 'GLSPMooseBrowser',
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

{ #category : 'accessing' }
GLSPArchitecturalMapBrowser >> mapModel [

	^ model
]

{ #category : 'callbacks from the model' }
GLSPArchitecturalMapBrowser >> runVisualization [
	"The map changed (MiArchitecturalMapModel>>updateFromConfiguration:)"

	self sendModelToClient
]

{ #category : 'callbacks from the model' }
GLSPArchitecturalMapBrowser >> selectRelatedTo: anEntity [
	"Nothing is selected in a GLSP client from Pharo"

	
]

{ #category : 'accessing' }
GLSPArchitecturalMapBrowser >> title [

	^ 'Architectural map (GLSP)'
]
