"
The user moved nodes of the architectural map (standard GLSP operation changeBounds): the browser of the session keeps their new positions.

An action handler, not an operation handler: operations are recorded for undo by copying the source model (GLSPRecordingCommand, veryDeepCopy), here the browser with the map model and the Moose model behind it. As in Roassal, moving a node cannot be undone.
"
Class {
	#name : 'GLSPArchitecturalMapChangeBoundsHandler',
	#superclass : 'GLSPActionHandler',
	#category : 'MooseIDE-ArchitecturalMap-GLSP',
	#package : 'MooseIDE-ArchitecturalMap',
	#tag : 'GLSP'
}

{ #category : 'handling' }
GLSPArchitecturalMapChangeBoundsHandler >> execute: aChangeBoundsOperation in: aClientSession [
	"The browser of the session keeps the new positions (the nodes cannot be resized: see the type hints of the module). Answer the model drawn again"

	| browser |
	browser := aClientSession modelState sourceModel.
	aChangeBoundsOperation elementBoundsDo: [ :elementId :newPosition :newSize |
		newPosition ifNotNil: [ browser moveNodeWithId: elementId to: newPosition ] ].
	aClientSession updateGModel.
	^ { browser updateModelAction }
]

{ #category : 'handling' }
GLSPArchitecturalMapChangeBoundsHandler >> handledActionKinds [

	^ { GLSPChangeBoundsOperation kind }
]
