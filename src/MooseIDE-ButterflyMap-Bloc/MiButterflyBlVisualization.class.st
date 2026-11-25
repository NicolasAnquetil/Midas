"
I draw with Bloc and Toplo the butterfly map of a `MiButterflyBlTree`: the central node in the middle, its clients in columns on the left, its providers in columns on the right, one column per level. Boxes, arrows, pan and zoom, drag, selection, highlight and the common menu items come from `MiBlVisualization`.

## Collaborators & Context
- `MiButterflyBlTree` (`tree`): gives the levels (`#leftLevels`, `#rightLevels`) and the dependencies, and changes when my menus ask (`#addLevel`, `#removeLevel`, `#addDependenciesOf:`, `#removeDependenciesOf:`, `#remove:`).
- `MiButterflyMapBrowserBl` (`browser`): creates me (`#newVisualizationOn:`), and draws the map of another entity for Be central node (`#centralEntity:`).
- `MiButterflyBlNode`: a node of the butterfly has a box in a column; the nodes inside it are drawn inside its box, as in any map.

## Assumptions & Invariants
- Columns, from left to right: the left levels from the outermost one, the central node, the right levels (`#fillBoxesLayer`). They are centered vertically and `#columnSpacing` apart; in a column the boxes are one under the other, aligned towards the center (right on the left side, left on the right side).
- A change of the butterfly draws all the boxes again (`#treeChanged`, by `#relayoutAll`): boxes moved by hand go back to their column. Expanded boxes, hidden links, zoom and pan are kept; the nodes no longer drawn leave the selection.
- Menu of a box of the butterfly, after Expand/Collapse: Add dependencies (if the model was not asked yet for this node), Remove dependencies (if the node has some), Remove node and Be central node (not for the central node). Then the common items (links, Inspect, Propagate). A box inside another box only has the common items.
- Menu of the background: Relayout all, Add level, Remove external level (with more than one level), Zoom to fit.
- Highlight: as in any map, and the other boxes of the same entity get a halo too.

## Main API
- `MiButterflyBlVisualization new tree: aButterflyTree; tokenSource: aSpaceRoot; browser: aBrowser; yourself`, then `#viewport` (see `MiBlVisualization`).
- `#addLevel`, `#removeLevel`, `#addDependenciesOf:`, `#removeDependenciesOf:`, `#remove:`: change the butterfly and draw it again, as the menus do.
- `#zoomToFit` (from `MiBlVisualization`).

"
Class {
	#name : 'MiButterflyBlVisualization',
	#superclass : 'MiBlVisualization',
	#category : 'MooseIDE-ButterflyMap-Bloc-browser',
	#package : 'MooseIDE-ButterflyMap-Bloc',
	#tag : 'browser'
}

{ #category : 'changing' }
MiButterflyBlVisualization >> addDependenciesOf: aNode [

	tree addDependenciesOf: aNode.
	self treeChanged
]

{ #category : 'changing' }
MiButterflyBlVisualization >> addLevel [

	tree addLevel.
	self treeChanged
]

{ #category : 'building' }
MiButterflyBlVisualization >> columnOf: someNodes alignedRight: aBoolean [
	"A column of the boxes of someNodes, one under the other, centered vertically. Aligned right on the left side (towards the center), left on the right side. Not a box: a plain element, frozen like any container when one of its boxes is moved"

	| column |
	column := BlElement new
		          layout: (aBoolean
				           ifTrue: [ BlLinearLayout vertical alignCenterRight ]
				           ifFalse: [ BlLinearLayout vertical alignCenterLeft ]);
		          yourself.
	column constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ].
	^ column
		  addChildren: (someNodes collect: [ :each | self boxForNode: each ]);
		  yourself
]

{ #category : 'styling' }
MiButterflyBlVisualization >> columnSpacing [
	"The horizontal space between two columns: room for the arrows"

	^ 120
]

{ #category : 'building' }
MiButterflyBlVisualization >> fillBoxesLayer [
	"The columns of the butterfly, side by side and centered vertically: the left levels from the outermost one, the central node, then the right levels. Each column but the first is #columnSpacing away from the previous one (a margin: the cell spacing of a Bloc linear layout also goes before the first child and after the last)"

	| columns |
	boxesLayer layout: BlLinearLayout horizontal alignCenterLeft.
	boxesLayer constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ].
	tree central ifNil: [ ^ self ].
	columns := OrderedCollection new.
	columns addAll: (tree leftLevels reversed collect: [ :each | self columnOf: each alignedRight: true ]).
	columns add: (self columnOf: { tree central } alignedRight: false).
	columns addAll: (tree rightLevels collect: [ :each | self columnOf: each alignedRight: false ]).
	columns allButFirstDo: [ :each | each margin: (BlInsets left: self columnSpacing) ].
	boxesLayer addChildren: columns
]

{ #category : 'highlight' }
MiButterflyBlVisualization >> highlight: aNodeOrNil [
	"As any map (the dependencies of the node, and the boxes at their other end), and also the other boxes of the same entity: an entity can be in several places of a butterfly"

	super highlight: aNodeOrNil.
	aNodeOrNil ifNil: [ ^ self ].
	self boxes
		select: [ :each |
			| node |
			node := self nodeOf: each.
			node ~~ aNodeOrNil and: [ node entity = aNodeOrNil entity ] ]
		thenDo: [ :each | halosLayer addChild: (self haloForBox: each) ]
]

{ #category : 'changing' }
MiButterflyBlVisualization >> remove: aNode [

	tree remove: aNode.
	self treeChanged
]

{ #category : 'changing' }
MiButterflyBlVisualization >> removeDependenciesOf: aNode [

	tree removeDependenciesOf: aNode.
	self treeChanged
]

{ #category : 'changing' }
MiButterflyBlVisualization >> removeLevel [

	tree removeLevel.
	self treeChanged
]

{ #category : 'menu' }
MiButterflyBlVisualization >> specificItemsFor: aNode [
	"For a node of the butterfly (not one inside a box), the items that would change something: Add dependencies (ask the model for its clients or providers), Remove dependencies (the nodes added for it), Remove node and Be central node (not for the central node). Be central node asks the browser to draw the map of its entity"

	| items |
	aNode isInButterfly ifFalse: [ ^ #(  ) ].
	items := OrderedCollection new.
	(tree canAddDependenciesOf: aNode) ifTrue: [ items add: (self menuItem: 'Add dependencies' do: [ self addDependenciesOf: aNode ]) ].
	aNode expansions ifNotEmpty: [ items add: (self menuItem: 'Remove dependencies' do: [ self removeDependenciesOf: aNode ]) ].
	aNode isCentral ifFalse: [
			items add: (self menuItem: 'Remove node' do: [ self remove: aNode ]).
			items add: (self menuItem: 'Be central node' do: [ browser ifNotNil: [ browser centralEntity: aNode entity ] ]) ].
	^ items
]

{ #category : 'changing' }
MiButterflyBlVisualization >> treeChanged [
	"The butterfly changed (a level, or nodes, added or removed): draw all the boxes again, and drop from the selection the nodes no longer drawn"

	self relayoutAll.
	self unselectNodesWithoutBox
]

{ #category : 'menu' }
MiButterflyBlVisualization >> viewportMenuItems [
	"Relayout all, then Add level, Remove external level (if there is more than one level), Zoom to fit"

	| items |
	items := super viewportMenuItems.
	items add: (self menuItem: 'Add level' do: [ self addLevel ]).
	tree depth > 1 ifTrue: [ items add: (self menuItem: 'Remove external level' do: [ self removeLevel ]) ].
	items add: (self menuItem: 'Zoom to fit' do: [ self zoomToFit ]).
	^ items
]
