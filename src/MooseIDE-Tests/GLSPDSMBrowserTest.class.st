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
GLSPDSMBrowserTest >> fillFrom: anEntity to: anotherEntity [

	^ (session modelState root children detect: [ :each | each id = (visualization cellIdFrom: anEntity to: anotherEntity) ]) args at:
		  'fill'
]

{ #category : 'running' }
GLSPDSMBrowserTest >> hex: aColor [

	^ '#' , aColor asHexString
]

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
	dsm := GLSPDSMBrowser dsmModelOn: {
			       class1.
			       class2.
			       class3 }.
	visualization := GLSPDSMVisualization new.
	server := GLSPDSMTestServer new.
	session := (GLSPDSMDiagramModule new
		            dsmModel: dsm;
		            yourself) createClientSession: 'test' server: server clientActionKinds: #(  ).
	GLSPRequestModelActionHandler new execute: GLSPRequestModelAction new in: session
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
GLSPDSMBrowserTest >> testAModelIsBuiltWithABrowserWithoutClient [

	| model |
	model := GLSPDSMBrowser dsmModelOn: {
			         class1.
			         class2.
			         class3 }.
	self assert: model class equals: MiDSMBrowserModel.
	self assert: model browser class equals: GLSPDSMBrowser.
	self assert: model browser session isNil.
	self assert: model orderedNodesX size equals: 3
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testCellsOfAnSCCArePinkWhenNotHovered [

	self assert: (self fillFrom: class1 to: class2) equals: (self hex: dsm sccColor).
	self assert: (self fillFrom: class2 to: class1) equals: (self hex: dsm sccColor)
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testHoveringACellOfAnSCCMakesAllItsCellsRed [

	| actions |
	actions := self hover: (visualization cellIdFrom: class1 to: class2).
	self assert: actions size equals: 1.
	self assert: actions first kind equals: 'updateModel'.
	self assert: (self fillFrom: class1 to: class2) equals: (self hex: dsm showSCCColor).
	self assert: (self fillFrom: class2 to: class1) equals: (self hex: dsm showSCCColor).
	"Outside the SCC"
	self assert: (self fillFrom: class3 to: class1) equals: (self hex: dsm dependencyColor)
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testHoveringACellOutsideAnSCCChangesNothing [

	self assert: (self hover: (visualization cellIdFrom: class3 to: class1)) isEmpty.
	self assert: (self hover: (visualization cellIdFrom: class3 to: class3)) isEmpty.
	self assert: (self fillFrom: class1 to: class2) equals: (self hex: dsm sccColor)
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testHoveringAnotherCellOfTheSameSCCSendsNothing [

	self hover: (visualization cellIdFrom: class1 to: class2).
	self assert: (self hover: (visualization cellIdFrom: class2 to: class1)) isEmpty
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testLeavingTheCellMakesThemPinkAgain [

	self hover: (visualization cellIdFrom: class1 to: class2).
	self assert: (self hover: nil) size equals: 1.
	self assert: (self fillFrom: class1 to: class2) equals: (self hex: dsm sccColor)
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
GLSPDSMBrowserTest >> testTheServerAnnouncesTheHoverAction [

	self assert: (GLSPDSMDiagramModule new handledActionKinds includes: GLSPDSMHoverCellAction kind)
]

{ #category : 'tests' }
GLSPDSMBrowserTest >> testWhenTheClientHasGoneTheModelGetsABrowserWithoutClient [

	server close.
	dsm followEntity: {
			class1.
			class2 }.
	self assert: dsm browser class equals: GLSPDSMBrowser.
	self assert: dsm browser session isNil.
	"The model works with it"
	dsm followEntity: { class1 }.
	self assert: dsm orderedNodesX size equals: 1
]
