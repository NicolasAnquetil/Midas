"
The user selected or deselected nodes of the architectural map (standard GLSP actions elementSelected and allSelected): the map model keeps the selected entities (MiArchitecturalMapModel>>selectedEntities, its miSelectedItem). The client already shows the selection: nothing is sent back.
"
Class {
	#name : 'GLSPArchitecturalMapSelectHandler',
	#superclass : 'GLSPActionHandler',
	#category : 'MooseIDE-ArchitecturalMap-GLSP',
	#package : 'MooseIDE-ArchitecturalMap',
	#tag : 'GLSP'
}

{ #category : 'handling' }
GLSPArchitecturalMapSelectHandler >> execute: aSelectionAction in: aClientSession [
	"The map model keeps the new selection. Nothing to send back: the client already shows it"

	| browser mapModel |
	browser := aClientSession modelState sourceModel.
	mapModel := browser mapModel.
	mapModel selectedEntities: (aSelectionAction kind = GLSPSelectAllAction kind
			 ifTrue: [ self selectionAfterSelectAll: aSelectionAction in: mapModel ]
			 ifFalse: [ self selectionAfterSelect: aSelectionAction in: mapModel of: browser ]).
	^ #(  )
]

{ #category : 'handling' }
GLSPArchitecturalMapSelectHandler >> handledActionKinds [

	^ {
		  GLSPSelectAction kind.
		  GLSPSelectAllAction kind }
]

{ #category : 'handling' }
GLSPArchitecturalMapSelectHandler >> selectionAfterSelect: aSelectAction in: aMapModel of: aBrowser [

	| selection deselected |
	selection := aSelectAction deselectAll
		             ifTrue: [ OrderedCollection new ]
		             ifFalse: [ aMapModel selectedEntities copy ].
	deselected := aBrowser entitiesWithNodeIds: aSelectAction deselectedElementsIDs.
	selection removeAllSuchThat: [ :each | deselected includes: each ].
	(aBrowser entitiesWithNodeIds: aSelectAction selectedElementsIDs) do: [ :each |
		(selection includes: each) ifFalse: [ selection add: each ] ].
	^ selection
]

{ #category : 'handling' }
GLSPArchitecturalMapSelectHandler >> selectionAfterSelectAll: aSelectAllAction in: aMapModel [

	^ aSelectAllAction select
		  ifTrue: [ aMapModel rootNodes copy ]
		  ifFalse: [ #(  ) ]
]
