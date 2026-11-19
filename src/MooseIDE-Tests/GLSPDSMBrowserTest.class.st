"
GLSPDSMBrowser: the browser of a DSM shown by a GLSP client. Hovering a cell (GLSPDSMHoverCellAction) shows the cells of its SCC red; a change of the DSM model is sent to the client.
"
Class {
	#name : 'GLSPDSMBrowserTest',
	#superclass : 'TestCase',
	#instVars : [
		'famixModel',
		'class1',
		'class2',
		'class3',
		'dsm',
		'session',
		'server',
		'visualization'
	],
	#category : 'MooseIDE-Tests-Browsers',
	#package : 'MooseIDE-Tests',
	#tag : 'Browsers'
}

{ #category : 'running' }
GLSPDSMBrowserTest >> hover: aCellId [

	^ GLSPDSMHoverCellActionHandler new
		  execute: (GLSPDSMHoverCellAction new
				   cellId: aCellId;
				   yourself)
		  in: session
]

{ #category : 'running' }
GLSPDSMBrowserTest >> invocationFrom: aClass to: anotherClass [

	| sender receiver |
	sender := (famixModel newMethodNamed: 'from' , aClass name) parentType: aClass.
	receiver := (famixModel newMethodNamed: 'to' , anotherClass name) parentType: anotherClass.
	famixModel newInvocation
		sender: sender;
		candidates: { receiver }
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> isHighlightedFrom: anEntity to: anotherEntity [
	"Shown red by the client: the cell has the class dsm-highlighted"

	^ (session modelState root children detect: [ :each | each id = (visualization cellIdFrom: anEntity to: anotherEntity) ])
		  cssClasses includes: 'dsm-highlighted'
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> outlines [

	^ session modelState root children select: [ :each | each cssClasses includes: 'dsm-hovered-line' ]
]

{ #category : 'running' }
GLSPDSMBrowserTest >> setUp [
	"Class1 and Class2 depend on each other (an SCC); Class3 depends on Class1, outside the SCC"

	super setUp.
	famixModel := FamixJavaModel new.
	class1 := famixModel newClassNamed: 'Class1'.
	class2 := famixModel newClassNamed: 'Class2'.
	class3 := famixModel newClassNamed: 'Class3'.
	self invocationFrom: class1 to: class2.
	self invocationFrom: class2 to: class1.
	self invocationFrom: class3 to: class1.
	visualization := GLSPDSMVisualization new.
	server := GLSPTestServer new.
	session := (GLSPDSMBrowser diagramModuleOn: {
			            class1.
			            class2.
			            class3 }) createClientSession: 'test' server: server clientActionKinds: #(  ).
	dsm := session modelState sourceModel model.
	GLSPRequestModelActionHandler new execute: GLSPRequestModelAction new in: session
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testABrowserBuildsItsModelBeforeHavingASession [

	| browser |
	browser := GLSPDSMBrowser on: {
			           class1.
			           class2.
			           class3 }.
	self assert: browser model class equals: MiDSMBrowserModel.
	self assert: browser model browser identicalTo: browser.
	self assert: browser session isNil.
	self assert: browser model orderedNodesX size equals: 3
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testAChangeOfTheMatrixIsSentToTheClient [

	| update |
	dsm followEntity: {
			class1.
			class2 }.
	self assert: server sentActions size equals: 1.
	update := server sentActions first.
	self assert: update kind equals: 'updateModel'.
	self assert: (update newRoot children select: [ :each | each type = 'dsm-cell' ]) size equals: 4
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testCellsOfAnSCCArePinkWhenNotHovered [

	self deny: (self isHighlightedFrom: class1 to: class2).
	self deny: (self isHighlightedFrom: class2 to: class1)
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testHoveringACellOfAnSCCMakesAllItsCellsRed [

	| actions |
	actions := self hover: (visualization cellIdFrom: class1 to: class2).
	self assert: actions size equals: 1.
	self assert: actions first kind equals: 'updateModel'.
	self assert: (self isHighlightedFrom: class1 to: class2).
	self assert: (self isHighlightedFrom: class2 to: class1).
	"Outside the SCC"
	self deny: (self isHighlightedFrom: class3 to: class1)
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testHoveringACellOutlinesItsRowAndColumn [

	self hover: (visualization cellIdFrom: class3 to: class1).
	self assert: (self outlines collect: [ :each | each id ]) asSet equals: #( 'dsm-hovered-column' 'dsm-hovered-row' ) asSet
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testHoveringACellOutsideAnSCCKeepsTheSCCPink [

	self assert: (self hover: (visualization cellIdFrom: class3 to: class1)) size equals: 1.
	self deny: (self isHighlightedFrom: class1 to: class2)
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testHoveringAnotherCellOfTheSameSCCMovesTheOutlines [

	self hover: (visualization cellIdFrom: class1 to: class2).
	self assert: (self hover: (visualization cellIdFrom: class2 to: class1)) size equals: 1.
	self assert: (self isHighlightedFrom: class1 to: class2)
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testHoveringTheSameCellAgainSendsNothing [

	self hover: (visualization cellIdFrom: class1 to: class2).
	self assert: (self hover: (visualization cellIdFrom: class1 to: class2)) isEmpty
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testLeavingTheCellMakesThemPinkAgain [

	self hover: (visualization cellIdFrom: class1 to: class2).
	self assert: (self hover: nil) size equals: 1.
	self deny: (self isHighlightedFrom: class1 to: class2)
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testLeavingTheMatrixRemovesTheOutlines [

	self hover: (visualization cellIdFrom: class3 to: class1).
	self assert: (self hover: nil) size equals: 1.
	self assert: self outlines isEmpty
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testTheActionIsReadFromJSON [

	| action |
	action := GLSPAction fromJSON: (Dictionary new
			           at: 'kind' put: 'dsmHoverCell';
			           at: 'cellId' put: 'c1_2';
			           yourself).
	self assert: action class equals: GLSPDSMHoverCellAction.
	self assert: action cellId equals: 'c1_2'
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testTheBrowserOfTheSessionIsSetInTheModel [

	self assert: dsm browser identicalTo: session modelState sourceModel.
	self assert: dsm browser class equals: GLSPDSMBrowser
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testTheHoverIsHandledByTheBrowser [

	| browser |
	browser := session modelState sourceModel.
	self hover: (visualization cellIdFrom: class1 to: class2).
	self assert: (browser isHighlighted: (browser tupleWithCellId: (visualization cellIdFrom: class2 to: class1)))
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testTheOutlinesAreNotAnimated [
	"Without animate: false, the client slides the outlines from the previous cell to the new one"

	self deny: (self hover: (visualization cellIdFrom: class3 to: class1)) first animate
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testTheServerAnnouncesTheHoverAction [

	self assert: ((GLSPDSMBrowser diagramModuleOn: #(  )) handledActionKinds includes: GLSPDSMHoverCellAction kind)
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testWhenTheClientHasGoneTheBrowserHasNoSession [

	| browser |
	browser := dsm browser.
	server close.
	dsm followEntity: {
			class1.
			class2 }.
	self assert: dsm browser identicalTo: browser.
	self assert: browser session isNil.
	"The model works with it, nothing is sent"
	dsm followEntity: { class1 }.
	self assert: dsm orderedNodesX size equals: 1
]
