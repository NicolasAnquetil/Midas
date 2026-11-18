"
GLSPMooseDiagramModule: the architectural map and the DSM served by one GLSP server (one port), each client choosing its diagram type.
"
Class {
	#name : 'GLSPMooseDiagramModuleTest',
	#superclass : 'TestCase',
	#instVars : [
		'server'
	],
	#category : 'MooseIDE-Tests-Browsers',
	#package : 'MooseIDE-Tests',
	#tag : 'Browsers'
}

{ #category : 'running' }
GLSPMooseDiagramModuleTest >> setUp [
	"One server with both diagrams of two packages, Package1 depending on Package2"

	| famixModel package1 package2 class1 class2 |
	super setUp.
	famixModel := FamixJavaModel new.
	package1 := famixModel newPackageNamed: 'Package1'.
	package2 := famixModel newPackageNamed: 'Package2'.
	class1 := (famixModel newClassNamed: 'C1')
		          parentPackage: package1;
		          yourself.
	class2 := (famixModel newClassNamed: 'C2')
		          parentPackage: package2;
		          yourself.
	famixModel newInvocation
		sender: ((famixModel newMethodNamed: 'a') parentType: class1);
		candidates: { ((famixModel newMethodNamed: 'b') parentType: class2) }.
	server := GLSPServer new.
	{
		(GLSPArchitecturalMapDiagramModule on: famixModel allModelPackages).
		(GLSPDSMDiagramModule on: famixModel allModelPackages) } do: [ :each | server registerDiagramModule: each ]
]

{ #category : 'tests' }
GLSPMooseDiagramModuleTest >> testEachDiagramTypeGetsItsBrowser [

	self
		assert:
			((server diagramModules at: 'archmap-diagram') createClientSession: 's1' server: server clientActionKinds: #(  )) modelState
				sourceModel class
		equals: GLSPArchitecturalMapBrowser.
	self
		assert:
			((server diagramModules at: 'dsm-diagram') createClientSession: 's2' server: server clientActionKinds: #(  )) modelState
				sourceModel class
		equals: GLSPDSMBrowser
]

{ #category : 'tests' }
GLSPMooseDiagramModuleTest >> testEachSessionHasItsOwnModel [
	"As each MooseIDE browser in Pharo has its own model"

	| module first second |
	module := server diagramModules at: 'dsm-diagram'.
	first := (module createClientSession: 's1' server: server clientActionKinds: #(  )) modelState sourceModel.
	second := (module createClientSession: 's2' server: server clientActionKinds: #(  )) modelState sourceModel.
	self assert: first model class equals: MiDSMBrowserModel.
	self deny: first model identicalTo: second model.
	self assert: first model browser identicalTo: first.
	self assert: second model browser identicalTo: second.
	self assert: first model orderedNodesX size equals: 2
]

{ #category : 'tests' }
GLSPMooseDiagramModuleTest >> testOneServerAnnouncesBothDiagramTypes [

	| actions |
	actions := server serverActions.
	self assertCollection: actions keys hasSameElements: #( 'archmap-diagram' 'dsm-diagram' ).
	self assert: ((actions at: 'dsm-diagram') includes: GLSPDSMHoverCellAction kind).
	self deny: ((actions at: 'archmap-diagram') includes: GLSPDSMHoverCellAction kind)
]

{ #category : 'tests' }
GLSPMooseDiagramModuleTest >> testTheStorageIsReadOnly [

	self should: [ GLSPMooseSourceModelStorage new saveSourceModel: GLSPModelState new to: 'file:///x' ] raise: GLSPServerError
]
