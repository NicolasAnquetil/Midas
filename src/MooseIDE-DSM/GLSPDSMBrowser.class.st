"
The browser of a DSM shown by a GLSP client (one per client session, see GLSPMooseBrowser), as MiDSMBrowser is for a DSM shown in Pharo.

The MiDSMBrowserModel calls it back: #buildDSM sends the matrix again to the client. It also holds the callback from the client: #hoverCellWithId: (the cell under the mouse, see GLSPDSMHoverCellAction) shows the SCC of that cell red instead of pink (#showSCC:). GLSPDSMVisualization draws the matrix from it.
"
Class {
	#name : 'GLSPDSMBrowser',
	#superclass : 'GLSPMooseBrowser',
	#instVars : [
		'highlightedTuples'
	],
	#category : 'MooseIDE-DSM-GLSP',
	#package : 'MooseIDE-DSM',
	#tag : 'GLSP'
}

{ #category : 'instance creation' }
GLSPDSMBrowser class >> newModel [

	^ MiDSMBrowserModel new
]

{ #category : 'instance creation' }
GLSPDSMBrowser class >> setEntities: aCollection in: aModel [
	"A square matrix of the dependencies between the entities of aCollection"

	aModel followEntity: aCollection
]

{ #category : 'callbacks from the model' }
GLSPDSMBrowser >> buildDSM [
	"The matrix changed (MiDSMBrowserModel>>followEntity:, withX:withY:, settings)"

	self sendModelToClient
]

{ #category : 'accessing' }
GLSPDSMBrowser >> dsmModel [

	^ model
]

{ #category : 'accessing' }
GLSPDSMBrowser >> highlightedTuples [

	^ highlightedTuples ifNil: [ highlightedTuples := Set new ]
]

{ #category : 'callbacks from the client' }
GLSPDSMBrowser >> hoverCellWithId: aString [
	"The mouse is over the cell with this id (nil: over no cell). Answer the actions to send back to the client: the model again, if the cells to show red changed"

	| tuples |
	tuples := (self sccTuplesOf: (self tupleWithCellId: aString)) asSet.
	tuples = self highlightedTuples ifTrue: [ ^ #(  ) ].
	self showSCC: tuples.
	session updateGModel.
	^ { self updateModelAction }
]

{ #category : 'accessing' }
GLSPDSMBrowser >> isHighlighted: aTuple [

	^ self highlightedTuples includes: aTuple
]

{ #category : 'accessing' }
GLSPDSMBrowser >> sccTuplesOf: aTuple [
	"The cells of the SCC aTuple belongs to; empty if it is not in a cycle"

	aTuple ifNil: [ ^ #(  ) ].
	((model isDependency: aTuple) and: [ model isCycle: aTuple ]) ifFalse: [ ^ #(  ) ].
	^ model sccTuplesForTuple: aTuple
]

{ #category : 'callbacks from the model' }
GLSPDSMBrowser >> showSCC: aCollection [
	"Show the cells (tuples) of aCollection red instead of pink, as MiDSMBrowser>>showSCC:"

	highlightedTuples := aCollection asSet
]

{ #category : 'accessing' }
GLSPDSMBrowser >> title [

	^ 'DSM (GLSP)'
]

{ #category : 'accessing' }
GLSPDSMBrowser >> tupleWithCellId: aString [
	"The tuple (column node -> row node) shown by the cell with this id (see GLSPDSMVisualization>>cellIdFrom:to:), nil if none"

	aString ifNil: [ ^ nil ].
	model orderedNodesX do: [ :column |
			model orderedNodesY do: [ :row |
				(GLSPDSMVisualization new cellIdFrom: column model to: row model) = aString ifTrue: [ ^ column -> row ] ] ].
	^ nil
]

{ #category : 'callbacks from the model' }
GLSPDSMBrowser >> updateToolbar [
	"The selected entities changed: no toolbar here"

	
]
