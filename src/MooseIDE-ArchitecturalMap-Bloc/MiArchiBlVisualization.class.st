"
I draw with Bloc and Toplo the architectural map built by a `MiArchiBlTreeBuilder`: a box per visible node, a line per visible dependency, and the root boxes laid out by a `MiArchiBlLayout`. The map can be panned and zoomed with the mouse.

## Collaborators & Context
- `MiArchiBlTreeBuilder` (`tree`): gives the root `MiArchiBlNode`s (`#roots`) and the `MiArchiBlDependency`s between the visible nodes (`#visibleDependencies`).
- `MiArchiBlLayout` subclasses (`layoutClass`): place the root boxes in `nodesLayer`. The browser chooses the layout: its `MiArchitecturalMapModel>>#layout`, by default `MiArchitecturalMapBrowserBl>>#defaultMapLayout`.
- `tokenSource`: an element already in a space (the space root). Its Toplo theme gives the colors (`#tokenNamed:`).
- `MiArchitecturalMapBrowserBl>>#showTree:` creates me in the Bloc UI process and puts my `#element` in its space.
- The element tree I build: `element` (fills its parent, clips, gets the mouse) > `canvas` (frame layout with padding; moved and scaled) > `linesLayer` under `nodesLayer`.
- Bloc documentation followed (github.com/pharo-graphics/Bloc, doc/): LayoutAndConstraints (position is a request; layout handlers change only what differs) and GraphicalPatterns (zoom and pan).

## Assumptions & Invariants
- `tree`, `layoutClass` and `tokenSource` must all be set before `#element` is first sent. There is no default layout.
- I am built once and lazily, the first time `#element` is sent. To show a changed tree (expand/collapse, other layout), make a new visualization.
- A node's box has its label (`ToLabel`). A tag's box has the tag's color, and a box with children has a dashed border. A collapsed node's children get no box.
- `elementsByNode` maps each node that has a box to that box. Each box also has its node in its `userData` at `#miArchitecturalMapNode`.
- `linesLayer` and `nodesLayer` both fill the canvas, so they share their coordinates: the lines layer is never moved. Its children (one per line, filling it) are not clipped.
- Lines go from box center to box center. They are redrawn after a layout of `nodesLayer` only if some box bounds changed (`lastBounds`), so the space can settle.
- Pan and zoom are kept in `origin` (where the canvas is in `element`) and `zoom`, and applied together by `#applyTransform` (absolute scale, top left origin). Zoom is around the mouse cursor, by 1.1 per wheel step, between `#minZoom` and `#maxZoom`. Dragging with the mouse pressed pans. Mouse positions are in space coordinates (`#position`, never `#screenPosition`).
- Not thread-safe: once my element is in an opened space, use me only from its UI process (`BlSpace>>#defer:`).

## Main API
- `MiArchiBlVisualization new tree: aTreeBuilder; layoutClass: aLayoutClass; tokenSource: aSpaceRoot; yourself`
- `#element`: the element to add to the space (built on first send).
- `#elementsByNode`: the box of each displayed node.
- `#zoomBy:` a wheel event, `#panBy:` a move event: the mouse interactions.
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
		'dragFrom'
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
	"The lines under the nodes. Moved (origin) and zoomed by #applyTransform"

	canvas := BlElement new
		          layout: BlFrameLayout new;
		          padding: (BlInsets all: 20);
		          addChildren: {
				          linesLayer.
				          nodesLayer };
		          yourself.
	canvas constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ]
]

{ #category : 'building' }
MiArchiBlVisualization >> buildElement [
	"The element shown: it fills its parent and clips the canvas. It receives the mouse: wheel to zoom, drag to pan (the zoom and pan pattern of the Bloc guide on graphical patterns)"

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
		addEventHandlerOn: BlMouseUpEvent do: [ :event | dragFrom := nil ]
]

{ #category : 'building' }
MiArchiBlVisualization >> buildLinesLayer [
	"The layer of the lines, under the nodes and out of the mouse events. It fills the canvas like the nodes layer (both are children of a frame layout with the same padding), so the two share their coordinates and the lines layer never needs to be moved"

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

{ #category : 'lines' }
MiArchiBlVisualization >> centerOf: anElement [
	"The center of anElement in the coordinates of the lines layer"

	^ linesLayer globalPointToLocal: (anElement localPointToGlobal: anElement extent / 2)
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
MiArchiBlVisualization >> lineColor [

	^ (self tokenNamed: #'color-text-secondary') alpha: 0.5
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

{ #category : 'lines' }
MiArchiBlVisualization >> updateLines [
	"Draw again the lines between the boxes, only if they moved since the last time: a layout is computed often, and a handler of BlElementLayoutComputedEvent must only change what differs, or the space never settles"

	| visible bounds |
	bounds := elementsByNode values collect: [ :each | each boundsInSpace ].
	bounds = lastBounds ifTrue: [ ^ self ].
	lastBounds := bounds.
	visible := tree visibleDependencies select: [ :each |
		           (elementsByNode includesKey: each source) and: [ elementsByNode includesKey: each target ] ].
	linesLayer removeChildren.
	linesLayer addChildren: (visible collect: [ :each |
				 BlElement new
					 constraintsDo: [ :c |
							 c horizontal matchParent.
							 c vertical matchParent ];
					 geometry:
						 (BlLineGeometry
							  from: (self centerOf: (elementsByNode at: each source))
							  to: (self centerOf: (elementsByNode at: each target)));
					 outskirts: BlOutskirts centered;
					 border: (BlBorder paint: self lineColor width: 1);
					 yourself ])
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
