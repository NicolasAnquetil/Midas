"
I test `MiArchiBlVisualization`, the Bloc drawing of the architectural map: its element tree, the boxes of the nodes, their styling, the lines of the dependencies, and the zoom and pan with the mouse.

## Collaborators & Context
- `MiArchitecturalMapBlAbstractTest`: the fixture (two packages, Class1 inheriting from Class2 and Class3) and `#tree`.
- `MiArchiBlTreeBuilder`, `MiArchiBlNode`: the tree drawn. Expanding nodes (`#isExpanded:`) before drawing chooses what is shown.
- `BlSpace` (`space`) on the headless host (`BlHeadlessHost`), as in the Bloc guide TestingInteractions (github.com/pharo-graphics/Bloc, doc/). Its root, with a `ToRawTheme`, is the `tokenSource`.

## Assumptions & Invariants
- Each test gets a new space, opened and settled by `#setUp`, and closed by `#tearDown`.
- Expand nodes before `#visualizationOf:` sends `#element`, because the boxes are built only once.
- The scene is only changed through `BlSpace>>#deferAndSettle:` (`#layOut:`, `#fire:at:on:`), so assertions see a settled space: layout done, lines drawn.
- Mouse events are sent with `#fireEvent:` (they go up to the root, as with a real mouse), with a screen position different from the space position on purpose.

## Main API
- `#visualizationOf:` a tree builder: a visualization with a flow layout and the space root as token source.
- `#layOut:` a visualization: add its element to the space and settle.
- `#fire:at:on:`, `#wheel:at:on:`, `#drag:from:to:`: mouse events on the element of a visualization.

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
MiArchiBlVisualizationTest >> drag: aVisualization from: startPoint to: endPoint [

	self
		fire: (BlMouseDownEvent new
				 button: BlMouseButton primary;
				 yourself)
		at: startPoint
		on: aVisualization.
	self fire: BlMouseMoveEvent new at: endPoint on: aVisualization.
	self
		fire: (BlMouseUpEvent new
				 button: BlMouseButton primary;
				 yourself)
		at: endPoint
		on: aVisualization
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
MiArchiBlVisualizationTest >> fire: anEvent at: aPoint on: aVisualization [
	"Fire anEvent at aPoint (space coordinates) on the element of aVisualization, as the mouse does, and wait for the space to settle. The screen position is made different on purpose: the code must use #position"

	anEvent
		position: aPoint;
		screenPosition: aPoint + (1000 @ 1000).
	space deferAndSettle: [ aVisualization element fireEvent: anEvent ].
	^ anEvent
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> layOut: aVisualization [
	"Add the element of aVisualization to the space and wait until the space has settled: the layout is done and the lines are drawn"

	space deferAndSettle: [ space root addChild: aVisualization element ].
	^ aVisualization
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> setUp [
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
MiArchiBlVisualizationTest >> tearDown [

	space
		close;
		settle.
	super tearDown
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
MiArchiBlVisualizationTest >> testMoveWithoutPressDoesNotPan [

	| visualization |
	visualization := self layOut: (self visualizationOf: self tree).
	self fire: BlMouseMoveEvent new at: 330 @ 310 on: visualization.
	self assert: visualization origin equals: 0 @ 0
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
MiArchiBlVisualizationTest >> testPan [
	"Dragging moves the map by the same amount, and the boxes with it"

	| visualization box before |
	visualization := self layOut: (self visualizationOf: self tree).
	box := self boxOf: package1 in: visualization.
	before := box boundsInSpace origin.
	self drag: visualization from: 300 @ 300 to: 330 @ 310.
	self assert: visualization origin equals: 30 @ 10.
	self assert: box boundsInSpace origin equals: before + (30 @ 10)
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testTagBoxHasTagColor [
	"A tag node has its color as background, an entity node the background token of the theme"

	| visualization |
	visualization := self visualizationOf: self tree.
	self
		assert: (visualization backgroundFor: (MiArchiBlTagNode new
					  color: Color red;
					  yourself))
		equals: Color red.
	self assert: (visualization backgroundFor: MiArchiBlEntityNode new) equals: (space root valueOfTokenNamed: #'color-bg-container')
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
MiArchiBlVisualizationTest >> testZoomAroundCursor [
	"With the cursor on the center of a box, zooming leaves that center under the cursor, and makes the box larger"

	| visualization box center width |
	visualization := self layOut: (self visualizationOf: self tree).
	box := self boxOf: package2 in: visualization.
	center := box boundsInSpace center.
	width := box boundsInSpace width.
	self wheel: 1 at: center on: visualization.
	self assert: (box boundsInSpace center distanceTo: center) < 0.01.
	self assert: box boundsInSpace width closeTo: width * 1.1
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testZoomInAndOut [

	| visualization event |
	visualization := self layOut: (self visualizationOf: self tree).
	self assert: visualization zoom equals: 1.
	event := self wheel: 1 at: 0 @ 0 on: visualization.
	self assert: visualization zoom closeTo: 1.1.
	self assert: event isConsumed.
	self wheel: -1 at: 0 @ 0 on: visualization.
	self assert: visualization zoom closeTo: 1
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testZoomIsBounded [

	| visualization |
	visualization := self layOut: (self visualizationOf: self tree).
	60 timesRepeat: [
			visualization zoomBy: (BlMouseWheelEvent new
					 vector: (BlVector x: 0 y: 1);
					 position: 0 @ 0;
					 yourself) ].
	self assert: visualization zoom equals: visualization maxZoom.
	60 timesRepeat: [
			visualization zoomBy: (BlMouseWheelEvent new
					 vector: (BlVector x: 0 y: -1);
					 position: 0 @ 0;
					 yourself) ].
	self assert: visualization zoom equals: visualization minZoom
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
MiArchiBlVisualizationTest >> wheel: anInteger at: aPoint on: aVisualization [
	"anInteger > 0: wheel up (zoom in), < 0: wheel down"

	^ self fire: (BlMouseWheelEvent new vector: (BlVector x: 0 y: anInteger)) at: aPoint on: aVisualization
]
