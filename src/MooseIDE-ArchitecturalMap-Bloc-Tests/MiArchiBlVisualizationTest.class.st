"
I test `MiArchiBlVisualization`, the Bloc drawing of the architectural map: its element tree, the boxes of the nodes, their styling, the lines of the dependencies, and the zoom and pan with the mouse.

## Collaborators & Context
- `MiArchitecturalMapBlAbstractTest`: the fixture (two packages, Class1 inheriting from Class2 and Class3) and `#tree`.
- `MiArchiBlTreeBuilder`, `MiArchiBlNode`: the tree drawn. Expanding nodes (`#isExpanded:`) before drawing chooses what is shown.
- `BlSpace` (`space`) on the headless host (`BlHeadlessHost`), as in the Bloc guide TestingInteractions (github.com/pharo-graphics/Bloc, doc/). Its root, with a `ToRawTheme`, is the `tokenSource`.

## Assumptions & Invariants
- Each test gets a new space, opened and settled by `#setUp`, and closed by `#tearDown`.
- Expand nodes before `#visualizationOf:` sends `#viewport`, because the boxes are built only once.
- The scene is only changed through `BlSpace>>#deferAndSettle:` (`#layOut:`, `#fire:at:on:`), so assertions see a settled space: layout done, lines drawn.
- Mouse events are sent with `#fireEvent:` (they go up to the root, as with a real mouse), with a screen position different from the space position on purpose.

## Main API
- `#visualizationOf:` a tree builder: a visualization with a flow layout and the space root as token source.
- `#layOut:` a visualization: add its viewport to the space and settle.
- `#fire:at:on:`, `#wheel:at:on:`, `#drag:from:to:`: mouse events on the viewport of a visualization.

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
MiArchiBlVisualizationTest >> box: aBox hasHaloIn: aVisualization [
	"A halo of a box is a translucent yellow ring, 3 pixels wide, around it, in the halos layer (same bounds, drawn outside them)"

	^ aVisualization halosLayer children anySatisfy: [ :each |
			  each boundsInSpace asRectangle = aBox boundsInSpace asRectangle and: [
				  (each border paint color alpha: 1) = Color yellow and: [ each border width = 3 ] ] ]
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> boxOf: anEntity in: aVisualization [

	^ aVisualization boxes detect: [ :each | (aVisualization nodeOf: each) entity == anEntity ] ifNone: [ nil ]
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> choose: aLabel in: aMenu [
	"Click (primary press and release, in one go) the item of aMenu labelled aLabel, where it is drawn, through the space"

	| item |
	item := aMenu items asArray detect: [ :each | each labelText asString = aLabel ].
	self
		mouseAll: {
				BlMouseDownEvent primary.
				BlMouseUpEvent primary }
		at: item boundsInSpace center
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> drag: aVisualization from: startPoint to: endPoint [
	"Press the primary button at startPoint, move to endPoint and release it there, through the space (so as drag events when the move is longer than the drag threshold of Bloc, a few pixels)"

	self mouse: BlMouseDownEvent primary at: startPoint.
	self mouse: BlMouseMoveEvent primary at: endPoint.
	self mouse: BlMouseUpEvent primary at: endPoint
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
	"Fire anEvent at aPoint (space coordinates) on the viewport under that point (as the mouse does: lines and halos ignore the mouse), and wait for the space to settle. The event bubbles up to the viewport of aVisualization. The screen position is made different on purpose: the code must use #position"

	anEvent
		position: aPoint;
		screenPosition: aPoint + (1000 @ 1000).
	space deferAndSettle: [ ((space root findMouseEventTargetAt: aPoint) ifNil: [ aVisualization viewport ]) fireEvent: anEvent ].
	^ anEvent
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> labelsOf: aMenu [

	^ aMenu items collect: [ :each | each labelText asString ]
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> layOut: aVisualization [
	"Add the viewport of aVisualization to the space and wait until the space has settled: the layout is done and the lines are drawn"

	space deferAndSettle: [ space root addChild: aVisualization viewport ].
	^ aVisualization
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> line: aLine hasHaloIn: aVisualization [
	"A halo of a line is a translucent yellow stroke, along the same segment, 3 pixels wide, drawn under the lines"

	^ aVisualization halosLayer children anySatisfy: [ :each |
			  (each geometry isKindOf: BlLineGeometry) and: [
					  each geometry from = aLine geometry from and: [
						  each geometry to = aLine geometry to and: [
							  (each border paint color alpha: 1) = Color yellow and: [ each border width = 3 ] ] ] ] ]
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> lineFrom: sourceEntity to: targetEntity in: aVisualization [

	^ aVisualization linesLayer children detect: [ :each |
			  | dependency |
			  dependency := each userData at: #miArchitecturalMapDependency.
			  dependency source entity == sourceEntity and: [ dependency target entity == targetEntity ] ]
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> mouse: anEvent at: aPoint [
	"Send anEvent (a mouse down, move or up) at aPoint (space coordinates) to the space, as its host does, and wait for the space to settle. The space picks the element under aPoint, and turns a press followed by moves into drag events (as in BlMouseProcessingTest). The screen position is made different on purpose: the code must use #position"

	self mouseAll: { anEvent } at: aPoint.
	^ anEvent
]

{ #category : 'running' }
MiArchiBlVisualizationTest >> mouseAll: someEvents at: aPoint [
	"Send someEvents one after the other at aPoint, without waiting in between, then wait for the space to settle (see #mouse:at:)"

	someEvents do: [ :each |
			each
				position: aPoint;
				screenPosition: aPoint + (1000 @ 1000) ].
	space deferAndSettle: [
			someEvents do: [ :each |
					each fillFromTime: space time.
					space eventListener handleEvent: each ] ]
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
MiArchiBlVisualizationTest >> rightClick: aBox [
	"Press and release the secondary button over the label of aBox (not over a child box), through the space, as a quick right click does. Answer the context menu it opened, nil if none.
	Both are sent in one go: Toplo closes a menu released more than 300 ms after it popped up (a press held, then released), and settling the space between the two may take that long"

	| point |
	point := aBox children first boundsInSpace center.
	self
		mouseAll: {
				BlMouseDownEvent secondary.
				BlMouseUpEvent secondary }
		at: point.
	^ aBox currentContextMenu
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
	"Each box drawn knows its node, and the visualization finds the box of a node"

	| visualization |
	visualization := self visualizationOf: self expandedTree.
	visualization viewport.
	visualization boxes do: [ :box | self assert: (visualization boxOf: (visualization nodeOf: box)) identicalTo: box ]
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testBoxLabelIsNodeName [

	| visualization |
	visualization := self visualizationOf: self expandedTree.
	visualization viewport.
	visualization boxes do: [ :box | self assert: box children first text asString equals: (visualization nodeOf: box) name ]
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testBoxesForChildrenWhenExpanded [
	"The boxes of the children are in the box of their parent, after its label"

	| visualization nested |
	visualization := self visualizationOf: self expandedTree.
	visualization viewport.
	self assert: visualization boxes size equals: 5.
	nested := (self boxOf: package2 in: visualization) children second children.
	self assert: nested asArray equals: {
			(self boxOf: class2 in: visualization).
			(self boxOf: class3 in: visualization) }
]

{ #category : 'tests - expand' }
MiArchiBlVisualizationTest >> testChooseCollapseHidesChildren [
	"In the expanded tree, Collapse on package2 removes the boxes of Class2 and Class3; the dependencies of Class1 now end on package2"

	| visualization |
	visualization := self layOut: (self visualizationOf: self expandedTree).
	self choose: 'Collapse' in: (self rightClick: (self boxOf: package2 in: visualization)).
	self assert: (self boxOf: class2 in: visualization) isNil.
	self assert: (self boxOf: class3 in: visualization) isNil.
	self assert: (self pairsOfLinesIn: visualization) equals: { (class1 -> package2) } asSet
]

{ #category : 'tests - expand' }
MiArchiBlVisualizationTest >> testChooseExpandMovesLinesToChildren [
	"After Expand on package1, the dependency to package2 starts from Class1, on the border of its box"

	| visualization line |
	visualization := self layOut: (self visualizationOf: self tree).
	self choose: 'Expand' in: (self rightClick: (self boxOf: package1 in: visualization)).
	self assert: (self pairsOfLinesIn: visualization) equals: { (class1 -> package2) } asSet.
	line := self lineFrom: class1 to: package2 in: visualization.
	self assertPoint: (line localPointToGlobal: line geometry from) isOnBorderOf: (self boxOf: class1 in: visualization)
]

{ #category : 'tests - expand' }
MiArchiBlVisualizationTest >> testChooseExpandShowsChildrenInTheBox [
	"Expand in the menu of package1 draws the box of Class1 in the box of package1"

	| visualization class1Box |
	visualization := self layOut: (self visualizationOf: self tree).
	self choose: 'Expand' in: (self rightClick: (self boxOf: package1 in: visualization)).
	class1Box := self boxOf: class1 in: visualization.
	self assert: class1Box isNotNil.
	self assert: (class1Box allParentsInclude: (self boxOf: package1 in: visualization))
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testDashedBorderForNodeWithChildren [

	| visualization |
	visualization := self visualizationOf: self expandedTree.
	visualization viewport.
	self assert: (self boxOf: package2 in: visualization) border style isDashed.
	self deny: (self boxOf: class2 in: visualization) border style isDashed
]

{ #category : 'tests - moving' }
MiArchiBlVisualizationTest >> testDragBoxLeavesOtherBoxesInPlace [
	"The layout of the map is replaced by explicit positions: package2 stays where it was"

	| visualization before start |
	visualization := self layOut: (self visualizationOf: self tree).
	before := (self boxOf: package2 in: visualization) boundsInSpace asRectangle.
	start := (self boxOf: package1 in: visualization) boundsInSpace center.
	self drag: visualization from: start to: start + (30 @ 60).
	self assert: (self boxOf: package2 in: visualization) boundsInSpace asRectangle equals: before
]

{ #category : 'tests - moving' }
MiArchiBlVisualizationTest >> testDragBoxMovesIt [
	"Pressing on package1 and dragging moves its box by the same amount, and does not pan the map"

	| visualization box before start |
	visualization := self layOut: (self visualizationOf: self tree).
	box := self boxOf: package1 in: visualization.
	before := box boundsInSpace origin.
	start := box boundsInSpace center.
	self drag: visualization from: start to: start + (30 @ 10).
	self assert: box boundsInSpace origin equals: before + (30 @ 10).
	self assert: visualization origin equals: 0 @ 0
]

{ #category : 'tests - moving' }
MiArchiBlVisualizationTest >> testDragBoxMovesItsLines [
	"The line from package1 starts on the border of package1 where it is now"

	| visualization start line |
	visualization := self layOut: (self visualizationOf: self tree).
	start := (self boxOf: package1 in: visualization) boundsInSpace center.
	self drag: visualization from: start to: start + (30 @ 60).
	line := self lineFrom: package1 to: package2 in: visualization.
	self assertPoint: (line localPointToGlobal: line geometry from) isOnBorderOf: (self boxOf: package1 in: visualization).
	self assertPoint: (line localPointToGlobal: line geometry to) isOnBorderOf: (self boxOf: package2 in: visualization)
]

{ #category : 'tests - moving' }
MiArchiBlVisualizationTest >> testDragBoxUnderZoomFollowsTheMouse [
	"Zoomed in, the box moves on screen by what the mouse moved (not by that amount times the zoom)"

	| visualization box before start |
	visualization := self layOut: (self visualizationOf: self tree).
	3 timesRepeat: [ self wheel: 1 at: 0 @ 0 on: visualization ].
	box := self boxOf: package1 in: visualization.
	before := box boundsInSpace origin.
	start := box boundsInSpace center.
	self drag: visualization from: start to: start + (30 @ 10).
	self assert: (box boundsInSpace origin - (before + (30 @ 10))) r < 0.01
]

{ #category : 'tests - moving' }
MiArchiBlVisualizationTest >> testDragNestedBoxGrowsItsParent [
	"Expanded: Class3 (the rightmost class of package2) dragged 80 pixels to the right makes package2 80 pixels wider and still contains it; Class2 stays in place"

	| visualization package2Box class2Bounds width start |
	visualization := self layOut: (self visualizationOf: self expandedTree).
	package2Box := self boxOf: package2 in: visualization.
	width := package2Box boundsInSpace width.
	class2Bounds := (self boxOf: class2 in: visualization) boundsInSpace asRectangle.
	start := (self boxOf: class3 in: visualization) boundsInSpace center.
	self drag: visualization from: start to: start + (80 @ 0).
	self assert: package2Box boundsInSpace width equals: width + 80.
	self assert: (self boxOf: class2 in: visualization) boundsInSpace asRectangle equals: class2Bounds.
	self assert:
		(package2Box boundsInSpace asRectangle containsRect: (self boxOf: class3 in: visualization) boundsInSpace asRectangle)
]

{ #category : 'tests - moving' }
MiArchiBlVisualizationTest >> testDragNestedBoxStopsAtLeftAndTopOfItsParent [
	"Expanded: Class2 (the leftmost class of package2) dragged far to the left and up stays inside package2"

	| visualization package2Box start |
	visualization := self layOut: (self visualizationOf: self expandedTree).
	package2Box := self boxOf: package2 in: visualization.
	start := (self boxOf: class2 in: visualization) boundsInSpace center.
	self drag: visualization from: start to: start - (100 @ 100).
	self assert:
		(package2Box boundsInSpace asRectangle containsRect: (self boxOf: class2 in: visualization) boundsInSpace asRectangle)
]

{ #category : 'tests - moving' }
MiArchiBlVisualizationTest >> testDragParentBoxMovesItsChildren [
	"Expanded: dragging package2 by its label moves Class2 and Class3 with it"

	| visualization class2Origin start |
	visualization := self layOut: (self visualizationOf: self expandedTree).
	class2Origin := (self boxOf: class2 in: visualization) boundsInSpace origin.
	start := (self boxOf: package2 in: visualization) children first boundsInSpace center.
	self drag: visualization from: start to: start + (20 @ 50).
	self assert: (self boxOf: class2 in: visualization) boundsInSpace origin equals: class2Origin + (20 @ 50)
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testDraggedBoxIsHighlightedAtRelease [
	"The mouse was over package1, then package2 is dragged: at the release the mouse is over package2, so the line from package1 has a halo where it is now, and package1 gets the ring"

	| visualization start |
	visualization := self layOut: (self visualizationOf: self tree).
	self mouseOver: (self boxOf: package1 in: visualization).
	start := (self boxOf: package2 in: visualization) boundsInSpace center.
	self drag: visualization from: start to: start + (40 @ 60).
	self assert: (self line: (self lineFrom: package1 to: package2 in: visualization) hasHaloIn: visualization).
	self assert: (self box: (self boxOf: package1 in: visualization) hasHaloIn: visualization).
	self assert: visualization halosLayer children size equals: 2
]

{ #category : 'tests - expand' }
MiArchiBlVisualizationTest >> testExpandKeepsBoxesMovedByHand [
	"package2 dragged down, then expanded: package2 stays where it was dropped, package1 too, and the layer of the boxes grows to contain the bigger package2"

	| visualization start package1Origin package2Origin package2Box |
	visualization := self layOut: (self visualizationOf: self tree).
	start := (self boxOf: package2 in: visualization) boundsInSpace center.
	self drag: visualization from: start to: start + (0 @ 80).
	package1Origin := (self boxOf: package1 in: visualization) boundsInSpace origin.
	package2Origin := (self boxOf: package2 in: visualization) boundsInSpace origin.
	self choose: 'Expand' in: (self rightClick: (self boxOf: package2 in: visualization)).
	package2Box := self boxOf: package2 in: visualization.
	self assert: package2Box boundsInSpace origin equals: package2Origin.
	self assert: (self boxOf: package1 in: visualization) boundsInSpace origin equals: package1Origin.
	self assert: (package2Box parent boundsInSpace asRectangle containsRect: package2Box boundsInSpace asRectangle)
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testHighlightedLineKeepsItsLook [
	"The halo is added under the line: the line and its arrow head keep their color and width"

	| visualization line border headBackground |
	visualization := self layOut: (self visualizationOf: self tree).
	line := self lineFrom: package1 to: package2 in: visualization.
	border := line border.
	headBackground := line children first background.
	self mouseOver: (self boxOf: package1 in: visualization).
	self assert: line border equals: border.
	self assert: line children first background equals: headBackground
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
	"Over package1, then the mouse leaves the whole map (leave events are sent to the viewport itself, they do not bubble)"

	| visualization |
	visualization := self layOut: (self visualizationOf: self tree).
	self mouseOver: (self boxOf: package1 in: visualization).
	space deferAndSettle: [
			visualization viewport dispatchEvent: (BlMouseLeaveEvent new
					 position: 900 @ 700;
					 screenPosition: 1900 @ 1700;
					 yourself) ].
	self assert: visualization halosLayer children isEmpty
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testMouseOverBackgroundRemovesHighlight [
	"Over package1, then over the background: no halo left"

	| visualization |
	visualization := self layOut: (self visualizationOf: self tree).
	self mouseOver: (self boxOf: package1 in: visualization).
	self mouseOver: visualization viewport.
	self assert: visualization halosLayer children isEmpty
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testMouseOverBoxHighlightsIncomingLine [
	"package1 depends on package2: with the mouse over package2, the line from package1 has a halo too"

	| visualization |
	visualization := self layOut: (self visualizationOf: self tree).
	self mouseOver: (self boxOf: package2 in: visualization).
	self assert: (self line: (self lineFrom: package1 to: package2 in: visualization) hasHaloIn: visualization)
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testMouseOverBoxHighlightsOutgoingLine [
	"package1 depends on package2: with the mouse over package1, the line to package2 has a grey halo"

	| visualization |
	visualization := self layOut: (self visualizationOf: self tree).
	self mouseOver: (self boxOf: package1 in: visualization).
	self assert: (self line: (self lineFrom: package1 to: package2 in: visualization) hasHaloIn: visualization)
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testMouseOverBoxHighlightsRemoteBoxes [
	"With the mouse over package1, package2 (at the other end of its dependency) has a yellow ring around it and keeps its border, both ways"

	| visualization box2Border |
	visualization := self layOut: (self visualizationOf: self tree).
	box2Border := (self boxOf: package2 in: visualization) border.
	self mouseOver: (self boxOf: package1 in: visualization).
	self assert: (self box: (self boxOf: package2 in: visualization) hasHaloIn: visualization).
	self deny: (self box: (self boxOf: package1 in: visualization) hasHaloIn: visualization).
	self assert: (self boxOf: package2 in: visualization) border equals: box2Border.
	self mouseOver: (self boxOf: package2 in: visualization).
	self assert: (self box: (self boxOf: package1 in: visualization) hasHaloIn: visualization)
]

{ #category : 'tests - highlight' }
MiArchiBlVisualizationTest >> testMouseOverNestedBoxHighlightsItsOwnDependencies [
	"Expanded packages: the mouse over the label of Class2 (inside package2) highlights Class1 -> Class2, not Class1 -> Class3"

	| visualization |
	visualization := self layOut: (self visualizationOf: self expandedTree).
	self mouseOver: (self boxOf: class2 in: visualization) children first.
	self assert: (self line: (self lineFrom: class1 to: class2 in: visualization) hasHaloIn: visualization).
	self deny: (self line: (self lineFrom: class1 to: class3 in: visualization) hasHaloIn: visualization)
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testMoveWithoutPressDoesNotPan [

	| visualization |
	visualization := self layOut: (self visualizationOf: self tree).
	self mouse: BlMouseMoveEvent new at: 330 @ 310.
	self assert: visualization origin equals: 0 @ 0
]

{ #category : 'tests - moving' }
MiArchiBlVisualizationTest >> testMovingAfterReleaseMovesNothing [
	"package1 dragged and released: moving the mouse afterwards, button up, neither moves it nor pans"

	| visualization box start dropped |
	visualization := self layOut: (self visualizationOf: self tree).
	box := self boxOf: package1 in: visualization.
	start := box boundsInSpace center.
	self drag: visualization from: start to: start + (30 @ 10).
	dropped := box boundsInSpace origin.
	self mouse: BlMouseMoveEvent new at: start + (60 @ 40).
	self assert: box boundsInSpace origin equals: dropped.
	self assert: visualization origin equals: 0 @ 0
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testOneBoxPerRootWhenCollapsed [

	| visualization |
	visualization := self visualizationOf: self tree.
	visualization viewport.
	self assert: (visualization boxes collect: [ :each | (visualization nodeOf: each) entity ]) asSet equals: {
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

{ #category : 'tests - lines' }
MiArchiBlVisualizationTest >> testPanDoesNotRedrawLines [
	"The lines are in the canvas, which the pan moves as a whole: they stay the same elements"

	| visualization line |
	visualization := self layOut: (self visualizationOf: self tree).
	line := self lineFrom: package1 to: package2 in: visualization.
	self drag: visualization from: 700 @ 500 to: 720 @ 520.
	self assert: (self lineFrom: package1 to: package2 in: visualization) identicalTo: line
]

{ #category : 'tests - expand' }
MiArchiBlVisualizationTest >> testRightClickBoxWithoutChildrenOpensNoMenu [
	"Class1 has no children: no menu, neither its own nor the one of package1 around it"

	| visualization |
	visualization := self layOut: (self visualizationOf: self expandedTree).
	self assert: (self rightClick: (self boxOf: class1 in: visualization)) isNil.
	self assert: (self boxOf: package1 in: visualization) currentContextMenu isNil
]

{ #category : 'tests - expand' }
MiArchiBlVisualizationTest >> testRightClickCollapsedBoxOffersExpand [
	"package1 has a child and is collapsed: its menu has one item, Expand"

	| visualization menu |
	visualization := self layOut: (self visualizationOf: self tree).
	menu := self rightClick: (self boxOf: package1 in: visualization).
	self assert: menu isNotNil.
	self assert: (self labelsOf: menu) asArray equals: #( 'Expand' )
]

{ #category : 'tests - expand' }
MiArchiBlVisualizationTest >> testRightClickExpandedBoxOffersCollapse [
	"In the expanded tree, package2 shows its classes: its menu has one item, Collapse"

	| visualization menu |
	visualization := self layOut: (self visualizationOf: self expandedTree).
	menu := self rightClick: (self boxOf: package2 in: visualization).
	self assert: (self labelsOf: menu) asArray equals: #( 'Collapse' )
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
MiArchiBlVisualizationTest >> testViewportFillsParent [

	| constraints |
	constraints := (self visualizationOf: self tree) viewport constraints.
	self assert: constraints horizontal resizer isMatchParent.
	self assert: constraints vertical resizer isMatchParent
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testViewportIsBuiltOnce [

	| visualization |
	visualization := self visualizationOf: self tree.
	self assert: visualization viewport identicalTo: visualization viewport
]

{ #category : 'tests' }
MiArchiBlVisualizationTest >> testViewportWithoutLayoutClassFails [
	"There is no default layout: the browser always gives one"

	| visualization |
	visualization := MiArchiBlVisualization new
		                 tree: self tree;
		                 tokenSource: space root;
		                 yourself.
	self should: [ visualization viewport ] raise: Error
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

{ #category : 'tests - lines' }
MiArchiBlVisualizationTest >> testZoomDoesNotRedrawLines [
	"The lines are in the canvas, which the zoom scales as a whole: they stay the same elements"

	| visualization line |
	visualization := self layOut: (self visualizationOf: self tree).
	line := self lineFrom: package1 to: package2 in: visualization.
	self wheel: 1 at: 100 @ 100 on: visualization.
	self assert: (self lineFrom: package1 to: package2 in: visualization) identicalTo: line
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
