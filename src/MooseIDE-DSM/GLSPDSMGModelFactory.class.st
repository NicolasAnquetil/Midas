"
I turn a MiDSMBrowserModel (through the GLSPDSMBrowser of the session) into a GModel: a matrix with one column per entity of orderedNodesX and one row per entity of orderedNodesY.

- a 'dsm-column-header' and a 'dsm-row-header' node per entity, with its name as label ('dsm-column-label', 'dsm-row-label');
- a 'dsm-cell' node per (column, row) pair: the dependencies of the column entity towards the row entity. Its label ('dsm-weight') is their number (empty when 0); its css class tells its kind (dsm-diagonal, dsm-empty, dsm-cycle, dsm-dependency); its args give its color as the DSM model computes it ('fill') and a tooltip ('title').

The server does no text layout: the sizes come from the length of the names.
"
Class {
	#name : 'GLSPDSMGModelFactory',
	#superclass : 'GLSPGModelFactory',
	#category : 'MooseIDE-DSM-GLSP',
	#package : 'MooseIDE-DSM',
	#tag : 'GLSP'
}

{ #category : 'building' }
GLSPDSMGModelFactory >> cellFor: aTuple of: aSourceModel at: aPoint [
	"The dependencies of the column entity (key) towards the row entity (value). The cells of the SCC under the mouse are red instead of pink"

	| aDSMModel weight cell highlighted |
	aDSMModel := aSourceModel dsmModel.
	weight := aDSMModel getTupleDependencyWeight: aTuple.
	cell := self
		        node: (self cellIdFrom: aTuple key model to: aTuple value model)
		        type: 'dsm-cell'
		        at: aPoint
		        size: self cellSize
		        label: (weight > 0
				         ifTrue: [ weight printString ]
				         ifFalse: [ '' ])
		        labelType: 'dsm-weight'.
	cell addCssClass: 'dsm-' , (self kindOf: aTuple in: aDSMModel).
	highlighted := aSourceModel isHighlighted: aTuple.
	highlighted ifTrue: [ cell addCssClass: 'dsm-highlighted' ].
	cell argsAt: 'fill' put: '#' , (highlighted
			 ifTrue: [ aDSMModel showSCCColorForTuple: aTuple ]
			 ifFalse: [ aDSMModel colorForTuple: aTuple ]) asHexString.
	cell argsAt: 'title' put: (self titleOf: aTuple weight: weight in: aDSMModel).
	^ cell
]

{ #category : 'building' }
GLSPDSMGModelFactory >> cellIdFrom: aColumnEntity to: aRowEntity [

	^ 'c' , aColumnEntity mooseID printString , '_' , aRowEntity mooseID printString
]

{ #category : 'layout' }
GLSPDSMGModelFactory >> cellSize [
	"Room for a 4 digit weight"

	^ 48 @ 30
]

{ #category : 'layout' }
GLSPDSMGModelFactory >> charWidth [
	"Average width of a character of the labels (13px font): the server does no text layout"

	^ 7.5
]

{ #category : 'building' }
GLSPDSMGModelFactory >> columnHeaderFor: aNode at: aPoint height: aNumber [

	^ self
		  node: 'x' , aNode model mooseID printString
		  type: 'dsm-column-header'
		  at: aPoint
		  size: self cellSize x @ aNumber
		  label: aNode model name
		  labelType: 'dsm-column-label'
]

{ #category : 'building' }
GLSPDSMGModelFactory >> createGModel: aModelState [

	| source dsm columns rows root cellOrigin |
	source := aModelState sourceModel.
	dsm := source ifNotNil: [ source dsmModel ].
	root := GLSPGModelRoot new
		        id: 'dsm';
		        type: 'graph';
		        yourself.
	dsm ifNil: [ ^ root ].
	columns := dsm orderedNodesX.
	rows := dsm orderedNodesY.
	(columns isEmpty or: [ rows isEmpty ]) ifTrue: [ ^ root ].
	"Row headers on the left, column headers (names written upwards) on top"
	cellOrigin := self margin + ((self headerBreadthFor: rows) @ (self headerBreadthFor: columns)).
	columns doWithIndex: [ :column :i |
			root add:
				(self
					 columnHeaderFor: column
					 at: cellOrigin x + (i - 1 * self cellSize x) @ self margin y
					 height: cellOrigin y - self margin y) ].
	rows doWithIndex: [ :row :j |
			root add:
				(self rowHeaderFor: row at: self margin x @ (cellOrigin y + (j - 1 * self cellSize y)) width: cellOrigin x - self margin x) ].
	rows doWithIndex: [ :row :j |
			columns doWithIndex: [ :column :i |
				root add: (self cellFor: column -> row of: source at: cellOrigin + (i - 1 @ (j - 1) * self cellSize)) ] ].
	^ root
]

{ #category : 'layout' }
GLSPDSMGModelFactory >> headerBreadthFor: aCollectionOfNodes [
	"Room for the longest name"

	| longest |
	longest := aCollectionOfNodes inject: 0 into: [ :max :each | max max: each model name size ].
	^ (longest * self charWidth) rounded + 16
]

{ #category : 'building' }
GLSPDSMGModelFactory >> kindOf: aTuple in: aDSMModel [
	"As MiDSMBrowserModel>>colorForTuple: decides"

	(aDSMModel isDiagonal: aTuple) ifTrue: [ ^ 'diagonal' ].
	(aDSMModel isDependency: aTuple) ifFalse: [ ^ 'empty' ].
	(aDSMModel isCycle: aTuple) ifTrue: [ ^ 'cycle' ].
	^ 'dependency'
]

{ #category : 'layout' }
GLSPDSMGModelFactory >> margin [

	^ 20 @ 20
]

{ #category : 'building' }
GLSPDSMGModelFactory >> node: anId type: aType at: aPoint size: aSize label: aString labelType: aLabelType [

	^ GLSPGNode new
		  id: anId;
		  type: aType;
		  position: aPoint;
		  size: aSize;
		  add: (GLSPGLabel new
				   id: anId , '_label';
				   type: aLabelType;
				   text: aString;
				   yourself);
		  yourself
]

{ #category : 'building' }
GLSPDSMGModelFactory >> rowHeaderFor: aNode at: aPoint width: aNumber [

	^ self
		  node: 'y' , aNode model mooseID printString
		  type: 'dsm-row-header'
		  at: aPoint
		  size: aNumber @ self cellSize y
		  label: aNode model name
		  labelType: 'dsm-row-label'
]

{ #category : 'building' }
GLSPDSMGModelFactory >> titleOf: aTuple weight: aNumber in: aDSMModel [

	^ String streamContents: [ :s |
			  s << aTuple key model name << ' -> ' << aTuple value model name << ': ' << aNumber printString << ' dependenc'
			  << (aNumber = 1
					   ifTrue: [ 'y' ]
					   ifFalse: [ 'ies' ]).
			  (self kindOf: aTuple in: aDSMModel) = 'cycle' ifTrue: [ s << ' (in a cycle)' ] ]
]
