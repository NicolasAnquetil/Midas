"
I draw with Bloc and Toplo the architectural map built by a `MiArchiBlTreeBuilder`: a box per visible node, a line per visible dependency, and the root boxes laid out by a `MiArchiBlLayout`.

## Collaborators & Context
- `MiArchiBlTreeBuilder` (`tree`): gives the root `MiArchiBlNode`s (`#roots`) and the `MiArchiBlDependency`s between the visible nodes (`#visibleDependencies`).
- `MiArchiBlLayout` subclasses (`layoutClass`: `MiArchiBlFlowLayout`, `MiArchiBlGridLayout`, `MiArchiBlCircularLayout`, `MiArchiBlLinearLayout`): place the root boxes in `nodesLayer`. The browser chooses the layout: its `MiArchitecturalMapModel>>#layout`, by default `MiArchitecturalMapBrowserBl>>#defaultMapLayout`.
- `tokenSource`: an element already in a space (the space root). Its Toplo theme gives the colors (`#tokenNamed:`).
- `MiArchitecturalMapBrowserBl>>#showTree:` creates me in the Bloc UI process and puts my `#element` in its space.
- The element tree I build: `element` (fills its parent, clips, gets the mouse wheel) > `canvas` (dragged with a `BlPullHandler`, zoomed) > `linesLayer` under `nodesLayer`.

## Assumptions & Invariants
- `tree`, `layoutClass` and `tokenSource` must all be set before `#element` is first sent. There is no default layout.
- I am built once and lazily, the first time `#element` is sent. To show a changed tree (expand/collapse, other layout), make a new visualization.
- A node's box has its label (`ToLabel`). A tag's box has the tag's color, and a box with children has a dashed border. A collapsed node's children get no box.
- `elementsByNode` maps each node that has a box to that box. Each box also has its node in its `userData` at `#miArchitecturalMapNode`.
- Lines go from box center to box center, in the coordinates of `nodesLayer`. `linesLayer` takes the same position and extent and does not take part in layout or mouse events. Lines are redrawn when `nodesLayer` computes a layout, and only if some box bounds changed (`lastBounds`).
- Zoom is around the top-left corner, by a factor of 1.1 per wheel step.
- Not thread-safe: use me only from the Bloc UI process of the space.

## Main API
- `MiArchiBlVisualization new tree: aTreeBuilder; layoutClass: aLayoutClass; tokenSource: aSpaceRoot; yourself`
- `#element`: the element to add to the space (built on first send).
- `#elementsByNode`: the box of each displayed node.

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
		'zoom'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc-browser',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'browser'
}

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
					  dashArray: #( 1 5 );
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
	"The lines under the nodes, dragged by the mouse and zoomed by #zoomBy:"

	canvas := BlElement new
		          layout: BlFrameLayout new;
		          padding: (BlInsets all: 20);
		          addChildren: {
				          linesLayer.
				          nodesLayer };
		          addEventHandler: BlPullHandler new;
		          yourself.
	canvas constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ]
]

{ #category : 'building' }
MiArchiBlVisualization >> buildElement [
	"The element shown: it fills its parent, clips the canvas and receives the mouse wheel to zoom"

	element := BlElement new
		           layout: BlBasicLayout new;
		           clipChildren: true;
		           addChild: canvas;
		           addEventHandlerOn: BlMouseWheelEvent do: [ :event | self zoomBy: event ];
		           yourself.
	element constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ]
]

{ #category : 'building' }
MiArchiBlVisualization >> buildLinesLayer [
	"The layer of the lines, out of the layout and of the mouse events: #updateLines puts it on the nodes layer"

	linesLayer := BlElement new
		              layout: BlBasicLayout new;
		              preventMeAndChildrenMouseEvents;
		              yourself.
	linesLayer constraintsDo: [ :c | c ignoreByLayout ]
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
	"The center of anElement in the coordinates of the nodes layer (the lines layer is put at the same place)"

	^ nodesLayer globalPointToLocal: (anElement localPointToGlobal: anElement extent / 2)
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
	"Draw again the lines between the boxes, if they moved since the last time (a layout is computed often)"

	| visible bounds |
	visible := tree visibleDependencies select: [ :each |
		           (elementsByNode includesKey: each source) and: [ elementsByNode includesKey: each target ] ].
	bounds := elementsByNode values collect: [ :each | each boundsInSpace ].
	bounds = lastBounds ifTrue: [ ^ self ].
	lastBounds := bounds.
	linesLayer
		position: nodesLayer position;
		extent: nodesLayer extent.
	linesLayer removeChildren.
	linesLayer addChildren: (visible collect: [ :each |
				 BlElement new
					 extent: nodesLayer extent;
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
	"Zoom in (wheel up) or out, around the top left corner of the map"

	aWheelEvent isScrollUp ifTrue: [ zoom := zoom * 1.1 ].
	aWheelEvent isScrollDown ifTrue: [ zoom := zoom / 1.1 ].
	canvas transformDo: [ :t |
			t topLeftOrigin.
			t scaleBy: zoom ].
	aWheelEvent consumed: true
]
