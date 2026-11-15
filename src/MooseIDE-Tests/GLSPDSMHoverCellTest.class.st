"
Hovering a cell of the GLSP DSM (GLSPDSMHoverCellAction, handled by GLSPDSMHoverCellActionHandler): the cells of its SCC become red.
"
Class {
	#name : 'GLSPDSMHoverCellTest',
	#superclass : 'TestCase',
	#instVars : [
		'famixModel',
		'class1',
		'class2',
		'class3',
		'dsm',
		'session',
		'factory'
	],
	#category : 'MooseIDE-Tests-Browsers',
	#package : 'MooseIDE-Tests',
	#tag : 'Browsers'
}

{ #category : 'running' }
GLSPDSMHoverCellTest >> fillFrom: anEntity to: anotherEntity [

	^ (session modelState root children detect: [ :each | each id = (factory cellIdFrom: anEntity to: anotherEntity) ]) args at:
		  'fill'
]

{ #category : 'running' }
GLSPDSMHoverCellTest >> hex: aColor [

	^ '#' , aColor asHexString
]

{ #category : 'running' }
GLSPDSMHoverCellTest >> hover: aCellId [

	^ GLSPDSMHoverCellActionHandler new
		  execute: (GLSPDSMHoverCellAction new
				   cellId: aCellId;
				   yourself)
		  in: session
]

{ #category : 'running' }
GLSPDSMHoverCellTest >> invocationFrom: aClass to: anotherClass [

	| sender receiver |
	sender := (famixModel newMethodNamed: 'from' , aClass name) parentType: aClass.
	receiver := (famixModel newMethodNamed: 'to' , anotherClass name) parentType: anotherClass.
	famixModel newInvocation
		sender: sender;
		candidates: { receiver }
]

{ #category : 'running' }
GLSPDSMHoverCellTest >> setUp [
	"Class1 and Class2 depend on each other (an SCC); Class3 depends on Class1, outside the SCC"

	super setUp.
	famixModel := FamixJavaModel new.
	class1 := famixModel newClassNamed: 'Class1'.
	class2 := famixModel newClassNamed: 'Class2'.
	class3 := famixModel newClassNamed: 'Class3'.
	self invocationFrom: class1 to: class2.
	self invocationFrom: class2 to: class1.
	self invocationFrom: class3 to: class1.
	dsm := MiStandaloneDSMModel on: {
			       class1.
			       class2.
			       class3 }.
	factory := GLSPDSMGModelFactory new.
	session := (GLSPDSMDiagramModule new
		            dsmModel: dsm;
		            yourself) createClientSession: 'test' server: nil clientActionKinds: #(  ).
	GLSPRequestModelActionHandler new execute: GLSPRequestModelAction new in: session
]

{ #category : 'tests' }
GLSPDSMHoverCellTest >> testCellsOfAnSCCArePinkWhenNotHovered [

	self assert: (self fillFrom: class1 to: class2) equals: (self hex: dsm sccColor).
	self assert: (self fillFrom: class2 to: class1) equals: (self hex: dsm sccColor)
]

{ #category : 'tests' }
GLSPDSMHoverCellTest >> testHoveringACellOfAnSCCMakesAllItsCellsRed [

	| actions |
	actions := self hover: (factory cellIdFrom: class1 to: class2).
	self assert: actions size equals: 1.
	self assert: actions first kind equals: 'updateModel'.
	self assert: (self fillFrom: class1 to: class2) equals: (self hex: dsm showSCCColor).
	self assert: (self fillFrom: class2 to: class1) equals: (self hex: dsm showSCCColor).
	"Outside the SCC"
	self assert: (self fillFrom: class3 to: class1) equals: (self hex: dsm dependencyColor)
]

{ #category : 'tests' }
GLSPDSMHoverCellTest >> testHoveringACellOutsideAnSCCChangesNothing [

	self assert: (self hover: (factory cellIdFrom: class3 to: class1)) isEmpty.
	self assert: (self hover: (factory cellIdFrom: class3 to: class3)) isEmpty.
	self assert: (self fillFrom: class1 to: class2) equals: (self hex: dsm sccColor)
]

{ #category : 'tests' }
GLSPDSMHoverCellTest >> testHoveringAnotherCellOfTheSameSCCSendsNothing [

	self hover: (factory cellIdFrom: class1 to: class2).
	self assert: (self hover: (factory cellIdFrom: class2 to: class1)) isEmpty
]

{ #category : 'tests' }
GLSPDSMHoverCellTest >> testLeavingTheCellMakesThemPinkAgain [

	self hover: (factory cellIdFrom: class1 to: class2).
	self assert: (self hover: nil) size equals: 1.
	self assert: (self fillFrom: class1 to: class2) equals: (self hex: dsm sccColor)
]

{ #category : 'tests' }
GLSPDSMHoverCellTest >> testTheActionIsReadFromJSON [

	| action |
	action := GLSPAction fromJSON: (Dictionary new
			           at: 'kind' put: 'dsmHoverCell';
			           at: 'cellId' put: 'c1_2';
			           yourself).
	self assert: action class equals: GLSPDSMHoverCellAction.
	self assert: action cellId equals: 'c1_2'
]

{ #category : 'tests' }
GLSPDSMHoverCellTest >> testTheServerAnnouncesTheHoverAction [

	self assert: (GLSPDSMDiagramModule new handledActionKinds includes: GLSPDSMHoverCellAction kind)
]
