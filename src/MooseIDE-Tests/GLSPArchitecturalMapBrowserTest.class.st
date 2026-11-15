"
GLSPArchitecturalMapBrowser: the browser of an architectural map shown by a GLSP client. It is the browser of the MiArchitecturalMapModel; a change of the map is sent to the client.
"
Class {
	#name : 'GLSPArchitecturalMapBrowserTest',
	#superclass : 'TestCase',
	#instVars : [
		'famixModel',
		'package1',
		'package2',
		'mapModel',
		'session',
		'server'
	],
	#category : 'MooseIDE-Tests-Browsers',
	#package : 'MooseIDE-Tests',
	#tag : 'Browsers'
}

{ #category : 'running' }
GLSPArchitecturalMapBrowserTest >> elementsOfType: aType in: aRoot [

	^ aRoot children select: [ :each | each type = aType ]
]

{ #category : 'running' }
GLSPArchitecturalMapBrowserTest >> setUp [
	"Package1 depends on Package2 (C1>>a invokes C2>>b)"

	| class1 class2 |
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
	mapModel := GLSPArchitecturalMapBrowser modelOn: famixModel allModelPackages.
	server := GLSPTestServer new.
	session := (GLSPArchitecturalMapDiagramModule new
		            model: mapModel;
		            yourself) createClientSession: 'test' server: server clientActionKinds: #(  ).
	GLSPRequestModelActionHandler new execute: GLSPRequestModelAction new in: session
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testAChangeOfTheMapIsSentToTheClient [

	mapModel updateFromConfiguration: mapModel currentConfiguration.
	self assert: server sentActions size equals: 1.
	self assert: server sentActions first kind equals: 'updateModel'.
	self assert: (self elementsOfType: 'archmap-node' in: server sentActions first newRoot) size equals: 2
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testAModelIsBuiltWithABrowserWithoutClient [

	| model |
	model := GLSPArchitecturalMapBrowser modelOn: famixModel allModelPackages.
	self assert: model class equals: MiArchitecturalMapModel.
	self assert: model browser class equals: GLSPArchitecturalMapBrowser.
	self assert: model browser session isNil.
	self assert: model rootNodes size equals: 2
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testTheBrowserOfTheSessionIsSetInTheModel [

	self assert: mapModel browser identicalTo: session modelState sourceModel.
	self assert: mapModel browser class equals: GLSPArchitecturalMapBrowser
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testTheMapShowsTheRootsAndTheirDependencies [

	| root |
	root := session modelState root.
	self assert: (self elementsOfType: 'archmap-node' in: root) size equals: 2.
	self assert: (self elementsOfType: 'archmap-dependency' in: root) size equals: 1
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testWhenTheClientHasGoneTheModelGetsABrowserWithoutClient [

	server close.
	mapModel updateFromConfiguration: mapModel currentConfiguration.
	self assert: mapModel browser class equals: GLSPArchitecturalMapBrowser.
	self assert: mapModel browser session isNil.
	"The model works with it"
	mapModel updateFromConfiguration: mapModel currentConfiguration.
	self assert: mapModel rootNodes size equals: 2
]
