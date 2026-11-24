"
I draw with Bloc and Toplo the architectural map built by a `MiArchiBlTreeBuilder`: a box per visible node, an arrow per visible dependency, and the root boxes laid out by a `MiArchiBlLayout`. The map can be panned and zoomed with the mouse.

## Collaborators & Context
- `MiArchiBlTreeBuilder` (`tree`): gives the root `MiArchiBlNode`s (`#roots`) and the `MiArchiBlDependency`s between the visible nodes (`#visibleDependencies`).
- `MiArchiBlLayout` subclasses (`layoutClass`): place the root boxes in `nodesLayer`. The browser chooses the layout: its `MiArchitecturalMapModel>>#layout`, by default `MiArchitecturalMapBrowserBl>>#defaultMapLayout`.
- `tokenSource`: an element already in a space (the space root). Its Toplo theme gives the colors (`#tokenNamed:`).
- `MiArchitecturalMapBrowserBl>>#showTree:` creates me in the Bloc UI process and puts my `#element` in its space.
- The element tree I build: `element` (fills its parent, clips, gets the mouse) > `canvas` (frame layout with padding; moved and scaled) > `nodesLayer` under `linesLayer`.
- Bloc documentation followed (github.com/pharo-graphics/Bloc, doc/): LayoutAndConstraints (position is a request; layout handlers change only what differs) and GraphicalPatterns (zoom and pan).

## Assumptions & Invariants
- `tree`, `layoutClass` and `tokenSource` must all be set before `#element` is first sent. There is no default layout.
- I am built once and lazily, the first time `#element` is sent. To show a changed tree (expand/collapse, other layout), make a new visualization.
- A node's box has its label (`ToLabel`). A tag's box has the tag's color, and a box with children has a dashed border. A collapsed node's children get no box.
- `elementsByNode` maps each node that has a box to that box. Each box also has its node in its `userData` at `#miArchitecturalMapNode`.
- `linesLayer` and `nodesLayer` both fill the canvas, so they share their coordinates: the lines layer is never moved. Its children (one per line, filling it) are not clipped.
- Lines are drawn over the boxes (the boxes are filled and nested, lines under them would be hidden), and ignore the mouse. A line goes from the border of the source box to the border of the target box, towards their centers, and ends with an arrow head (a `BlPolygonGeometry` triangle: this Bloc has no arrowheads) on the target border.
- Lines are redrawn after a layout of `nodesLayer` only if some box bounds changed (`lastBounds`, kept as copies since `#boundsInSpace` is changed in place), so the space can settle.
- Each line has its dependency in its `userData` at `#miArchitecturalMapDependency`.
- Pan and zoom are kept in `origin` (where the canvas is in `element`) and `zoom`, and applied together by `#applyTransform` (absolute scale, top left origin). Zoom is around the mouse cursor, by 1.1 per wheel step, between `#minZoom` and `#maxZoom`. Dragging with the mouse pressed pans. Mouse positions are in space coordinates (`#position`, never `#screenPosition`).
- Highlight: the mouse over a box (`BlMouseOverEvent`, which bubbles, handled on `element`) highlights the node of the innermost box under it (`#nodeUnder:`, walking up from the event target). Its dependencies both ways (lines and arrow heads) are drawn in the theme's accent color (`color-primary`), 2 pixels wide, and the boxes at their other end get a border of that color (same style, dashed or not). Over the background, or when the mouse leaves `element` (`BlMouseLeaveEvent`), nothing is highlighted. Only one node at a time (`highlightedNode`); the highlight is reapplied when the lines are redrawn.
- Not thread-safe: once my element is in an opened space, use me only from its UI process (`BlSpace>>#defer:`).

## Main API
- `MiArchiBlVisualization new tree: aTreeBuilder; layoutClass: aLayoutClass; tokenSource: aSpaceRoot; yourself`
- `#element`: the element to add to the space (built on first send).
- `#elementsByNode`: the box of each displayed node.
- `#zoomBy:` a wheel event, `#panBy:` a move event, `#highlight:` a node or nil: the mouse interactions.
- For the tests: `#linesLayer`, `#origin`, `#zoom`.

"
Class {
	#name : 'MiArchiBlVisualization',
	#superclass : 'Object',
	#instVars : [
		'tree',
		'layoutClass',
		'tokenSource',
		'element',
		'canvas',
		'nodesLayer',
		'linesLayer',
		'elementsByNode',
		'lastBounds',
		'zoom',
		'origin',
		'dragFrom',
		'highlightedNode'
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

{ #category : 'building' }
MiArchiBlVisualization >> build [
	"Build and answer the element showing the map. It contains the canvas, which contains the lines layer under the nodes layer.
	The order matters: the canvas needs both layers, the element needs the canvas"

	self buildNodesLayer.
	self buildLinesLayer.
	self buildCanvas.
	self buildElement.
	^ element
]

{ #category : 'building' }
MiArchiBlVisualization >> buildCanvas [
	"The lines over the nodes: the boxes are filled, and nested when expanded, so lines under them would be hidden. Moved (origin) and zoomed by #applyTransform"

	canvas := BlElement new
		          layout: BlFrameLayout new;
		          padding: (BlInsets all: 20);
		          addChildren: {
				          nodesLayer.
				          linesLayer };
		          yourself.
	canvas constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ]
]

{ #category : 'building' }
MiArchiBlVisualization >> buildElement [
	"The element shown: it fills its parent and clips the canvas. It receives the mouse: wheel to zoom, drag to pan (the zoom and pan pattern of the Bloc guide on graphical patterns), over to highlight the dependencies of the box under the mouse, leave to remove the highlight"

	element := BlElement new
		           layout: BlBasicLayout new;
		           clipChildren: true;
		           addChild: canvas;
		           yourself.
	element constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ].
	element
		addEventHandlerOn: BlMouseWheelEvent do: [ :event | self zoomBy: event ];
		addEventHandlerOn: BlMouseDownEvent do: [ :event | dragFrom := event position ];
		addEventHandlerOn: BlMouseMoveEvent do: [ :event | self panBy: event ];
		addEventHandlerOn: BlMouseUpEvent do: [ :event | dragFrom := nil ];
		addEventHandlerOn: BlMouseOverEvent do: [ :event | self highlight: (self nodeUnder: event) ];
		addEventHandlerOn: BlMouseLeaveEvent do: [ :event | self highlight: nil ]
]

{ #category : 'building' }
MiArchiBlVisualization >> buildLinesLayer [
	"The layer of the lines, over the nodes and out of the mouse events (they go to the boxes under it). It fills the canvas like the nodes layer (both are children of a frame layout with the same padding), so the two share their coordinates and the lines layer never needs to be moved"

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
MiArchiBlVisualization >> buildNodesLayer [
	"The boxes of the root nodes, placed by the layout. The lines follow them each time a layout is computed"

	nodesLayer := BlElement new.
	layoutClass new applyOn: nodesLayer topElementsCount: tree roots size.
	nodesLayer addChildren: (tree roots collect: [ :each | self elementForNode: each ]).
	nodesLayer addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self updateLines ]
]

{ #category : 'accessing' }
MiArchiBlVisualization >> element [

	^ element ifNil: [ self build ]
]

{ #category : 'building' }
MiArchiBlVisualization >> elementForNode: aNode [
	"The box of aNode: its label, then (when expanded) the boxes of its children"

	| box |
	box := BlElement new
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
	(aNode isExpanded and: [ aNode hasChildren ]) ifTrue: [
			box addChild: (BlElement new
					 layout: BlFlowLayout horizontal;
					 constraintsDo: [ :c |
							 c horizontal fitContent.
							 c vertical fitContent ];
					 addChildren: (aNode children collect: [ :each | self elementForNode: each ]);
					 yourself) ].
	elementsByNode at: aNode put: box.
	^ box
]

{ #category : 'accessing' }
MiArchiBlVisualization >> elementsByNode [

	^ elementsByNode
]

{ #category : 'highlight' }
MiArchiBlVisualization >> highlight: aNodeOrNil [
	"Show the dependencies of aNodeOrNil (none for nil)"

	highlightedNode := aNodeOrNil.
	self updateHighlight
]

{ #category : 'highlight' }
MiArchiBlVisualization >> highlightColor [

	^ self tokenNamed: #'color-primary'
]

{ #category : 'initialization' }
MiArchiBlVisualization >> initialize [

	super initialize.
	elementsByNode := IdentityDictionary new.
	lastBounds := #(  ).
	origin := 0 @ 0.
	zoom := 1
]

{ #category : 'accessing' }
MiArchiBlVisualization >> layoutClass: aLayoutClass [
	"A subclass of MiArchiBlLayout (required before #element)"

	layoutClass := aLayoutClass
]

{ #category : 'styling' }
MiArchiBlVisualization >> lineBorderHighlighted: aBoolean [

	^ aBoolean
		  ifTrue: [ BlBorder paint: self highlightColor width: 2 ]
		  ifFalse: [ BlBorder paint: self lineColor width: 1 ]
]

{ #category : 'styling' }
MiArchiBlVisualization >> lineColor [

	^ (self tokenNamed: #'color-text-secondary') alpha: 0.5
]

{ #category : 'lines' }
MiArchiBlVisualization >> lineElementFor: aDependency [
	"A line from the border of the source box to the border of the target box, ended by an arrow head on the border of the target"

	| sourceBounds targetBounds from to line |
	sourceBounds := self boundsOf: (elementsByNode at: aDependency source).
	targetBounds := self boundsOf: (elementsByNode at: aDependency target).
	from := self borderPointOf: sourceBounds towards: targetBounds center.
	to := self borderPointOf: targetBounds towards: sourceBounds center.
	line := BlElement new
		        constraintsDo: [ :c |
				        c horizontal matchParent.
				        c vertical matchParent ];
		        clipChildren: false;
		        geometry: (BlLineGeometry from: from to: to);
		        outskirts: BlOutskirts centered;
		        border: (self lineBorderHighlighted: false);
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

{ #category : 'interactions' }
MiArchiBlVisualization >> maxZoom [

	^ 10
]

{ #category : 'interactions' }
MiArchiBlVisualization >> minZoom [

	^ 0.1
]

{ #category : 'highlight' }
MiArchiBlVisualization >> nodeUnder: aMouseEvent [
	"The node of the innermost box under the mouse, nil on the background. Over events bubble up from the element under the mouse: walk up from it to the first box"

	| current |
	current := aMouseEvent target.
	[ current isNil or: [ current == element ] ] whileFalse: [
			(current userData at: #miArchitecturalMapNode ifAbsent: [ nil ]) ifNotNil: [ :node | ^ node ].
			current := current parent ].
	^ nil
]

{ #category : 'testing' }
MiArchiBlVisualization >> origin [
	"Where the canvas is in the element: changed by panning and by zooming around the cursor (for the tests)"

	^ origin
]

{ #category : 'interactions' }
MiArchiBlVisualization >> panBy: aMoveEvent [
	"While the mouse is pressed, move the map with it. Positions in space coordinates, not screen ones (which change when the window moves)"

	dragFrom ifNil: [ ^ self ].
	origin := origin + (aMoveEvent position - dragFrom).
	dragFrom := aMoveEvent position.
	self applyTransform
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

{ #category : 'highlight' }
MiArchiBlVisualization >> updateHighlight [
	"Each line and box drawn normally, except the dependencies of highlightedNode (both ways, line and arrow head) and the boxes at their other end"

	| remoteNodes |
	remoteNodes := IdentitySet new.
	linesLayer children do: [ :line |
			| dependency isHighlighted |
			dependency := line userData at: #miArchitecturalMapDependency.
			isHighlighted := highlightedNode isNotNil and: [
				                 dependency source == highlightedNode or: [ dependency target == highlightedNode ] ].
			isHighlighted ifTrue: [
					remoteNodes add: (dependency source == highlightedNode
							 ifTrue: [ dependency target ]
							 ifFalse: [ dependency source ]) ].
			line border: (self lineBorderHighlighted: isHighlighted).
			line children first background: (isHighlighted
					 ifTrue: [ self highlightColor ]
					 ifFalse: [ self lineColor ]) ].
	elementsByNode keysAndValuesDo: [ :node :box |
			box border: ((remoteNodes includes: node)
					 ifTrue: [ (self borderFor: node) copyWithPaint: self highlightColor ]
					 ifFalse: [ self borderFor: node ]) ]
]

{ #category : 'lines' }
MiArchiBlVisualization >> updateLines [
	"Draw again the lines between the boxes, only if they moved since the last time: a layout is computed often, and a handler of BlElementLayoutComputedEvent must only change what differs, or the space never settles.
	The bounds are kept as copies (#asRectangle): #boundsInSpace answers the same cached object, changed in place by each layout.
	The new lines show the current highlight"

	| visible bounds |
	bounds := elementsByNode values collect: [ :each | each boundsInSpace asRectangle ].
	bounds = lastBounds ifTrue: [ ^ self ].
	lastBounds := bounds.
	visible := tree visibleDependencies select: [ :each |
		           (elementsByNode includesKey: each source) and: [ elementsByNode includesKey: each target ] ].
	linesLayer removeChildren.
	linesLayer addChildren: (visible collect: [ :each | self lineElementFor: each ]).
	highlightedNode ifNotNil: [ self updateHighlight ]
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
	cursor := element globalPointToLocal: aWheelEvent position.
	origin := cursor - (newZoom / zoom * (cursor - origin)).
	zoom := newZoom.
	self applyTransform.
	aWheelEvent consumed: true
]
