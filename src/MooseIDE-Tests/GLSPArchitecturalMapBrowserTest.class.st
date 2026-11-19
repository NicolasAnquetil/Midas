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
GLSPArchitecturalMapBrowserTest >> handle: aSelectionAction [
	"The client tells the server what the user selected"

	^ GLSPArchitecturalMapSelectHandler new execute: aSelectionAction in: session
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
GLSPArchitecturalMapBrowserTest >> nodeOf: aPackage [

	^ session modelState root children detect: [ :each | each id = (self nodeIdOf: aPackage) ]
]

{ #category : 'helpers' }
GLSPArchitecturalMapBrowserTest >> positionOf: aPackage [

	^ (session modelState root children detect: [ :each | each id = (self nodeIdOf: aPackage) ]) position
]

{ #category : 'helpers' }
GLSPArchitecturalMapBrowserTest >> select: aCollectionOfPackages [
	"The user added the nodes of these packages to the selection (Ctrl/Cmd+click)"

	^ self handle: (GLSPSelectAction new
			   selectedElementsIDs: (aCollectionOfPackages collect: [ :each | self nodeIdOf: each ]);
			   yourself)
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
	server := GLSPTestServer new.
	session := (GLSPArchitecturalMapBrowser diagramModuleOn: famixModel allModelPackages)
		           createClientSession: 'test'
		           server: server
		           clientActionKinds: #(  ).
	mapModel := session modelState sourceModel model.
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
GLSPArchitecturalMapBrowserTest >> testAMoveIsNotRecordedForUndo [
	"An undo command copies the source model (veryDeepCopy): here the browser, the Moose model behind it..."

	self move: package1 to: 300 @ 400.
	self deny: session commandStack canUndo
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testDeselectAllFirst [
	"A click on a node: it alone is selected"

	self select: { package1 }.
	self handle: (GLSPSelectAction new
			 selectedElementsIDs: { (self nodeIdOf: package2) };
			 deselectAll: true;
			 yourself).
	self assert: mapModel selectedEntities asArray equals: { package2 }
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testDeselectingANode [

	self select: {
			package1.
			package2 }.
	self handle: (GLSPSelectAction new
			 deselectedElementsIDs: { (self nodeIdOf: package1) };
			 yourself).
	self assert: mapModel selectedEntities asArray equals: { package2 }
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
GLSPArchitecturalMapBrowserTest >> testNewEntitiesClearTheSelection [

	self select: { package1 }.
	mapModel entities: famixModel allModelPackages.
	self assert: mapModel selectedEntities isEmpty
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testSelectAllAndDeselectAll [

	self handle: (GLSPSelectAllAction new
			 select: true;
			 yourself).
	self assertCollection: mapModel selectedEntities hasSameElements: {
			package1.
			package2 }.
	self handle: (GLSPSelectAllAction new
			 select: false;
			 yourself).
	self assert: mapModel selectedEntities isEmpty
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testSelectingANodeSelectsItsEntityInTheModel [

	self select: { package1 }.
	self assert: mapModel selectedEntities asArray equals: { package1 }.
	self assert: mapModel miSelectedItem asArray equals: { package1 }
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testSelectingAnEdgeSelectsNoEntity [

	self handle: (GLSPSelectAction new
			 selectedElementsIDs: ((self elementsOfType: 'archmap-dependency' in: session modelState root) collect: [ :each | each id ]);
			 yourself).
	self assert: mapModel selectedEntities isEmpty
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testSelectingMoreNodesAddsToTheSelection [

	self select: { package1 }.
	self select: { package2 }.
	self assertCollection: mapModel selectedEntities hasSameElements: {
			package1.
			package2 }
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
	module := (GLSPArchitecturalMapBrowser diagramModuleOn: #(  )).
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
GLSPArchitecturalMapBrowserTest >> testTheSelectedNodesAreSentSelected [
	"So that a model sent again (e.g. after a move) still shows the selection"

	self select: { package1 }.
	session updateGModel.
	self assert: (self nodeOf: package1) selected.
	self deny: (self nodeOf: package2) selected
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testTheServerAnnouncesTheMove [

	self assert: ((GLSPArchitecturalMapBrowser diagramModuleOn: #(  )) handledActionKinds includes: GLSPChangeBoundsOperation kind)
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testTheServerAnnouncesTheSelection [

	| kinds |
	kinds := (GLSPArchitecturalMapBrowser diagramModuleOn: #(  )) handledActionKinds.
	self assert: (kinds includes: GLSPSelectAction kind).
	self assert: (kinds includes: GLSPSelectAllAction kind)
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testWhenTheClientHasGoneNothingIsSent [

	| browser sent |
	browser := mapModel browser.
	sent := server sentActions size.
	server close.
	mapModel updateFromConfiguration: mapModel currentConfiguration.
	self assert: mapModel browser identicalTo: browser.
	self assert: server sentActions size equals: sent.
	"The model still works"
	mapModel updateFromConfiguration: mapModel currentConfiguration.
	self assert: mapModel rootNodes size equals: 2
]

{ #category : 'tests' }
GLSPArchitecturalMapBrowserTest >> testWithoutSelectionTheModelAnswersItsEntities [

	self assert: mapModel selectedEntities isEmpty.
	self assert: mapModel miSelectedItem equals: mapModel entities
]
