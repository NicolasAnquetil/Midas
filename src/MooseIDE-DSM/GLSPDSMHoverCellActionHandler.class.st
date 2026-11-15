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
	"The browser of the session handles it"

	^ aClientSession modelState sourceModel hoverCellWithId: aHoverAction cellId
]

{ #category : 'executing' }
GLSPDSMHoverCellActionHandler >> handledActionKinds [

	^ { GLSPDSMHoverCellAction kind }
]
