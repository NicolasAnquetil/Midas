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

{ #category : 'helpers' }
GLSPArchitecturalMapBrowserTest >> move: aPackage to: aPoint [
	"The client moved the node of aPackage (standard GLSP operation changeBounds)"

	^ GLSPArchitecturalMapChangeBoundsHandler new
		  execute: (GLSPChangeBoundsOperation new
				   newBounds: { (Dictionary new
						    at: 'elementId' put: (self nodeIdOf: aPackage);
						    at: 'newPosition' put: (Dictionary new
								     at: 'x' put: aPoint x;
								     at: 'y' put: aPoint y;
								     yourself);
						    yourself) };
				   yourself)
		  in: session
]

{ #category : 'helpers' }
GLSPArchitecturalMapBrowserTest >> nodeIdOf: aPackage [

	^ GLSPArchitecturalMapVisualization new idFor: aPackage
]

{ #category : 'helpers' }
GLSPArchitecturalMapBrowserTest >> positionOf: aPackage [

	^ (session modelState root children detect: [ :each | each id = (self nodeIdOf: aPackage) ]) position
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
GLSPArchitecturalMapBrowserTest >> testAChangeOfTheMapLaysOutTheNodesAgain [
	"As in Roassal: a new configuration draws a new map"

	| before |
	before := self positionOf: package1.
	self move: package1 to: 300 @ 400.
	mapModel updateFromConfiguration: mapModel currentConfiguration.
	self assert: (self positionOf: package1) equals: before
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
GLSPArchitecturalMapBrowserTest >> testAMoveIsNotRecordedForUndo [
	"An undo command copies the source model (veryDeepCopy): here the browser, the Moose model behind it..."

	self move: package1 to: 300 @ 400.
	self deny: session commandStack canUndo
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testMovedNodesStayInPlaceWhenTheModelIsDrawnAgain [

	self move: package1 to: 300 @ 400.
	session updateGModel.
	self assert: (self positionOf: package1) equals: 300 @ 400
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testMovingANodeKeepsItWhereTheUserPutIt [

	| actions |
	actions := self move: package1 to: 300 @ 400.
	self assert: (self positionOf: package1) equals: 300 @ 400.
	self assert: actions size equals: 1.
	self assert: actions first kind equals: 'updateModel'
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testMovingANodeLeavesTheOthersInPlace [

	| before |
	before := self positionOf: package2.
	self move: package1 to: 300 @ 400.
	self assert: (self positionOf: package2) equals: before
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
GLSPArchitecturalMapBrowserTest >> testTheNodesCanOnlyBeMoved [
	"Type hints: the server tells the client what the user can do with each element type"

	| module node dependency |
	module := GLSPArchitecturalMapDiagramModule new.
	node := module shapeTypeHints detect: [ :each | each elementTypeId = 'archmap-node' ].
	self assert: node repositionable.
	self deny: node resizable.
	self deny: node deletable.
	self deny: node reparentable.
	dependency := module edgeTypeHints detect: [ :each | each elementTypeId = 'archmap-dependency' ].
	self deny: dependency repositionable.
	self deny: dependency deletable.
	self deny: dependency routable
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testTheServerAnnouncesTheMove [

	self assert: (GLSPArchitecturalMapDiagramModule new handledActionKinds includes: GLSPChangeBoundsOperation kind)
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
