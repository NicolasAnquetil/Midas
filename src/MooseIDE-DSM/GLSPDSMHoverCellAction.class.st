"
A custom action sent by the browser client when the mouse comes over a cell of the DSM (cellId: the id of the cell), or leaves the cells (no cellId). See GLSPDSMHoverCellActionHandler.
"
Class {
	#name : 'GLSPDSMHoverCellAction',
	#superclass : 'GLSPAction',
	#instVars : [
		'cellId'
	],
	#category : 'MooseIDE-DSM-GLSP',
	#package : 'MooseIDE-DSM',
	#tag : 'GLSP'
}

{ #category : 'accessing' }
GLSPDSMHoverCellAction class >> kind [

	^ 'dsmHoverCell'
]

{ #category : 'accessing' }
GLSPDSMHoverCellAction >> cellId [

	^ cellId
]

{ #category : 'accessing' }
GLSPDSMHoverCellAction >> cellId: aString [

	cellId := aString
]
