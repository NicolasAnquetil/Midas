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
	dsm := GLSPDSMBrowser modelOn: {
			       class1.
			       class2.
			       class3 }.
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
GLSPDSMVisualizationTest >> testADependencyCellShowsItsWeightAndColor [
	| cell |
	cell := self cellFrom: class1 to: class2.
	self assert: (self textOf: cell) equals: '1'.
	self assert: (cell cssClasses includes: 'dsm-dependency').
	self assert: (cell args at: 'fill') equals: '#' , dsm dependencyColor asHexString
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
GLSPDSMVisualizationTest >> testOneCellPerPairAndOneHeaderPerEntity [
	self assert: (self elementsOfType: 'dsm-cell') size equals: 9.
	self assert: (self elementsOfType: 'dsm-column-header') size equals: 3.
	self assert: (self elementsOfType: 'dsm-row-header') size equals: 3
]

{ #category : 'running' }
GLSPDSMVisualizationTest >> textOf: anElement [
	^ anElement children first text
]
