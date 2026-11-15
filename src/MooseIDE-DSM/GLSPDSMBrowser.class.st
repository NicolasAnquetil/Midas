"
The browser of a DSM shown by a GLSP client (one per client session), as MiDSMBrowser is for a DSM shown in Pharo.

It is the browser of its DSM model (MiDSMBrowserModel>>browser:), which calls it back: #buildDSM sends the matrix again to the client. It also holds the callbacks from the client: #hoverCellWithId: (the cell under the mouse, see GLSPDSMHoverCellAction) shows the SCC of that cell red instead of pink (#showSCC:).

It is also the source model of its session: GLSPDSMGModelFactory builds the matrix from it.
"
Class {
	#name : 'GLSPDSMBrowser',
	#superclass : 'Object',
	#instVars : [
		'dsmModel',
		'highlightedTuples',
		'session'
	],
	#category : 'MooseIDE-DSM-GLSP',
	#package : 'MooseIDE-DSM',
	#tag : 'GLSP'
}

{ #category : 'instance creation' }
GLSPDSMBrowser class >> dsmModelOn: aCollection [
	"A DSM model of the dependencies between the entities of aCollection, with a browser without client: it can be served (GLSPDSMDiagramModule class>>serve:onPort:), each client then has its browser"

	| model |
	model := MiDSMBrowserModel new.
	self new dsmModel: model.
	model followEntity: aCollection.
	^ model
]

{ #category : 'callbacks from the model' }
GLSPDSMBrowser >> buildDSM [
	"The matrix changed (MiDSMBrowserModel>>followEntity:, withX:withY:, settings): send it again to the client. If the client has gone, I am no longer the browser of the model"

	session ifNil: [ ^ self ].
	session modelState sourceModel == self ifFalse: [ ^ self ].
	session updateGModel.
	session server ifNil: [ ^ self ].
	[ session sendToClient: self updateModelAction ]
		on: NetworkError
		do: [ :error | self detachFromModel ]
]

{ #category : 'callbacks from the model' }
GLSPDSMBrowser >> detachFromModel [
	"My client has gone: the model gets a browser without client (MiDSMBrowserModel needs one)"

	(dsmModel notNil and: [ dsmModel browser == self ]) ifTrue: [ self class new dsmModel: dsmModel ]
]

{ #category : 'accessing' }
GLSPDSMBrowser >> dsmModel [

	^ dsmModel
]

{ #category : 'accessing' }
GLSPDSMBrowser >> dsmModel: aDSMModel [
	"I become the browser of aDSMModel: it calls me back"

	dsmModel := aDSMModel.
	aDSMModel browser: self
]

{ #category : 'accessing' }
GLSPDSMBrowser >> highlightedTuples [

	^ highlightedTuples ifNil: [ highlightedTuples := Set new ]
]

{ #category : 'accessing' }
GLSPDSMBrowser >> highlightedTuples: aCollection [

	highlightedTuples := aCollection asSet
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
	((dsmModel isDependency: aTuple) and: [ dsmModel isCycle: aTuple ]) ifFalse: [ ^ #(  ) ].
	^ dsmModel sccTuplesForTuple: aTuple
]

{ #category : 'accessing' }
GLSPDSMBrowser >> session [

	^ session
]

{ #category : 'accessing' }
GLSPDSMBrowser >> session: aClientSession [

	session := aClientSession
]

{ #category : 'callbacks from the model' }
GLSPDSMBrowser >> showSCC: aCollection [
	"Show the cells (tuples) of aCollection red instead of pink, as MiDSMBrowser>>showSCC:"

	self highlightedTuples: aCollection
]

{ #category : 'accessing' }
GLSPDSMBrowser >> title [

	^ 'DSM (GLSP)'
]

{ #category : 'accessing' }
GLSPDSMBrowser >> tupleWithCellId: aString [
	"The tuple (column node -> row node) shown by the cell with this id (see GLSPDSMGModelFactory>>cellIdFrom:to:), nil if none"

	aString ifNil: [ ^ nil ].
	dsmModel orderedNodesX do: [ :column |
			dsmModel orderedNodesY do: [ :row |
				(GLSPDSMGModelFactory new cellIdFrom: column model to: row model) = aString ifTrue: [ ^ column -> row ] ] ].
	^ nil
]

{ #category : 'callbacks from the client' }
GLSPDSMBrowser >> updateModelAction [

	^ GLSPUpdateModelAction newRoot: session modelState root
]

{ #category : 'callbacks from the model' }
GLSPDSMBrowser >> updateToolbar [
	"The selected entities changed: no toolbar here"

	
]
