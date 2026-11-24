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
MiArchiBlVisualizationTest >> assertPoint: aPoint isOnBorderOf: anElement [
	"aPoint is in space coordinates. The bounds are copied as a Rectangle: Bloc's cached bounds are changed in place by #expandBy:"

	| bounds |
	bounds := anElement boundsInSpace asRectangle.
	self assert: ((bounds expandBy: 0.01) containsPoint: aPoint).
	self assert: ({
			 bounds left.
			 bounds right } anySatisfy: [ :x | (x - aPoint x) abs < 0.01 ]) | ({
			 bounds top.
			 bounds bottom } anySatisfy: [ :y | (y - aPoint y) abs < 0.01 ])
]

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
MiArchiBlVisualizationTest >> highlightColor [
	"The accent color of the theme"

	^ space root valueOfTokenNamed: #'color-primary'
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> layOut: aVisualization [
	"Add the element of aVisualization to the space and wait until the space has settled: the layout is done and the lines are drawn"

	space deferAndSettle: [ space root addChild: aVisualization element ].
	^ aVisualization
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> lineFrom: sourceEntity to: targetEntity in: aVisualization [

	^ aVisualization linesLayer children detect: [ :each |
			  | dependency |
			  dependency := each userData at: #miArchitecturalMapDependency.
			  dependency source entity == sourceEntity and: [ dependency target entity == targetEntity ] ]
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> mouseOver: aBox [
	"The mouse comes over aBox: the event bubbles up from it, as with a real mouse"

	space deferAndSettle: [
			aBox fireEvent: (BlMouseOverEvent new
					 position: aBox boundsInSpace center;
					 screenPosition: aBox boundsInSpace center + (1000 @ 1000);
					 yourself) ]
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> pairsOfLinesIn: aVisualization [
	"The (source entity -> target entity) of each line drawn"

	^ (aVisualization linesLayer children collect: [ :each |
			   | dependency |
			   dependency := each userData at: #miArchitecturalMapDependency.
			   dependency source entity -> dependency target entity ]) asSet
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

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testHighlightKeptWhenLinesAreRedrawn [
	"Boxes move while the mouse is over package1: the new line to package2 is still highlighted"

	| visualization |
	visualization := self layOut: (self visualizationOf: self tree).
	self mouseOver: (self boxOf: package1 in: visualization).
	space deferAndSettle: [ (self boxOf: package1 in: visualization) margin: (BlInsets all: 40) ].
	self assert: (self lineFrom: package1 to: package2 in: visualization) border paint color equals: self highlightColor
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testHighlightedLineHasHighlightedArrowHead [

	| visualization head |
	visualization := self layOut: (self visualizationOf: self tree).
	head := (self lineFrom: package1 to: package2 in: visualization) children first.
	self deny: head background paint color equals: self highlightColor.
	self mouseOver: (self boxOf: package1 in: visualization).
	head := (self lineFrom: package1 to: package2 in: visualization) children first.
	self assert: head background paint color equals: self highlightColor
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testLineEndsAreOnBoxBorders [
	"Lines are under the boxes: they go from border to border, so that the arrow head is visible"

	| visualization line |
	visualization := self layOut: (self visualizationOf: self tree).
	line := visualization linesLayer children first.
	self assertPoint: (line localPointToGlobal: line geometry from) isOnBorderOf: (self boxOf: package1 in: visualization).
	self assertPoint: (line localPointToGlobal: line geometry to) isOnBorderOf: (self boxOf: package2 in: visualization)
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testLineEndsWithArrowHeadOnTarget [
	"The head is a triangle whose tip is the end of the line, on the target box"

	| visualization line head |
	visualization := self layOut: (self visualizationOf: self tree).
	line := visualization linesLayer children first.
	self assert: line children size equals: 1.
	head := line children first.
	self assert: head geometry vertices size equals: 3.
	self assert: head geometry vertices first equals: line geometry to.
	self assertPoint: (head localPointToGlobal: head geometry vertices first) isOnBorderOf: (self boxOf: package2 in: visualization)
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testLinesFollowBoxesThatMove [
	"When the boxes move after the first drawing, the lines are drawn again"

	| visualization box2 |
	visualization := self layOut: (self visualizationOf: self tree).
	box2 := self boxOf: package2 in: visualization.
	space deferAndSettle: [ (self boxOf: package1 in: visualization) margin: (BlInsets all: 40) ].
	self assert: (self pairsOfLinesIn: visualization) equals: { (package1 -> package2) } asSet.
	self
		assertPoint: (visualization linesLayer children first localPointToGlobal: visualization linesLayer children first geometry to)
		isOnBorderOf: box2
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testLinesNotRedrawnWhenBoxesDidNotMove [

	| visualization lines |
	visualization := self layOut: (self visualizationOf: self tree).
	lines := visualization linesLayer children asArray.
	visualization updateLines.
	self assert: visualization linesLayer children asArray equals: lines
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testMouseLeavingTheMapRemovesHighlight [
	"Over package1, then the mouse leaves the whole map (leave events are sent to the element itself, they do not bubble)"

	| visualization |
	visualization := self layOut: (self visualizationOf: self tree).
	self mouseOver: (self boxOf: package1 in: visualization).
	space deferAndSettle: [
			visualization element dispatchEvent: (BlMouseLeaveEvent new
					 position: 900 @ 700;
					 screenPosition: 1900 @ 1700;
					 yourself) ].
	self deny: (self lineFrom: package1 to: package2 in: visualization) border paint color equals: self highlightColor.
	self deny: (self boxOf: package2 in: visualization) border paint color equals: self highlightColor
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testMouseOverBackgroundRemovesHighlight [
	"Over package1, then over the background: the line and the box of package2 look as before"

	| visualization line box2 lineBorder box2Border |
	visualization := self layOut: (self visualizationOf: self tree).
	line := self lineFrom: package1 to: package2 in: visualization.
	box2 := self boxOf: package2 in: visualization.
	lineBorder := line border.
	box2Border := box2 border.
	self mouseOver: (self boxOf: package1 in: visualization).
	self mouseOver: visualization element.
	self assert: line border equals: lineBorder.
	self assert: box2 border equals: box2Border
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testMouseOverBoxHighlightsIncomingLine [
	"package1 depends on package2: with the mouse over package2, the line from package1 is highlighted too"

	| visualization line |
	visualization := self layOut: (self visualizationOf: self tree).
	self mouseOver: (self boxOf: package2 in: visualization).
	line := self lineFrom: package1 to: package2 in: visualization.
	self assert: line border paint color equals: self highlightColor.
	self assert: line border width equals: 2
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testMouseOverBoxHighlightsOutgoingLine [
	"package1 depends on package2: with the mouse over package1, the line to package2 is drawn in the accent color, 2 pixels wide"

	| visualization line |
	visualization := self layOut: (self visualizationOf: self tree).
	self mouseOver: (self boxOf: package1 in: visualization).
	line := self lineFrom: package1 to: package2 in: visualization.
	self assert: line border paint color equals: self highlightColor.
	self assert: line border width equals: 2
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testMouseOverBoxHighlightsRemoteBoxes [
	"With the mouse over package1, package2 (at the other end of its dependency) has an accent border, both ways"

	| visualization |
	visualization := self layOut: (self visualizationOf: self tree).
	self mouseOver: (self boxOf: package1 in: visualization).
	self assert: (self boxOf: package2 in: visualization) border paint color equals: self highlightColor.
	self mouseOver: (self boxOf: package2 in: visualization).
	self assert: (self boxOf: package1 in: visualization) border paint color equals: self highlightColor
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testMouseOverNestedBoxHighlightsItsOwnDependencies [
	"Expanded packages: the mouse over the label of Class2 (inside package2) highlights Class1 -> Class2, not Class1 -> Class3"

	| visualization |
	visualization := self layOut: (self visualizationOf: self expandedTree).
	self mouseOver: (self boxOf: class2 in: visualization) children first.
	self assert: (self lineFrom: class1 to: class2 in: visualization) border paint color equals: self highlightColor.
	self deny: (self lineFrom: class1 to: class3 in: visualization) border paint color equals: self highlightColor
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

	| visualization |
	visualization := self layOut: (self visualizationOf: self tree).
	self assert: (self pairsOfLinesIn: visualization) equals: { (package1 -> package2) } asSet
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
MiArchiBlVisualizationTest >> testTagBoxIsDrawnWithTagColor [
	"In a map with a tag, the box of the tag is filled with its color, its entity boxes with the theme's background"

	| tag visualization |
	tag := self tagNamed: 'core' color: Color red on: class2.
	visualization := self layOut: (self visualizationOf: (self treeWithTags: { tag })).
	self assert: (self boxOf: tag in: visualization) background paint color equals: Color red.
	self
		assert: (self boxOf: package1 in: visualization) background paint color
		equals: (space root valueOfTokenNamed: #'color-bg-container')
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testTwoLinesWhenExpanded [
	"From Class1 to each of its superclasses"

	| visualization |
	visualization := self layOut: (self visualizationOf: self expandedTree).
	self assert: (self pairsOfLinesIn: visualization) equals: {
			(class1 -> class2).
			(class1 -> class3) } asSet
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
