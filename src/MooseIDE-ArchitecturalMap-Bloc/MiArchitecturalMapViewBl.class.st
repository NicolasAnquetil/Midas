"
I draw with Bloc and Toplo the architectural map built by a MiArchitecturalMapTreeBl, as MiArchitecturalMapBuilder draws it with Roassal:
- a box per visible node, with its label (a ToLabel); the box of a tag has the tag's color, the box of a node with children a dashed border; a collapsed node hides its children;
- a line per visible dependency (MiArchitecturalMapTreeBl>>visibleDependencies), drawn under the boxes, from center to center; the lines follow the boxes when the layout changes (#updateLines);
- the root nodes laid out by a MiArchitecturalMapLayoutBl subclass (layoutClass).

#element answers the element to show (it fills its parent). Drag it to move the map, use the mouse wheel to zoom.

The colors come from the Toplo theme of tokenSource, an element already in a space (the space root).
"
Class {
	#name : 'MiArchitecturalMapViewBl',
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
	#category : 'MooseIDE-ArchitecturalMap-Bloc',
	#package : 'MooseIDE-ArchitecturalMap-Bloc'
}

{ #category : 'styling' }
MiArchitecturalMapViewBl >> backgroundFor: aNode [

	^ aNode color ifNil: [ self tokenNamed: #'color-bg-container' ]
]

{ #category : 'styling' }
MiArchitecturalMapViewBl >> borderFor: aNode [
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
MiArchitecturalMapViewBl >> build [
	"element (fills its parent, receives the drag and the mouse wheel) > canvas (moved and zoomed) > lines under nodes"

	nodesLayer := BlElement new.
	(layoutClass ifNil: [ MiArchitecturalMapFlowLayoutBl ]) new applyOn: nodesLayer count: tree roots size.
	nodesLayer addChildren: (tree roots collect: [ :each | self elementForNode: each ]).
	nodesLayer addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self updateLines ].

	linesLayer := BlElement new
		              layout: BlBasicLayout new;
		              preventMeAndChildrenMouseEvents;
		              yourself.
	linesLayer constraintsDo: [ :c | c ignoreByLayout ].

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
			c vertical fitContent ].

	element := BlElement new
		           layout: BlBasicLayout new;
		           clipChildren: true;
		           addChild: canvas;
		           addEventHandlerOn: BlMouseWheelEvent do: [ :event | self zoomBy: event ];
		           yourself.
	element constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ].
	^ element
]

{ #category : 'lines' }
MiArchitecturalMapViewBl >> centerOf: anElement [
	"The center of anElement in the coordinates of the nodes layer (the lines layer is put at the same place)"

	^ nodesLayer globalPointToLocal: (anElement localPointToGlobal: anElement extent / 2)
]

{ #category : 'accessing' }
MiArchitecturalMapViewBl >> element [

	^ element ifNil: [ self build ]
]

{ #category : 'building' }
MiArchitecturalMapViewBl >> elementForNode: aNode [
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
MiArchitecturalMapViewBl >> elementsByNode [

	^ elementsByNode
]

{ #category : 'initialization' }
MiArchitecturalMapViewBl >> initialize [

	super initialize.
	elementsByNode := IdentityDictionary new.
	lastBounds := #(  ).
	zoom := 1
]

{ #category : 'accessing' }
MiArchitecturalMapViewBl >> layoutClass: aLayoutClass [
	"A subclass of MiArchitecturalMapLayoutBl"

	layoutClass := aLayoutClass
]

{ #category : 'styling' }
MiArchitecturalMapViewBl >> lineColor [

	^ (self tokenNamed: #'color-text-secondary') alpha: 0.5
]

{ #category : 'styling' }
MiArchitecturalMapViewBl >> tokenNamed: aSymbol [

	^ tokenSource valueOfTokenNamed: aSymbol
]

{ #category : 'accessing' }
MiArchitecturalMapViewBl >> tokenSource: anElement [
	"An element in a space, whose Toplo theme gives the colors"

	tokenSource := anElement
]

{ #category : 'accessing' }
MiArchitecturalMapViewBl >> tree: aTree [

	tree := aTree
]

{ #category : 'lines' }
MiArchitecturalMapViewBl >> updateLines [
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

{ #category : 'interactions' }
MiArchitecturalMapViewBl >> zoomBy: aWheelEvent [
	"Zoom in (wheel up) or out, around the top left corner of the map"

	aWheelEvent isScrollUp ifTrue: [ zoom := zoom * 1.1 ].
	aWheelEvent isScrollDown ifTrue: [ zoom := zoom / 1.1 ].
	canvas transformDo: [ :t |
			t topLeftOrigin.
			t scaleBy: zoom ].
	aWheelEvent consumed: true
]
