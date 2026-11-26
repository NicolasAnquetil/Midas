"
I test `MiButterflyBlVisualization`, the Bloc drawing of the butterfly map: the columns and their alignment, the boxes and lines, the menus of the boxes and of the background, the changes made from them, the highlight of the boxes of the same entity, and zoom to fit.

## Collaborators & Context
- `MiButterflyBlAbstractTest`: the fixture and `#tree`.
- `BlSpace` (`space`) on the headless host (`BlHeadlessHost`), as in the Bloc guide on testing. Its root, with a `ToRawTheme`, is the `tokenSource`.

## Assumptions & Invariants
- Each test gets a new space, opened and settled by `#setUp`, and closed by `#tearDown`.
- The scene is only changed in the UI process of the space (`#do:`, `#visualizationOf:`, through `BlSpace>>#deferAndSettle:`), so assertions see a settled space.
- Menus are checked through the items the visualization builds (`#menuItemsFor:`, `#viewportMenuItems`), not by opening them.

## Main API
- `#visualizationOf:` a tree: drawn in the space. `#do:` a block: run in the space and settle.
- `#boundsOf:in:`, `#menuOf:in:`, `#labelsOf:`: what the tests look at.

"
Class {
	#name : 'MiButterflyBlVisualizationTest',
	#superclass : 'MiButterflyBlAbstractTest',
	#instVars : [
		'space'
	],
	#category : 'MooseIDE-Bloc-ButterflyMap-tests',
	#package : 'MooseIDE-Bloc-ButterflyMap',
	#tag : 'tests'
}

{ #category : 'running' }
MiButterflyBlVisualizationTest >> boundsOf: anEntity in: aVisualization [
	"The bounds in the space of the first box of anEntity"

	^ (aVisualization boxes detect: [ :each | (aVisualization nodeOf: each) entity == anEntity ]) boundsInSpace asRectangle
]

{ #category : 'running' }
MiButterflyBlVisualizationTest >> do: aBlock [
	"Run aBlock in the UI process of the space, then wait for the space to settle"

	space deferAndSettle: aBlock
]

{ #category : 'running' }
MiButterflyBlVisualizationTest >> labelsOf: someMenuItems [

	^ someMenuItems collect: [ :each | each labelText asString ] as: Array
]

{ #category : 'running' }
MiButterflyBlVisualizationTest >> menuOf: anEntity in: aVisualization [

	^ self labelsOf: (aVisualization menuItemsFor: (aVisualization nodeOf: (aVisualization boxes detect: [ :each | (aVisualization nodeOf: each) entity == anEntity ])))
]

{ #category : 'running' }
MiButterflyBlVisualizationTest >> setUp [
	"A space on the headless host, opened and settled, as in the Bloc guide on testing"

	super setUp.
	space := BlSpace new.
	space host: BlHeadlessHost default.
	space extent: 800 @ 600.
	space toTheme: ToRawTheme new.
	space
		show;
		settle
]

{ #category : 'running' }
MiButterflyBlVisualizationTest >> tearDown [

	space
		close;
		settle.
	super tearDown
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testAddLevelDrawsANewColumn [
	"A new column on the left, with ClientOfClients twice, and their lines"

	| visualization |
	visualization := self visualizationOf: self tree.
	self do: [ visualization addLevel ].
	self assert: (visualization boxes count: [ :each | (visualization nodeOf: each) entity == clientOfClients ]) equals: 2.
	self assert: visualization linesLayer children size equals: 5
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testColumnsCenteredVertically [
	"Center is in the middle of the column of its two clients"

	| visualization clients |
	visualization := self visualizationOf: self tree.
	clients := (self boundsOf: client1 in: visualization) merge: (self boundsOf: client2 in: visualization).
	self assert: ((self boundsOf: center in: visualization) center y - clients center y) abs < 1
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testColumnsFromLeftToRight [
	"The clients, then Center, then the provider"

	| visualization |
	visualization := self visualizationOf: self tree.
	self assert: (self boundsOf: client1 in: visualization) right < (self boundsOf: center in: visualization) left.
	self assert: (self boundsOf: center in: visualization) right < (self boundsOf: provider in: visualization) left
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testHighlightTheOtherBoxesOfTheSameEntity [
	"Highlighting one node of ClientOfClients puts a halo on its other box too"

	| tree visualization nodes |
	tree := self tree.
	tree addLevel.
	visualization := self visualizationOf: tree.
	nodes := tree leftLevels second.
	self do: [ visualization highlight: nodes first ].
	self assert: (visualization halosLayer children anySatisfy: [ :each |
			 each boundsInSpace asRectangle = (visualization boxOf: nodes second) boundsInSpace asRectangle ])
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testLeftColumnAlignedTowardsTheCenter [
	"Client1 and Client2 are one under the other, their right edges together"

	| visualization one two |
	visualization := self visualizationOf: self tree.
	one := self boundsOf: client1 in: visualization.
	two := self boundsOf: client2 in: visualization.
	self assert: one bottom <= two top.
	self assert: (one right - two right) abs < 0.01
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testMenuOfABoxInsideABox [
	"A method inside the box of Center: only the common items"

	| tree visualization method labels |
	tree := self tree.
	tree central isExpanded: true.
	visualization := self visualizationOf: tree.
	method := tree central children first.
	labels := self labelsOf: (visualization menuItemsFor: method).
	self deny: (labels includes: 'Remove node').
	self deny: (labels includes: 'Add dependencies').
	self assert: (labels includes: 'Inspect')
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testMenuOfAClient [

	| labels |
	labels := self menuOf: client1 in: (self visualizationOf: self tree).
	self assert: (labels includes: 'Add dependencies').
	self deny: (labels includes: 'Remove dependencies').
	self assert: (labels includes: 'Remove node').
	self assert: (labels includes: 'Be central node')
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testMenuOfTheBackground [

	| visualization |
	visualization := self visualizationOf: self tree.
	self assert: (self labelsOf: visualization viewportMenuItems) equals: #( 'Relayout all' 'Add level' 'Zoom to fit' ).
	self do: [ visualization addLevel ].
	self assert: (self labelsOf: visualization viewportMenuItems) equals: #( 'Relayout all' 'Add level' 'Remove external level' 'Zoom to fit' )
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testMenuOfTheCentralNode [
	"It has methods (Expand), its dependencies are there, it can not be removed nor be made central"

	| labels |
	labels := self menuOf: center in: (self visualizationOf: self tree).
	self assert: labels first equals: 'Expand'.
	self deny: (labels includes: 'Add dependencies').
	self assert: (labels includes: 'Remove dependencies').
	self deny: (labels includes: 'Remove node').
	self deny: (labels includes: 'Be central node').
	self assert: (labels includes: 'Inspect')
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testOneBoxPerNodeOfTheButterfly [

	| visualization |
	visualization := self visualizationOf: self tree.
	self assert: (self entitiesOf: (visualization boxes collect: [ :each | visualization nodeOf: each ])) asSet equals: { center. client1. client2. provider } asSet.
	self assert: visualization boxes size equals: 4
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testOneLinePerDependency [

	self assert: (self visualizationOf: self tree) linesLayer children size equals: 3
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testOuterLevelOnTheLeft [

	| tree visualization |
	tree := self tree.
	tree addLevel.
	visualization := self visualizationOf: tree.
	self assert: (self boundsOf: clientOfClients in: visualization) right < (self boundsOf: client1 in: visualization) left
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testRemoveNodeLeavesTheSelection [

	| visualization node |
	visualization := self visualizationOf: self tree.
	node := visualization nodeOf: (visualization boxes detect: [ :each | (visualization nodeOf: each) entity == client1 ]).
	self do: [ visualization selectNodes: { node } ].
	self do: [ visualization remove: node ].
	self assert: (visualization boxOf: node) isNil.
	self assert: visualization selectedNodes isEmpty.
	self assert: visualization linesLayer children size equals: 2
]

{ #category : 'tests' }
MiButterflyBlVisualizationTest >> testZoomToFit [
	"The whole map in the viewport, touching two of its sides"

	| tree visualization canvas viewport |
	tree := self tree.
	tree addLevel.
	visualization := self visualizationOf: tree.
	self do: [ visualization zoomToFit ].
	viewport := visualization viewport boundsInSpace asRectangle.
	canvas := (visualization boxes inject: (visualization boxes first boundsInSpace asRectangle) into: [ :all :each | all merge: each boundsInSpace asRectangle ]).
	self assert: ((viewport expandBy: 0.5) containsRect: canvas).
	self assert: visualization zoom > 1
]

{ #category : 'running' }
MiButterflyBlVisualizationTest >> visualizationOf: aTree [
	"The visualization of aTree, its viewport in the space, the space settled: the layout is done and the lines are drawn"

	| visualization |
	visualization := MiButterflyBlVisualization new
		                 tree: aTree;
		                 tokenSource: space root;
		                 yourself.
	space deferAndSettle: [ space root addChild: visualization viewport ].
	^ visualization
]
