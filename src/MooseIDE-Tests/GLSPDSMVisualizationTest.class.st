"
Tests of GLSPDSMVisualization: the matrix sent to a GLSP client for a DSM.
"
Class {
	#name : 'GLSPDSMVisualizationTest',
	#superclass : 'TestCase',
	#instVars : [
		'famixModel',
		'class1',
		'class2',
		'class3',
		'dsm',
		'gmodel',
		'visualization'
	],
	#category : 'MooseIDE-Tests-Browsers',
	#package : 'MooseIDE-Tests',
	#tag : 'Browsers'
}

{ #category : 'running' }
GLSPDSMVisualizationTest >> cellFrom: anEntity to: anotherEntity [
	^ gmodel children detect: [ :each | each id = (visualization cellIdFrom: anEntity to: anotherEntity) ]
]

{ #category : 'running' }
GLSPDSMVisualizationTest >> elementsOfType: aType [
	^ gmodel children select: [ :each | each type = aType ]
]

{ #category : 'running' }
GLSPDSMVisualizationTest >> setUp [
	"Class1 depends on Class2 (mth1 invokes mth2); Class3 depends on nothing"

	| mth1 mth2 |
	super setUp.
	famixModel := FamixJavaModel new.
	class1 := famixModel newClassNamed: 'Class1'.
	class2 := famixModel newClassNamed: 'Class2'.
	class3 := famixModel newClassNamed: 'Class3'.
	mth1 := (famixModel newMethodNamed: 'mth1') parentType: class1.
	mth2 := (famixModel newMethodNamed: 'mth2') parentType: class2.
	famixModel newInvocation
		sender: mth1;
		candidates: { mth2 }.
	dsm := (GLSPDSMBrowser on: {
			        class1.
			        class2.
			        class3 }) model.
	visualization := GLSPDSMVisualization new.
	gmodel := visualization createGModel: (GLSPModelState new
			           sourceModel: dsm browser;
			           yourself)
]

{ #category : 'tests' }
GLSPDSMVisualizationTest >> testACellTellsWhatItIsInItsTooltip [
	self assert: (((self cellFrom: class1 to: class2) args at: 'title') includesSubstring: 'Class1 -> Class2')
]

{ #category : 'tests' }
GLSPDSMVisualizationTest >> testADependencyCellShowsItsWeightAndKind [
	"The client gives the color from the kind (CSS class), the server sends no color"

	| cell |
	cell := self cellFrom: class1 to: class2.
	self assert: (self textOf: cell) equals: '1'.
	self assert: (cell cssClasses includes: 'dsm-dependency').
	self deny: (cell args includesKey: 'fill')
]

{ #category : 'tests' }
GLSPDSMVisualizationTest >> testCellsAreLaidOutAsAMatrix [
	| a b c |
	a := self cellFrom: class1 to: class2.
	b := self cellFrom: class3 to: class2.
	c := self cellFrom: class1 to: class3.
	"Same row: same y; same column: same x"
	self assert: a position y equals: b position y.
	self assert: a position x equals: c position x.
	self assert: a size equals: visualization cellSize.
	self assert: (a position x - b position x) abs \\ visualization cellSize x equals: 0
]

{ #category : 'tests' }
GLSPDSMVisualizationTest >> testEmptyAndDiagonalCells [
	| empty diagonal |
	empty := self cellFrom: class2 to: class1.
	self assert: (self textOf: empty) equals: ''.
	self assert: (empty cssClasses includes: 'dsm-empty').
	diagonal := self cellFrom: class3 to: class3.
	self assert: (diagonal cssClasses includes: 'dsm-diagonal')
]

{ #category : 'tests' }
GLSPDSMVisualizationTest >> testHeadersNameTheEntitiesInTheOrderOfTheModel [
	self
		assert: ((self elementsOfType: 'dsm-column-header') collect: [ :each | self textOf: each ]) asArray
		equals: (dsm orderedNodesX collect: [ :each | each model name ]) asArray.
	self
		assert: ((self elementsOfType: 'dsm-row-header') collect: [ :each | self textOf: each ]) asArray
		equals: (dsm orderedNodesY collect: [ :each | each model name ]) asArray
]

{ #category : 'tests' }
GLSPDSMVisualizationTest >> testNoOutlineWhenNoCellIsHovered [

	self assert: (gmodel children noneSatisfy: [ :each | each cssClasses includes: 'dsm-hovered-line' ])
]

{ #category : 'tests' }
GLSPDSMVisualizationTest >> testOneCellPerPairAndOneHeaderPerEntity [
	self assert: (self elementsOfType: 'dsm-cell') size equals: 9.
	self assert: (self elementsOfType: 'dsm-column-header') size equals: 3.
	self assert: (self elementsOfType: 'dsm-row-header') size equals: 3
]

{ #category : 'tests' }
GLSPDSMVisualizationTest >> testTheHoveredCellOutlinesItsColumnAndRow [

	| cell column row |
	dsm browser hover: (dsm browser tupleWithCellId: (visualization cellIdFrom: class2 to: class3)).
	gmodel := visualization createGModel: (GLSPModelState new
			           sourceModel: dsm browser;
			           yourself).
	cell := self cellFrom: class2 to: class3.
	column := gmodel children detect: [ :each | each id = 'dsm-hovered-column' ].
	row := gmodel children detect: [ :each | each id = 'dsm-hovered-row' ].
	"The column: as wide as a cell, from the top of the first row to the bottom of the last one"
	self assert: column position equals: cell position x @ (self cellFrom: class2 to: class1) position y.
	self assert: column size equals: visualization cellSize x @ (visualization cellSize y * 3).
	"The row: as high as a cell, from the left of the first column to the right of the last one"
	self assert: row position equals: (self cellFrom: class1 to: class3) position x @ cell position y.
	self assert: row size equals: visualization cellSize x * 3 @ visualization cellSize y.
	"Drawn over the cells"
	self assert: (gmodel children indexOf: row) > (gmodel children indexOf: cell)
]

{ #category : 'tests' }
GLSPDSMVisualizationTest >> testTheOutlinesAreStandardRectangles [
	"Each client draws them its own way (a thick border in the browser client's CSS)"

	| outline |
	outline := visualization outline: 'x' at: 0 @ 0 size: 48 @ 90.
	self assert: outline type equals: 'node:rectangle'.
	self assert: (outline cssClasses includes: 'dsm-hovered-line').
	self assert: outline children isEmpty
]

{ #category : 'running' }
GLSPDSMVisualizationTest >> textOf: anElement [
	^ anElement children first text
]
