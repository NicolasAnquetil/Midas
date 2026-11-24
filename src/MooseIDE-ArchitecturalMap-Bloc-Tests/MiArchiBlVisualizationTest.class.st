"
I test `MiArchiBlVisualization`, the Bloc drawing of the architectural map: its element tree, the boxes of the nodes, their styling, the lines of the dependencies, and the zoom.

## Collaborators & Context
- `MiArchitecturalMapBlAbstractTest`: the fixture (two packages, Class1 inheriting from Class2 and Class3) and `#tree`.
- `MiArchiBlTreeBuilder`, `MiArchiBlNode`: the tree drawn. Expanding nodes (`#isExpanded:`) before drawing chooses what is shown.
- `BlSpace` (`space`): never opened. Its root, with a `ToRawTheme`, is the `tokenSource`, and holds the element so that a layout can be computed (`#layOut:`).

## Assumptions & Invariants
- Each test gets a new space from `#setUp`. Expand nodes before `#visualizationOf:` sends `#element`, because the boxes are built only once.
- The lines are only there, and in place, after `#layOut:`. It computes two layout passes, as a shown space does over two frames: the lines layer is moved during the first pass and Bloc applies the move on the second.

## Main API
- `#visualizationOf:` a tree builder: a visualization with a flow layout and the space root as token source.
- `#layOut:` a visualization: add its element to the space root and compute the layout twice (which draws the lines and puts them in place).

"
Class {
	#name : 'MiArchiBlVisualizationTest',
	#superclass : 'MiArchitecturalMapBlAbstractTest',
	#instVars : [
		'space'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc-Tests',
	#package : 'MooseIDE-ArchitecturalMap-Bloc-Tests'
}

{ #category : 'running' }
MiArchiBlVisualizationTest >> boxOf: anEntity in: aVisualization [

	^ aVisualization elementsByNode associations
		  detect: [ :each | each key entity == anEntity ]
		  ifFound: [ :each | each value ]
		  ifNone: [ nil ]
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> expandedTree [
	"The tree with both packages expanded"

	| tree |
	tree := self tree.
	tree roots do: [ :each | each isExpanded: true ].
	^ tree
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> layOut: aVisualization [
	"Add the element of aVisualization to the space and compute the layout, which draws the lines.
	A second pass is needed, as in a shown space on the next frame: the lines layer is moved (#updateLines) while the first layout is computed, and Bloc applies it on the next one"

	space root addChild: aVisualization element.
	space root computeLayout.
	space root requestLayout.
	space root computeLayout.
	^ aVisualization
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> setUp [

	super setUp.
	space := BlSpace new.
	space extent: 800 @ 600.
	space toTheme: ToRawTheme new
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testBoxKnowsItsNode [

	| visualization |
	visualization := self visualizationOf: self expandedTree.
	visualization element.
	visualization elementsByNode keysAndValuesDo: [ :node :box |
		self assert: (box userData at: #miArchitecturalMapNode) identicalTo: node ]
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testBoxLabelIsNodeName [

	| visualization |
	visualization := self visualizationOf: self expandedTree.
	visualization element.
	visualization elementsByNode keysAndValuesDo: [ :node :box | self assert: box children first text asString equals: node name ]
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testBoxesForChildrenWhenExpanded [
	"The boxes of the children are in the box of their parent, after its label"

	| visualization nested |
	visualization := self visualizationOf: self expandedTree.
	visualization element.
	self assert: visualization elementsByNode size equals: 5.
	nested := (self boxOf: package2 in: visualization) children second children.
	self assert: nested asArray equals: {
			(self boxOf: class2 in: visualization).
			(self boxOf: class3 in: visualization) }
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testDashedBorderForNodeWithChildren [

	| visualization |
	visualization := self visualizationOf: self expandedTree.
	visualization element.
	self assert: (self boxOf: package2 in: visualization) border style isDashed.
	self deny: (self boxOf: class2 in: visualization) border style isDashed
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testElementFillsParent [

	| constraints |
	constraints := (self visualizationOf: self tree) element constraints.
	self assert: constraints horizontal resizer isMatchParent.
	self assert: constraints vertical resizer isMatchParent
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testElementIsBuiltOnce [

	| visualization |
	visualization := self visualizationOf: self tree.
	self assert: visualization element identicalTo: visualization element
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testElementWithoutLayoutClassFails [
	"There is no default layout: the browser always gives one"

	| visualization |
	visualization := MiArchiBlVisualization new
		                 tree: self tree;
		                 tokenSource: space root;
		                 yourself.
	self should: [ visualization element ] raise: Error
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testLineEndsAreBoxCenters [
	"The ends of a line are the centers of the boxes, in space coordinates"

	| visualization line |
	visualization := self layOut: (self visualizationOf: self tree).
	line := visualization linesLayer children first.
	self assert: (line localPointToGlobal: line geometry from) equals: (self boxOf: package1 in: visualization) boundsInSpace center.
	self assert: (line localPointToGlobal: line geometry to) equals: (self boxOf: package2 in: visualization) boundsInSpace center
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testLinesNotRedrawnWhenBoxesDidNotMove [

	| visualization lines |
	visualization := self layOut: (self visualizationOf: self tree).
	lines := visualization linesLayer children asArray.
	visualization updateLines.
	self assert: visualization linesLayer children asArray equals: lines
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testOneBoxPerRootWhenCollapsed [

	| visualization |
	visualization := self visualizationOf: self tree.
	visualization element.
	self assert: (visualization elementsByNode keys collect: #entity) asSet equals: {
			package1.
			package2 } asSet
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testOneLineWhenCollapsed [
	"Collapsed packages stand for their classes: one line from package1 to package2"

	| visualization line |
	visualization := self layOut: (self visualizationOf: self tree).
	self assert: visualization linesLayer children size equals: 1.
	line := visualization linesLayer children first geometry.
	self assert: line from equals: (visualization centerOf: (self boxOf: package1 in: visualization)).
	self assert: line to equals: (visualization centerOf: (self boxOf: package2 in: visualization))
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testTagBoxHasTagColor [
	"A node with a color (a tag) has it as background, the others the background token of the theme"

	| visualization |
	visualization := self visualizationOf: self tree.
	self
		assert: (visualization backgroundFor: (MiArchiBlNode new
					  color: Color red;
					  yourself))
		equals: Color red.
	self assert: (visualization backgroundFor: MiArchiBlNode new) equals: (space root valueOfTokenNamed: #'color-bg-container')
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testTwoLinesWhenExpanded [
	"From Class1 to each of its superclasses"

	| visualization centers |
	visualization := self layOut: (self visualizationOf: self expandedTree).
	centers := [ :entity | visualization centerOf: (self boxOf: entity in: visualization) ].
	self assert: (visualization linesLayer children collect: [ :each | each geometry from -> each geometry to ]) asSet equals: {
			((centers value: class1) -> (centers value: class2)).
			((centers value: class1) -> (centers value: class3)) } asSet
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testZoomInAndOut [

	| visualization event |
	visualization := self visualizationOf: self tree.
	visualization element.
	self assert: visualization zoom equals: 1.
	event := self wheelUp.
	visualization zoomBy: event.
	self assert: visualization zoom equals: 1.1.
	self assert: event isConsumed.
	visualization zoomBy: self wheelDown.
	self assert: visualization zoom closeTo: 1
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> visualizationOf: aTree [

	^ MiArchiBlVisualization new
		  tree: aTree;
		  layoutClass: MiArchiBlFlowLayout;
		  tokenSource: space root;
		  yourself
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> wheelDown [

	^ BlMouseWheelEvent new vector: (BlVector x: 0 y: -1)
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> wheelUp [

	^ BlMouseWheelEvent new vector: (BlVector x: 0 y: 1)
]
