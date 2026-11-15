"
The source model of a DSM diagram, one per client session: the DSM model (shared by the sessions) and the cells highlighted in this session (the SCC under the mouse).
"
Class {
	#name : 'GLSPDSMSourceModel',
	#superclass : 'Object',
	#instVars : [
		'dsmModel',
		'highlightedTuples'
	],
	#category : 'MooseIDE-DSM-GLSP',
	#package : 'MooseIDE-DSM',
	#tag : 'GLSP'
}

{ #category : 'accessing' }
GLSPDSMSourceModel >> dsmModel [

	^ dsmModel
]

{ #category : 'accessing' }
GLSPDSMSourceModel >> dsmModel: aDSMModel [

	dsmModel := aDSMModel
]

{ #category : 'accessing' }
GLSPDSMSourceModel >> highlightedTuples [

	^ highlightedTuples ifNil: [ highlightedTuples := Set new ]
]

{ #category : 'accessing' }
GLSPDSMSourceModel >> highlightedTuples: aCollection [

	highlightedTuples := aCollection asSet
]

{ #category : 'accessing' }
GLSPDSMSourceModel >> isHighlighted: aTuple [

	^ self highlightedTuples includes: aTuple
]

{ #category : 'accessing' }
GLSPDSMSourceModel >> sccTuplesOf: aTuple [
	"The cells of the SCC aTuple belongs to; empty if it is not in a cycle"

	aTuple ifNil: [ ^ #(  ) ].
	((dsmModel isDependency: aTuple) and: [ dsmModel isCycle: aTuple ]) ifFalse: [ ^ #(  ) ].
	^ dsmModel sccTuplesForTuple: aTuple
]

{ #category : 'accessing' }
GLSPDSMSourceModel >> tupleWithCellId: aString [
	"The tuple (column node -> row node) shown by the cell with this id (see GLSPDSMGModelFactory>>cellIdFrom:to:), nil if none"

	aString ifNil: [ ^ nil ].
	dsmModel orderedNodesX do: [ :column |
			dsmModel orderedNodesY do: [ :row |
				(GLSPDSMGModelFactory new cellIdFrom: column model to: row model) = aString ifTrue: [ ^ column -> row ] ] ].
	^ nil
]
