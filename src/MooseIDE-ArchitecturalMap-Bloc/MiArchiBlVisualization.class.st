"
I draw with Bloc and Toplo the architectural map built by a `MiArchiBlTreeBuilder`: a box per visible node, an arrow per visible dependency, and the root boxes laid out by a `MiArchiBlLayout`. The map can be panned and zoomed with the mouse.

## Collaborators & Context
- `browser` (a `MiArchitecturalMapBrowserBl`, optional): inspects and propagates entities for the menu of the boxes.
- Vocabulary: a *node* is model data (a `MiArchiBlNode` of the tree, for an entity or a tag); a *box* is the Bloc element drawn for a node (`#boxOf:`, `#nodeOf:`); the *viewport* is the outermost Bloc element, the one shown, holding everything else.
- `MiArchiBlTreeBuilder` (`tree`): gives the root `MiArchiBlNode`s (`#roots`) and the `MiArchiBlDependency`s between the visible nodes (`#visibleDependencies`).
- `MiArchiBlLayout` subclasses (`layoutClass`): place the root boxes in `boxesLayer`. The browser chooses the layout: its `MiArchitecturalMapModel>>#layout`.
- `tokenSource`: an element already in a space (the space root). Its Toplo theme gives the colors (`#tokenNamed:`).
- `MiArchitecturalMapBrowserBl>>#showTree:` creates me in the Bloc UI process and puts my `#viewport` in its space.
- The Bloc elements I build: `viewport` (fills its parent, clips, gets the mouse) > `canvas` (frame layout with padding; moved and scaled) > from bottom to top `boxesLayer`, `halosLayer`, `linesLayer`.

## Assumptions & Invariants
- `tree`, `layoutClass` and `tokenSource` must all be set before `#viewport` is first sent.
- I am built once and lazily, the first time `#viewport` is sent. To show a changed tree (expand/collapse, other layout), make a new visualization.
- A node's box has its label (`ToLabel`). A box with children has a dashed border. A collapsed node's children get no box.
- Each box has its node in its `userData` at `#miArchitecturalMapNode`: that is the only link from boxes to nodes. Boxes are found by walking `boxesLayer` (`#boxes`, `#boxOf:`), not kept in a dictionary: a map has few boxes, and there is nothing to keep in sync when boxes are rebuilt.
- `linesLayer` and `boxesLayer` both fill the canvas, so they share their coordinates.
- Lines are drawn over the boxes (the boxes are filled and nested, lines under them would be hidden). A line goes from the border of the source box to the border of the target box, towards their centers, and ends with an arrow head (a `BlPolygonGeometry` triangle: this Bloc has no arrowheads) on the target border.
- Lines are redrawn after a layout of `boxesLayer` only if some box bounds changed (`lastBounds`), so the space can settle. The bounds are taken in the coordinates of the lines layer (`#placeOf:`), so zoom and pan, which move the canvas as a whole, redraw nothing: only moving boxes does.
- Each line has its dependency in its `userData` at `#miArchitecturalMapDependency`.
- Pan and zoom are kept in `origin` (where the canvas is in `viewport`) and `zoom`, and applied together by `#applyTransform` (absolute scale, top left origin). Zoom is around the mouse cursor, by 1.1 per wheel step, between `#minZoom` and `#maxZoom`. Dragging the background pans. Mouse positions are in space coordinates (`#position`, never `#screenPosition`).
- Moving boxes: dragging a box moves it, dragging the background pans. Drags are Bloc drag events (`BlDragStartEvent`, `BlDragEvent`, `BlDragEndEvent`): the space starts one after a press and a move of a few pixels, sends it to the element that consumed the drag start (the innermost box, see `#beDraggable:`, or else `viewport`), and ends it at the release. `lastDragPosition` is the mouse position at the previous drag event, for the move since then (`#dragDeltaOf:`). At the first move of a child, its container stops laying out its children (`#freezeLayoutOf:` replaces its layout by a `MiArchiBlFittingBasicLayout` with each child where it was): from then on it is as big as needed to contain all of them. So a parent box grows to contain a moved child, or a child drawn again bigger.
- Menu: each box is a Toplo element with a context menu (`#giveMenuTo:for:`), opened by a right click. Its items are chosen when it opens (`#menuItemsFor:`), in order:
  - Expand or Collapse, for a node with children: changes the node (`#isExpanded:`, `#toggle:`).
  - Relayout children, for an expanded node: its children go back to their grid (`#relayoutChildrenOf:`).
  Both draw only that box again, in place of the old one (`#redrawBoxOf:`): the other boxes stay where they are, even if moved by hand.
  - Hide or Show the incoming, outgoing or all links (`#linkItemsFor:`), only the items that would change something. A link is incoming (outgoing) for a box if its line ends (starts) at this very box, not at a box inside it. The nodes whose links are hidden are kept in `hiddenIncoming` and `hiddenOutgoing`; their lines are not drawn (`#isDrawn:`), and no box moves.
  - Inspect and Propagate the entity of the node: asked to `browser` (`#inspectEntity:`, `#propagateEntity:`), nothing without browser.
  A right press stops at the innermost box (`#keepRightClicksIn:`), so a box inside another does not open the menu of the outer one, nor the menu of the background.
- Menu of the background: `viewport` is a Toplo element too, with one item, Relayout all (`#giveMenuToViewport`, `#relayoutAll`): all the boxes are drawn again, placed by the layout of the map and the grids of the children, forgetting the moves by hand. Expansion, hidden links, zoom and pan are kept.
- Highlight: the mouse over a box (`BlMouseOverEvent`, which bubbles, handled on `viewport`) highlights the node of the innermost box under it (`#nodeUnder:`). Its dependencies both ways and the boxes at their other end get a halo (`#haloColor`), and keep their own look: both are drawn in `halosLayer` (over the boxes, under the lines): a box gets a translucent yellow ring just outside its bounds (`#haloForBox:). Over the background, or when the mouse leaves `viewport` (`BlMouseLeaveEvent`), nothing is highlighted. Only one node at a time is highlighted, and no state is kept: the halos are the highlight. Redrawing the lines removes them (they follow the old lines and boxes); since boxes move only while dragged, the end of a drag highlights again what is under the mouse (`#endDrag:`, `#highlightAt:`). While a box is dragged, nothing is highlighted.

## Main API
- `#browser:` the browser showing the map (optional).
- `#toggle:` a node: expand or collapse it, as its menu does. `#relayoutChildrenOf:` a node: lay out its children again. `#relayoutAll`: lay out all the boxes again.
- `MiArchiBlVisualization new tree: aTreeBuilder; layoutClass: aLayoutClass; tokenSource: aSpaceRoot; yourself`
- `#viewport`: the Bloc element to add to the space (built on first send). It shows the map: everything I draw is inside it.
- `#boxes`: all the boxes drawn. `#boxOf:` a node: its box, nil if it is not shown. `#nodeOf:` a box: its node (nil for any other element).
- `#zoomBy:` a wheel event, `#startDrag:` / `#dragDeltaOf:` / `#endDrag:` drag events (move a box or pan), `#panBy:` a point, `#highlight:` a node or nil: the mouse interactions.
- `#move:by:` a box and a delta in the coordinates of its parent.
- For the tests: `#linesLayer`, `#halosLayer`, `#origin`, `#zoom`.

"
Class {
	#name : 'MiArchiBlVisualization',
	#superclass : 'Object',
	#instVars : [
		'tree',
		'layoutClass',
		'tokenSource',
		'canvas',
		'linesLayer',
		'lastBounds',
		'zoom',
		'origin',
		'halosLayer',
		'viewport',
		'boxesLayer',
		'lastDragPosition',
		'browser',
		'hiddenIncoming',
		'hiddenOutgoing'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc-browser',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'browser'
}

{ #category : 'interactions' }
MiArchiBlVisualization >> applyTransform [
	"Put the canvas at origin, scaled by zoom around its top left corner. The scale is absolute, not cumulative"

	canvas position: origin.
	canvas transformDo: [ :builder |
			builder
				topLeftOrigin;
				scaleBy: zoom @ zoom ]
]

{ #category : 'lines' }
MiArchiBlVisualization >> arrowHeadAt: tipPoint from: startPoint [
	"A filled triangle with its tip at tipPoint, pointing away from startPoint"

	| direction unit normal base |
	direction := tipPoint - startPoint.
	unit := direction isZero
		        ifTrue: [ 1 @ 0 ]
		        ifFalse: [ direction / (direction x squared + direction y squared) sqrt ].
	normal := unit y negated @ unit x.
	base := tipPoint - (unit * self arrowHeadLength).
	^ BlElement new
		  constraintsDo: [ :c |
				  c horizontal matchParent.
				  c vertical matchParent ];
		  geometry: (BlPolygonGeometry vertices: {
						   tipPoint.
						   (base + (normal * self arrowHeadWidth / 2)).
						   (base - (normal * self arrowHeadWidth / 2)) });
		  background: self lineColor;
		  yourself
]

{ #category : 'lines' }
MiArchiBlVisualization >> arrowHeadLength [

	^ 8
]

{ #category : 'lines' }
MiArchiBlVisualization >> arrowHeadWidth [

	^ 7
]

{ #category : 'styling' }
MiArchiBlVisualization >> backgroundFor: aNode [

	^ aNode color ifNil: [ self tokenNamed: #'color-bg-container' ]
]

{ #category : 'interactions' }
MiArchiBlVisualization >> beDraggable: aBox [
	"Dragging aBox moves it within its parent (#move:by:), by the move of the mouse divided by the zoom, so it follows the mouse"

	aBox
		addEventHandlerOn: BlDragStartEvent do: [ :event | self startDrag: event ];
		addEventHandlerOn: BlDragEvent do: [ :event | self move: event currentTarget by: (self dragDeltaOf: event) / zoom ];
		addEventHandlerOn: BlDragEndEvent do: [ :event | self endDrag: event ]
]

{ #category : 'styling' }
MiArchiBlVisualization >> borderFor: aNode [
	"Dashed for a node with children, as in Roassal (MiArchitecturalMapBuilder>>borderFor:)"

	^ aNode hasChildren
		  ifTrue: [
				  BlBorder builder
					  paint: (self tokenNamed: #'color-text');
					  width: 2;
					  dashed;
					  build ]
		  ifFalse: [ BlBorder paint: (self tokenNamed: #'color-border') width: 2 ]
]

{ #category : 'lines' }
MiArchiBlVisualization >> borderPointOf: aRectangle towards: aPoint [
	"Where the segment from the center of aRectangle to aPoint crosses the border of aRectangle (the center itself when aPoint is the center)"

	| center direction scale |
	center := aRectangle center.
	direction := aPoint - center.
	direction isZero ifTrue: [ ^ center ].
	scale := direction x = 0
		         ifTrue: [ aRectangle height / 2 / direction y abs ]
		         ifFalse: [
				         direction y = 0
					         ifTrue: [ aRectangle width / 2 / direction x abs ]
					         ifFalse: [ aRectangle width / 2 / direction x abs min: aRectangle height / 2 / direction y abs ] ].
	^ center + (direction * scale)
]

{ #category : 'lines' }
MiArchiBlVisualization >> boundsOf: anElement [
	"The bounds of anElement in the coordinates of the lines layer"

	^ Rectangle encompassing: {
			  (linesLayer globalPointToLocal: (anElement localPointToGlobal: 0 @ 0)).
			  (linesLayer globalPointToLocal: (anElement localPointToGlobal: anElement extent)) }
]

{ #category : 'boxes' }
MiArchiBlVisualization >> boxContaining: anElement [
	"The innermost box containing anElement (a box, its label...), anElement itself if it is a box, nil if it is not in a box"

	| current |
	current := anElement.
	[ current isNil or: [ current == viewport ] ] whileFalse: [
			(self nodeOf: current) ifNotNil: [ ^ current ].
			current := current parent ].
	^ nil
]

{ #category : 'building' }
MiArchiBlVisualization >> boxForNode: aNode [
	"The box of aNode: its label, then (when expanded) the container of the boxes of its children (#childrenContainerFor:). It knows its node (#nodeOf:), can be dragged (#beDraggable:), and has a context menu (#giveMenuTo:for:). A Toplo element, for the menu"

	| box |
	box := ToElement new
		       layout: BlLinearLayout vertical;
		       padding: (BlInsets all: 6);
		       margin: (BlInsets all: 8);
		       background: (self backgroundFor: aNode);
		       border: (self borderFor: aNode);
		       addChild: (ToLabel new text: aNode name);
		       yourself.
	box constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ].
	box userData at: #miArchitecturalMapNode put: aNode.
	self beDraggable: box.
	self giveMenuTo: box for: aNode.
	self keepRightClicksIn: box.
	(aNode isExpanded and: [ aNode hasChildren ]) ifTrue: [ box addChild: (self childrenContainerFor: aNode) ].
	^ box
]

{ #category : 'boxes' }
MiArchiBlVisualization >> boxOf: aNode [
	"The box drawn for aNode, nil if aNode is not shown (a child of a collapsed node)"

	^ boxesLayer allChildrenBreadthFirstDetect: [ :each | (self nodeOf: each) == aNode ] ifFound: [ :box | box ] ifNone: [ nil ]
]

{ #category : 'boxes' }
MiArchiBlVisualization >> boxUnder: aMouseEvent [
	"The innermost box under the mouse, nil on the background. Mouse events bubble up from the Bloc element under the mouse (a box, its label...)"

	^ self boxContaining: aMouseEvent target
]

{ #category : 'boxes' }
MiArchiBlVisualization >> boxes [
	"All the boxes drawn, found in the boxes layer: the elements that know their node. A map has few boxes, so they are looked up rather than kept in a dictionary"

	^ boxesLayer allChildrenBreadthFirstSelect: [ :each | (self nodeOf: each) isNotNil ]
]

{ #category : 'accessing' }
MiArchiBlVisualization >> browser: aBrowser [
	"The browser showing me (a MiArchitecturalMapBrowserBl): the menu of a box asks it to inspect or propagate the entity of the node (#inspectEntity:, #propagateEntity:). Optional: without browser, these items do nothing"

	browser := aBrowser
]

{ #category : 'building' }
MiArchiBlVisualization >> build [
	"Build and answer the viewport showing the map. It contains the canvas, which contains, from bottom to top, the boxes layer, the halos layer and the lines layer.
	The order matters: the canvas needs the layers, the viewport needs the canvas"

	self buildBoxesLayer.
	self buildHalosLayer.
	self buildLinesLayer.
	self buildCanvas.
	self buildViewport.
	^ viewport
]

{ #category : 'building' }
MiArchiBlVisualization >> buildBoxesLayer [
	"The layer of the boxes (#fillBoxesLayer). The lines follow the boxes each time a layout is computed"

	boxesLayer := BlElement new.
	self fillBoxesLayer.
	boxesLayer addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self updateLines ]
]

{ #category : 'building' }
MiArchiBlVisualization >> buildCanvas [
	"The lines over the nodes: the boxes are filled, and nested when expanded, so lines under them would be hidden. The halos of the highlighted lines are between them. Moved (origin) and zoomed by #applyTransform"

	canvas := BlElement new
		          layout: BlFrameLayout new;
		          padding: (BlInsets all: 20);
		          addChildren: {
				          boxesLayer.
				          halosLayer.
				          linesLayer };
		          yourself.
	canvas constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ]
]

{ #category : 'building' }
MiArchiBlVisualization >> buildHalosLayer [
	"The halos of the highlighted lines: over the boxes, under the lines. Like the lines layer, it fills the canvas and ignores the mouse"

	halosLayer := BlElement new
		              layout: BlBasicLayout new;
		              clipChildren: false;
		              preventMeAndChildrenMouseEvents;
		              yourself.
	halosLayer constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ]
]

{ #category : 'building' }
MiArchiBlVisualization >> buildLinesLayer [
	"The layer of the lines, over the boxes and out of the mouse events (they go to the boxes under it). It fills the canvas like the boxes layer (both are children of a frame layout with the same padding), so the two share their coordinates and the lines layer never needs to be moved"

	linesLayer := BlElement new
		              layout: BlBasicLayout new;
		              clipChildren: false;
		              preventMeAndChildrenMouseEvents;
		              yourself.
	linesLayer constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ]
]

{ #category : 'building' }
MiArchiBlVisualization >> buildViewport [
	"The viewport shown: it fills its parent and clips the canvas. It receives the mouse: wheel to zoom, drag on the background to pan (the zoom and pan pattern of the Bloc guide on graphical patterns), over to highlight the dependencies of the box under the mouse, leave to remove the highlight, right click on the background for its menu (a Toplo element for it, #giveMenuToViewport).
	Drags are Bloc drag events: the space turns a press followed by a move of a few pixels into them, sends them to the element that took the drag start, and ends them at the release, wherever it happens. A drag on a box is taken by the box (#beDraggable:), so it does not reach the viewport"

	viewport := ToElement new
		            layout: BlBasicLayout new;
		            clipChildren: true;
		            addChild: canvas;
		            yourself.
	viewport constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ].
	viewport
		addEventHandlerOn: BlMouseWheelEvent do: [ :event | self zoomBy: event ];
		addEventHandlerOn: BlDragStartEvent do: [ :event | self startDrag: event ];
		addEventHandlerOn: BlDragEvent do: [ :event | self panBy: (self dragDeltaOf: event) ];
		addEventHandlerOn: BlDragEndEvent do: [ :event | self endDrag: event ];
		addEventHandlerOn: BlMouseOverEvent do: [ :event | self highlight: (self nodeUnder: event) ];
		addEventHandlerOn: BlMouseLeaveEvent do: [ :event | self highlight: nil ].
	self giveMenuToViewport
]

{ #category : 'building' }
MiArchiBlVisualization >> childrenContainerFor: aNode [
	"The element under the label of the box of aNode, holding the boxes of its children (built by #boxForNode:, so recursively). It exists for its layout: the box lays out its label and this element vertically, this element lays out the boxes in a square grid (MiArchiBlGridLayout: as many columns as the square root of their number), not in one long line. It is not a box: no node, no menu, nothing drawn, so a plain Bloc element. It is what #freezeLayoutOf: freezes when one of these boxes is moved"

	| container |
	container := BlElement new.
	MiArchiBlGridLayout new applyOn: container topElementsCount: aNode children size.
	^ container
		  addChildren: (aNode children collect: [ :each | self boxForNode: each ]);
		  yourself
]

{ #category : 'interactions' }
MiArchiBlVisualization >> dragDeltaOf: aDragEvent [
	"How far the mouse moved since the previous drag event (or the press), in space coordinates, not screen ones (which change when the window moves). Consumed: a box handles its own drag, its parents do not"

	| delta |
	aDragEvent consume.
	delta := aDragEvent position - lastDragPosition.
	lastDragPosition := aDragEvent position.
	^ delta
]

{ #category : 'interactions' }
MiArchiBlVisualization >> endDrag: aDragEndEvent [
	"The boxes may have moved, removing the halos (#updateLines): highlight again what is under the mouse at the release"

	aDragEndEvent consume.
	lastDragPosition := nil.
	self highlightAt: aDragEndEvent position
]

{ #category : 'building' }
MiArchiBlVisualization >> fillBoxesLayer [
	"The boxes of the root nodes, placed by the layout of the map, each with its children in their grid"

	layoutClass new applyOn: boxesLayer topElementsCount: tree roots size.
	boxesLayer addChildren: (tree roots collect: [ :each | self boxForNode: each ])
]

{ #category : 'moving' }
MiArchiBlVisualization >> freezeLayoutOf: aContainer [
	"Replace the layout of aContainer (flow, grid...) by explicit positions: each child stays where the layout put it. Done once, at the first move of one of its children. From then on, aContainer is as big as needed to contain its children (MiArchiBlFittingBasicLayout): it grows when one is moved, or drawn again bigger"

	| positions |
	(aContainer layout isKindOf: MiArchiBlFittingBasicLayout) ifTrue: [ ^ self ].
	positions := aContainer children collect: [ :each | each -> each position ].
	aContainer layout: MiArchiBlFittingBasicLayout new.
	aContainer constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ].
	positions do: [ :each | each key position: each value ]
]

{ #category : 'menu' }
MiArchiBlVisualization >> giveMenuTo: aBox for: aNode [
	"The context menu of aBox (opened by a right click, by Toplo). Its items are chosen when it opens (#menuItemsFor:), so they follow the state of aNode"

	aBox contextMenuBuilder: [ :menu :request | (self menuItemsFor: aNode) do: [ :each | menu addItem: each ] ]
]

{ #category : 'menu' }
MiArchiBlVisualization >> giveMenuToViewport [
	"The context menu of the background of the map (a right click on a box opens the menu of the box instead, #keepRightClicksIn:): Relayout all"

	viewport contextMenuBuilder: [ :menu :request | menu addItem: (self menuItem: 'Relayout all' do: [ self relayoutAll ]) ]
]

{ #category : 'styling' }
MiArchiBlVisualization >> haloColor [

	^ Color yellow
]

{ #category : 'highlight' }
MiArchiBlVisualization >> haloForBox: aBox [
	"A translucent yellow ring around aBox, drawn just outside its bounds (a gaussian shadow is too faint on a light background)"

	| bounds |
	bounds := self boundsOf: aBox.
	^ BlElement new
		  geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
		  border: (BlBorder paint: (self haloColor alpha: 0.7) width: 3);
		  outskirts: BlOutskirts outside;
		  position: bounds origin;
		  extent: bounds extent;
		  yourself
]

{ #category : 'highlight' }
MiArchiBlVisualization >> haloForLine: aLine [
	"A thin translucent yellow stroke along aLine, with round ends (Bloc shadows do not follow the stroke of a line)"

	^ BlElement new
		  constraintsDo: [ :c |
				  c horizontal matchParent.
				  c vertical matchParent ];
		  geometry: (BlLineGeometry from: aLine geometry from to: aLine geometry to);
		  outskirts: BlOutskirts centered;
		  border: (BlBorder builder
				   paint: (self haloColor alpha: 0.35);
				   width: 3;
				   lineCap: BlStrokeLineCap round;
				   build);
		  yourself
]

{ #category : 'testing' }
MiArchiBlVisualization >> halosLayer [
	"The element holding the halos of the highlighted lines (for the tests)"

	^ halosLayer
]

{ #category : 'menu' }
MiArchiBlVisualization >> hide: someHiddenSets linksOf: aNode [
	"someHiddenSets: hiddenIncoming and/or hiddenOutgoing. Only the lines change: no box moves"

	someHiddenSets do: [ :each | each add: aNode ].
	self redrawLines
]

{ #category : 'highlight' }
MiArchiBlVisualization >> highlight: aNodeOrNil [
	"The dependencies of aNodeOrNil (both ways) and the boxes at their other end get a yellow halo in the halos layer; the lines and boxes keep their look. For nil, nothing is highlighted"

	| remoteNodes |
	halosLayer removeChildren.
	aNodeOrNil ifNil: [ ^ self ].
	remoteNodes := IdentitySet new.
	linesLayer children do: [ :line |
			| dependency |
			dependency := line userData at: #miArchitecturalMapDependency.
			(dependency source == aNodeOrNil or: [ dependency target == aNodeOrNil ]) ifTrue: [
					remoteNodes add: (dependency source == aNodeOrNil
							 ifTrue: [ dependency target ]
							 ifFalse: [ dependency source ]).
					halosLayer addChild: (self haloForLine: line) ] ].
	remoteNodes do: [ :node | halosLayer addChild: (self haloForBox: (self boxOf: node)) ]
]

{ #category : 'highlight' }
MiArchiBlVisualization >> highlightAt: aPoint [
	"Highlight the node of the innermost box at aPoint (space coordinates), as the mouse coming over it would, or nothing on the background"

	self highlight:
		((self boxContaining: (viewport space root findMouseEventTargetAt: aPoint)) ifNotNil: [ :box | self nodeOf: box ])
]

{ #category : 'initialization' }
MiArchiBlVisualization >> initialize [

	super initialize.
	lastBounds := #(  ).
	origin := 0 @ 0.
	zoom := 1.
	hiddenIncoming := IdentitySet new.
	hiddenOutgoing := IdentitySet new
]

{ #category : 'lines' }
MiArchiBlVisualization >> isDrawn: aDependency [
	"False if its line was hidden from the menu of its source box (outgoing links) or of its target box (incoming links)"

	^ ((hiddenOutgoing includes: aDependency source) or: [ hiddenIncoming includes: aDependency target ]) not
]

{ #category : 'menu' }
MiArchiBlVisualization >> keepRightClicksIn: aBox [
	"A right press on aBox stops there: it does not go up to the boxes around aBox, which would open their menus. Installed after the menu of aBox, which sees the press first"

	aBox addEventHandlerOn: BlMouseDownEvent do: [ :event | event button = BlMouseButton secondary ifTrue: [ event consume ] ]
]

{ #category : 'accessing' }
MiArchiBlVisualization >> layoutClass: aLayoutClass [
	"A subclass of MiArchiBlLayout (required before #viewport)"

	layoutClass := aLayoutClass
]

{ #category : 'styling' }
MiArchiBlVisualization >> lineColor [

	^ (self tokenNamed: #'color-text-secondary') alpha: 0.5
]

{ #category : 'lines' }
MiArchiBlVisualization >> lineElementFor: aDependency [
	"A line from the border of the source box to the border of the target box, ended by an arrow head on the border of the target"

	| sourceBounds targetBounds from to line |
	sourceBounds := self boundsOf: (self boxOf: aDependency source).
	targetBounds := self boundsOf: (self boxOf: aDependency target).
	from := self borderPointOf: sourceBounds towards: targetBounds center.
	to := self borderPointOf: targetBounds towards: sourceBounds center.
	line := BlElement new
		        constraintsDo: [ :c |
				        c horizontal matchParent.
				        c vertical matchParent ];
		        clipChildren: false;
		        geometry: (BlLineGeometry from: from to: to);
		        outskirts: BlOutskirts centered;
		        border: (BlBorder paint: self lineColor width: 1);
		        addChild: (self arrowHeadAt: to from: from);
		        yourself.
	line userData at: #miArchitecturalMapDependency put: aDependency.
	^ line
]

{ #category : 'testing' }
MiArchiBlVisualization >> linesLayer [
	"The element holding the lines, under the boxes (for the tests)"

	^ linesLayer
]

{ #category : 'menu' }
MiArchiBlVisualization >> linkItemsFor: aNode [
	"Hide or show the incoming, outgoing or all links of the box of aNode: only the items that would change something. A link is incoming (outgoing) if its line ends (starts) at this box: lines of the boxes inside it are not concerned"

	| dependencies hasIncoming hasOutgoing canHideIncoming canHideOutgoing canShowIncoming canShowOutgoing items |
	dependencies := self shownDependencies.
	hasIncoming := dependencies anySatisfy: [ :each | each target == aNode ].
	hasOutgoing := dependencies anySatisfy: [ :each | each source == aNode ].
	canHideIncoming := hasIncoming and: [ (hiddenIncoming includes: aNode) not ].
	canShowIncoming := hasIncoming and: [ hiddenIncoming includes: aNode ].
	canHideOutgoing := hasOutgoing and: [ (hiddenOutgoing includes: aNode) not ].
	canShowOutgoing := hasOutgoing and: [ hiddenOutgoing includes: aNode ].
	items := OrderedCollection new.
	canHideIncoming ifTrue: [ items add: (self menuItem: 'Hide incoming links' do: [ self hide: { hiddenIncoming } linksOf: aNode ]) ].
	canHideOutgoing ifTrue: [ items add: (self menuItem: 'Hide outgoing links' do: [ self hide: { hiddenOutgoing } linksOf: aNode ]) ].
	(canHideIncoming or: [ canHideOutgoing ]) ifTrue: [
			items add: (self menuItem: 'Hide all links' do: [
						 self
							 hide: {
									 hiddenIncoming.
									 hiddenOutgoing }
							 linksOf: aNode ]) ].
	canShowIncoming ifTrue: [ items add: (self menuItem: 'Show incoming links' do: [ self show: { hiddenIncoming } linksOf: aNode ]) ].
	canShowOutgoing ifTrue: [ items add: (self menuItem: 'Show outgoing links' do: [ self show: { hiddenOutgoing } linksOf: aNode ]) ].
	(canShowIncoming or: [ canShowOutgoing ]) ifTrue: [
			items add: (self menuItem: 'Show all links' do: [
						 self
							 show: {
									 hiddenIncoming.
									 hiddenOutgoing }
							 linksOf: aNode ]) ].
	^ items
]

{ #category : 'interactions' }
MiArchiBlVisualization >> maxZoom [

	^ 10
]

{ #category : 'menu' }
MiArchiBlVisualization >> menuItem: aLabel do: aBlock [

	^ (ToMenuItem new labelText: aLabel)
		  clickAction: aBlock;
		  yourself
]

{ #category : 'menu' }
MiArchiBlVisualization >> menuItemsFor: aNode [
	"The items of the menu of the box of aNode, in order: Expand or Collapse (if aNode has children), Relayout children (if it is expanded), the links items that would change something (#linkItemsFor:), Inspect, Propagate"

	| items |
	items := OrderedCollection new.
	aNode hasChildren ifTrue: [
			items add: (self
					 menuItem: (aNode isExpanded
							  ifTrue: [ 'Collapse' ]
							  ifFalse: [ 'Expand' ])
					 do: [ self toggle: aNode ]).
			aNode isExpanded ifTrue: [ items add: (self menuItem: 'Relayout children' do: [ self relayoutChildrenOf: aNode ]) ] ].
	items addAll: (self linkItemsFor: aNode).
	items add: (self menuItem: 'Inspect' do: [ browser ifNotNil: [ browser inspectEntity: aNode entity ] ]).
	items add: (self menuItem: 'Propagate' do: [ browser ifNotNil: [ browser propagateEntity: aNode entity ] ]).
	^ items
]

{ #category : 'interactions' }
MiArchiBlVisualization >> minZoom [

	^ 0.1
]

{ #category : 'interactions' }
MiArchiBlVisualization >> move: aBox by: aPoint [
	"Move aBox by aPoint (in the coordinates of its parent, so unzoomed) from where it is. Its parent stops laying out its children: they stay where they are. The parent grows to the right and down to contain the moved box; to the left and up, the box stops at the edge of its parent (keeping its margin)"

	self freezeLayoutOf: aBox parent.
	aBox position: (aBox measuredBounds position + aPoint max: aBox margin left @ aBox margin top)
]

{ #category : 'boxes' }
MiArchiBlVisualization >> nodeOf: anElement [
	"The node of anElement if it is a box, nil otherwise"

	^ anElement userData at: #miArchitecturalMapNode ifAbsent: [ nil ]
]

{ #category : 'highlight' }
MiArchiBlVisualization >> nodeUnder: aMouseEvent [
	"The node of the innermost box under the mouse, nil on the background"

	^ (self boxUnder: aMouseEvent) ifNotNil: [ :box | self nodeOf: box ]
]

{ #category : 'testing' }
MiArchiBlVisualization >> origin [
	"Where the canvas is in the element: changed by panning and by zooming around the cursor (for the tests)"

	^ origin
]

{ #category : 'interactions' }
MiArchiBlVisualization >> panBy: aPoint [
	"Move the map by aPoint, in space coordinates"

	origin := origin + aPoint.
	self applyTransform
]

{ #category : 'lines' }
MiArchiBlVisualization >> placeOf: aBox [
	"The bounds of aBox in the coordinates of the lines layer, rounded to a hundredth of a pixel: the conversion goes out through the zoom of the canvas and back, which adds floating point noise (8.000000000000004 for 8) that must not count as a move"

	| bounds |
	bounds := self boundsOf: aBox.
	^ (bounds origin roundTo: 0.01) corner: (bounds corner roundTo: 0.01)
]

{ #category : 'expanding' }
MiArchiBlVisualization >> redrawBoxOf: aNode [
	"Draw the box of aNode again, in the place of the old one: the other boxes are not drawn again, so they stay where they are (even moved by hand). The new box keeps the position of the old one (used if its container was frozen by a move, #freezeLayoutOf:), and its children are laid out from scratch"

	| oldBox newBox |
	oldBox := self boxOf: aNode.
	newBox := self boxForNode: aNode.
	newBox position: oldBox position.
	oldBox parent replaceChild: oldBox with: newBox
]

{ #category : 'lines' }
MiArchiBlVisualization >> redrawLines [
	"Draw the lines again, though no box moved (the hidden links changed)"

	lastBounds := nil.
	self updateLines
]

{ #category : 'menu' }
MiArchiBlVisualization >> relayoutAll [
	"Draw all the boxes again, placed by the layout of the map and the grids of the children, forgetting where they were moved by hand. The nodes stay expanded or collapsed, the hidden links stay hidden; zoom and pan do not change"

	boxesLayer removeChildren.
	self fillBoxesLayer
]

{ #category : 'expanding' }
MiArchiBlVisualization >> relayoutChildrenOf: aNode [
	"Lay out the children of aNode (expanded) again in their grid, forgetting where they were moved by hand (also inside them): draw the box of aNode again (#redrawBoxOf:)"

	self redrawBoxOf: aNode
]

{ #category : 'menu' }
MiArchiBlVisualization >> show: someHiddenSets linksOf: aNode [

	someHiddenSets do: [ :each | each remove: aNode ifAbsent: [ ] ].
	self redrawLines
]

{ #category : 'lines' }
MiArchiBlVisualization >> shownDependencies [
	"The dependencies between two nodes that have a box, hidden or not"

	| shownNodes |
	shownNodes := (self boxes collect: [ :each | self nodeOf: each ]) asIdentitySet.
	^ tree visibleDependencies select: [ :each | (shownNodes includes: each source) and: [ shownNodes includes: each target ] ]
]

{ #category : 'interactions' }
MiArchiBlVisualization >> startDrag: aDragStartEvent [
	"A drag starts on a box or on the background. Consuming the event makes the element handling it (a box, or the viewport) the target of the next drag events, as decided by the mouse processor of the space; it also stops the event there, so only the innermost box under the mouse moves"

	aDragStartEvent consume.
	lastDragPosition := aDragStartEvent position
]

{ #category : 'expanding' }
MiArchiBlVisualization >> toggle: aNode [
	"Expand aNode if it is collapsed, collapse it otherwise, and draw its box again (#redrawBoxOf:)"

	aNode isExpanded: aNode isExpanded not.
	self redrawBoxOf: aNode
]

{ #category : 'styling' }
MiArchiBlVisualization >> tokenNamed: aSymbol [

	^ tokenSource valueOfTokenNamed: aSymbol
]

{ #category : 'accessing' }
MiArchiBlVisualization >> tokenSource: anElement [
	"An element in a space, whose Toplo theme gives the colors"

	tokenSource := anElement
]

{ #category : 'accessing' }
MiArchiBlVisualization >> tree: aTree [

	tree := aTree
]

{ #category : 'lines' }
MiArchiBlVisualization >> updateLines [
	"Draw again the lines between the boxes, only if they moved since the last time: a layout is computed often, and a handler of BlElementLayoutComputedEvent must only change what differs, or the space never settles.
	The bounds are compared in the coordinates of the lines layer (#placeOf:): zoom and pan move the canvas as a whole, they change where the boxes are in the space but not there, so they redraw nothing.
	The lines hidden from the menu of a box are not drawn (#isDrawn:).
	The halos follow the old lines and boxes: they are removed. Boxes move only while dragged, and the end of a drag highlights again (#endDrag:)"

	| bounds |
	bounds := self boxes collect: [ :each | self placeOf: each ].
	bounds = lastBounds ifTrue: [ ^ self ].
	lastBounds := bounds.
	linesLayer removeChildren.
	linesLayer addChildren:
		((self shownDependencies select: [ :each | self isDrawn: each ]) collect: [ :each | self lineElementFor: each ]).
	halosLayer removeChildren
]

{ #category : 'accessing' }
MiArchiBlVisualization >> viewport [

	^ viewport ifNil: [ self build ]
]

{ #category : 'testing' }
MiArchiBlVisualization >> zoom [
	"The current zoom factor of the map, 1 at first (for the tests)"

	^ zoom
]

{ #category : 'interactions' }
MiArchiBlVisualization >> zoomBy: aWheelEvent [
	"Zoom in (wheel up) or out, around the mouse cursor, between #minZoom and #maxZoom"

	| newZoom cursor |
	newZoom := (zoom * (aWheelEvent isScrollUp
		             ifTrue: [ 1.1 ]
		             ifFalse: [ 1 / 1.1 ]) min: self maxZoom) max: self minZoom.
	cursor := viewport globalPointToLocal: aWheelEvent position.
	origin := cursor - (newZoom / zoom * (cursor - origin)).
	zoom := newZoom.
	self applyTransform.
	aWheelEvent consumed: true
]
