"
I draw with Bloc and Toplo the architectural map built by a `MiArchiBlTreeBuilder`: a box per visible node, an arrow per visible dependency, and the root boxes laid out by a `MiArchiBlLayout`. The map can be panned and zoomed with the mouse.

## Collaborators & Context
- Vocabulary: a *node* is model data (a `MiArchiBlNode` of the tree, for an entity or a tag); a *box* is the Bloc element drawn for a node (`boxesByNode`); the *viewport* is the outermost Bloc element, the one shown, holding everything else.
- `MiArchiBlTreeBuilder` (`tree`): gives the root `MiArchiBlNode`s (`#roots`) and the `MiArchiBlDependency`s between the visible nodes (`#visibleDependencies`).
- `MiArchiBlLayout` subclasses (`layoutClass`): place the root boxes in `nodesLayer`. The browser chooses the layout: its `MiArchitecturalMapModel>>#layout`.
- `tokenSource`: an element already in a space (the space root). Its Toplo theme gives the colors (`#tokenNamed:`).
- `MiArchitecturalMapBrowserBl>>#showTree:` creates me in the Bloc UI process and puts my `#viewport` in its space.
- The Bloc elements I build: `viewport` (fills its parent, clips, gets the mouse) > `canvas` (frame layout with padding; moved and scaled) > from bottom to top `nodesLayer`, `halosLayer`, `linesLayer`.

## Assumptions & Invariants
- `tree`, `layoutClass` and `tokenSource` must all be set before `#viewport` is first sent.
- I am built once and lazily, the first time `#viewport` is sent. To show a changed tree (expand/collapse, other layout), make a new visualization.
- A node's box has its label (`ToLabel`). A box with children has a dashed border. A collapsed node's children get no box.
- `boxesByNode` maps each node that has a box to that box. Each box also has its node in its `userData` at `#miArchitecturalMapNode`.
- `linesLayer` and `nodesLayer` both fill the canvas, so they share their coordinates.
- Lines are drawn over the boxes (the boxes are filled and nested, lines under them would be hidden). A line goes from the border of the source box to the border of the target box, towards their centers, and ends with an arrow head (a `BlPolygonGeometry` triangle: this Bloc has no arrowheads) on the target border.
- Lines are redrawn after a layout of `nodesLayer` only if some box bounds changed (`lastBounds`, kept as copies since `#boundsInSpace` is changed in place), so the space can settle.
- Each line has its dependency in its `userData` at `#miArchitecturalMapDependency`.
- Pan and zoom are kept in `origin` (where the canvas is in `viewport`) and `zoom`, and applied together by `#applyTransform` (absolute scale, top left origin). Zoom is around the mouse cursor, by 1.1 per wheel step, between `#minZoom` and `#maxZoom`. Dragging the background pans. Mouse positions are in space coordinates (`#position`, never `#screenPosition`).
- Moving boxes: pressing on a box and dragging moves it (`draggedBox`), pressing on the background pans. At the first move of a child, its container stops laying out its children (`#freezeLayoutOf:` replaces its layout by a `BlBasicLayout` with each child where it was), and after each move gets the size that contains all of them (`#fitToChildren:`). So a parent box grows to contain a moved child.
- Highlight: the mouse over a box (`BlMouseOverEvent`, which bubbles, handled on `viewport`) highlights the node of the innermost box under it (`#nodeUnder:`). Its dependencies both ways and the boxes at their other end get a halo (`#haloColor`), and keep their own look: both are drawn in `halosLayer` (over the boxes, under the lines): a box gets a translucent yellow ring just outside its bounds (`#haloForBox:). Over the background, or when the mouse leaves `viewport` (`BlMouseLeaveEvent`), nothing is highlighted. Only one node at a time (`highlightedNode`) is highlighted; the highlight is reapplied when the lines are redrawn.

## Main API
- `MiArchiBlVisualization new tree: aTreeBuilder; layoutClass: aLayoutClass; tokenSource: aSpaceRoot; yourself`
- `#viewport`: the Bloc element to add to the space (built on first send). It shows the map: everything I draw is inside it.
- `#boxesByNode`: the box (a Bloc element) of each displayed node.
- `#zoomBy:` a wheel event, `#startDragAt:` / `#dragTo:` / `#endDrag` (move a box or pan), `#highlight:` a node or nil: the mouse interactions.
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
		'dragFrom',
		'highlightedNode',
		'halosLayer',
		'draggedBox',
		'boxesByNode',
		'viewport',
		'boxesLayer'
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
MiArchiBlVisualization >> boxForNode: aNode [
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
					 addChildren: (aNode children collect: [ :each | self boxForNode: each ]);
					 yourself) ].
	boxesByNode at: aNode put: box.
	^ box
]

{ #category : 'accessing' }
MiArchiBlVisualization >> boxesByNode [

	^ boxesByNode
]

{ #category : 'building' }
MiArchiBlVisualization >> build [
	"Build and answer the viewport showing the map. It contains the canvas, which contains, from bottom to top, the nodes layer, the halos layer and the lines layer.
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
	"The boxes of the root nodes, placed by the layout. The lines follow them each time a layout is computed"

	boxesLayer := BlElement new.
	layoutClass new applyOn: boxesLayer topElementsCount: tree roots size.
	boxesLayer addChildren: (tree roots collect: [ :each | self boxForNode: each ]).
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
MiArchiBlVisualization >> buildViewport [
	"The viewport shown: it fills its parent and clips the canvas. It receives the mouse: wheel to zoom, drag on a box to move it, drag on the background to pan (the zoom and pan pattern of the Bloc guide on graphical patterns), over to highlight the dependencies of the box under the mouse. Leaving the viewport removes the highlight and ends a drag (the button may be released outside, unseen)"

	viewport := BlElement new
		           layout: BlBasicLayout new;
		           clipChildren: true;
		           addChild: canvas;
		           yourself.
	viewport constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ].
	viewport
		addEventHandlerOn: BlMouseWheelEvent do: [ :event | self zoomBy: event ];
		addEventHandlerOn: BlMouseDownEvent do: [ :event | self startDragAt: event ];
		addEventHandlerOn: BlMouseMoveEvent do: [ :event | self dragTo: event ];
		addEventHandlerOn: BlMouseUpEvent do: [ :event | self endDrag ];
		addEventHandlerOn: BlMouseOverEvent do: [ :event | self highlight: (self nodeUnder: event) ];
		addEventHandlerOn: BlMouseLeaveEvent do: [ :event |
				self endDrag.
				self highlight: nil ]
]

{ #category : 'interactions' }
MiArchiBlVisualization >> dragTo: aMoveEvent [
	"While the mouse is pressed, move the pressed box, or pan the map. Positions in space coordinates, not screen ones (which change when the window moves)"

	| delta |
	dragFrom ifNil: [ ^ self ].
	delta := aMoveEvent position - dragFrom.
	dragFrom := aMoveEvent position.
	draggedBox
		ifNil: [
				origin := origin + delta.
				self applyTransform ]
		ifNotNil: [ self move: draggedBox by: delta / zoom ]
]

{ #category : 'interactions' }
MiArchiBlVisualization >> endDrag [

	dragFrom := nil.
	draggedBox := nil
]

{ #category : 'moving' }
MiArchiBlVisualization >> fitToChildren: aContainer [
	"Give aContainer the size that contains all its children and their margins (a basic layout does not fit positioned children). Read from #measuredBounds: a moved child has its new position there at once, #position answers it only after the next layout"

	| corner |
	corner := aContainer children
		          inject: 0 @ 0
		          into: [ :max :each |
		          max max: each measuredBounds position + each measuredBounds extent + (each margin right @ each margin bottom) ].
	aContainer constraintsDo: [ :c |
			c horizontal exact: corner x.
			c vertical exact: corner y ]
]

{ #category : 'moving' }
MiArchiBlVisualization >> freezeLayoutOf: aContainer [
	"Replace the layout of aContainer (flow, grid...) by explicit positions: each child stays where the layout put it. Done once, at the first move of one of its children"

	| positions |
	(aContainer layout isKindOf: BlBasicLayout) ifTrue: [ ^ self ].
	positions := aContainer children collect: [ :each | each -> each position ].
	aContainer layout: BlBasicLayout new.
	positions do: [ :each | each key position: each value ]
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

{ #category : 'highlight' }
MiArchiBlVisualization >> highlight: aNodeOrNil [
	"Show the dependencies of aNodeOrNil (none for nil)"

	highlightedNode := aNodeOrNil.
	self updateHighlight
]

{ #category : 'initialization' }
MiArchiBlVisualization >> initialize [

	super initialize.
	boxesByNode := IdentityDictionary new.
	lastBounds := #(  ).
	origin := 0 @ 0.
	zoom := 1
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
	sourceBounds := self boundsOf: (boxesByNode at: aDependency source).
	targetBounds := self boundsOf: (boxesByNode at: aDependency target).
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

{ #category : 'interactions' }
MiArchiBlVisualization >> maxZoom [

	^ 10
]

{ #category : 'interactions' }
MiArchiBlVisualization >> minZoom [

	^ 0.1
]

{ #category : 'interactions' }
MiArchiBlVisualization >> move: aBox by: aPoint [
	"Move aBox by aPoint (in the coordinates of its parent, so unzoomed) from where it is. Its parent stops laying out its children: they stay where they are. The parent grows to the right and down to contain the moved box; to the left and up, the box stops at the edge of its parent (keeping its margin)"

	| container |
	container := aBox parent.
	self freezeLayoutOf: container.
	aBox position: (aBox measuredBounds position + aPoint max: aBox margin left @ aBox margin top).
	self fitToChildren: container
]

{ #category : 'highlight' }
MiArchiBlVisualization >> nodeUnder: aMouseEvent [
	"The node of the innermost box under the mouse, nil on the background. Over events bubble up from the Bloc element under the mouse (a box, its label...): walk up from it to the first box"

	| current |
	current := aMouseEvent target.
	[ current isNil or: [ current == viewport ] ] whileFalse: [
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
MiArchiBlVisualization >> startDragAt: aMouseDownEvent [
	"Pressed on a box: it will be moved. On the background: the map will be panned"

	dragFrom := aMouseDownEvent position.
	draggedBox := (self nodeUnder: aMouseDownEvent) ifNotNil: [ :node | boxesByNode at: node ]
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
	"The dependencies of highlightedNode (both ways) and the boxes at their other end get a yellow halo in the halos layer; the lines and boxes keep their look"

	| remoteNodes |
	remoteNodes := IdentitySet new.
	halosLayer removeChildren.
	highlightedNode ifNil: [ ^ self ].
	linesLayer children do: [ :line |
			| dependency |
			dependency := line userData at: #miArchitecturalMapDependency.
			(dependency source == highlightedNode or: [ dependency target == highlightedNode ]) ifTrue: [
					remoteNodes add: (dependency source == highlightedNode
							 ifTrue: [ dependency target ]
							 ifFalse: [ dependency source ]).
					halosLayer addChild: (self haloForLine: line) ] ].
	remoteNodes do: [ :node | halosLayer addChild: (self haloForBox: (boxesByNode at: node)) ]
]

{ #category : 'lines' }
MiArchiBlVisualization >> updateLines [
	"Draw again the lines between the boxes, only if they moved since the last time: a layout is computed often, and a handler of BlElementLayoutComputedEvent must only change what differs, or the space never settles.
	The bounds are kept as copies (#asRectangle): #boundsInSpace answers the same cached object, changed in place by each layout.
	The new lines show the current highlight"

	| visible bounds |
	bounds := boxesByNode values collect: [ :each | each boundsInSpace asRectangle ].
	bounds = lastBounds ifTrue: [ ^ self ].
	lastBounds := bounds.
	visible := tree visibleDependencies select: [ :each |
		           (boxesByNode includesKey: each source) and: [ boxesByNode includesKey: each target ] ].
	linesLayer removeChildren.
	linesLayer addChildren: (visible collect: [ :each | self lineElementFor: each ]).
	highlightedNode ifNotNil: [ self updateHighlight ]
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
