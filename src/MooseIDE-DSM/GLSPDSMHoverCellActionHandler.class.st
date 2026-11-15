"
When the mouse is over a cell of an SCC (a cycle), all the cells of the SCC are shown red (MiDSMBrowserModel>>showSCCColorForTuple:) instead of pink, until the mouse leaves them: the model is sent again (updateModel), only when the cells to highlight change.
"
Class {
	#name : 'GLSPDSMHoverCellActionHandler',
	#superclass : 'GLSPActionHandler',
	#category : 'MooseIDE-DSM-GLSP',
	#package : 'MooseIDE-DSM',
	#tag : 'GLSP'
}

{ #category : 'executing' }
GLSPDSMHoverCellActionHandler >> execute: aHoverAction in: aClientSession [
	"Highlight the SCC of the cell under the mouse; send the model again only if the highlighted cells changed"

	| source tuples |
	source := aClientSession modelState sourceModel.
	tuples := (source sccTuplesOf: (source tupleWithCellId: aHoverAction cellId)) asSet.
	tuples = source highlightedTuples ifTrue: [ ^ #(  ) ].
	source highlightedTuples: tuples.
	aClientSession updateGModel.
	^ { (GLSPUpdateModelAction newRoot: aClientSession modelState root) }
]

{ #category : 'executing' }
GLSPDSMHoverCellActionHandler >> handledActionKinds [

	^ { GLSPDSMHoverCellAction kind }
]
