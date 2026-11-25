"
I draw with Bloc and Toplo the architectural map built by a `MiArchiBlTreeBuilder`: the root boxes are laid out by the layout chosen in the settings of the map (a `MiBlLayout` subclass). All the rest (boxes, arrows, pan and zoom, drag, selection, highlight, menus) comes from `MiBlVisualization`.

## Collaborators & Context
- `MiArchitecturalMapBrowserBl>>#newVisualizationOn:` creates me, with the tree builder and the layout of its model (`MiArchitecturalMapModel>>#layout`).
- `MiBlLayout` subclasses (`layoutClass`): place the root boxes in the boxes layer (`#fillBoxesLayer`).

## Assumptions & Invariants
- `layoutClass` must be set before `#viewport` is first sent, like the tree and the token source (see `MiBlVisualization`).
- The roots of the tree are drawn in its order (tags first, then entities sorted by name).

## Main API
- `MiArchiBlVisualization new tree: aTreeBuilder; layoutClass: aLayoutClass; tokenSource: aSpaceRoot; yourself`, then `#viewport` (see `MiBlVisualization`).

"
Class {
	#name : 'MiArchiBlVisualization',
	#superclass : 'MiBlVisualization',
	#instVars : [
		'layoutClass'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc-browser',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'browser'
}

{ #category : 'building' }
MiArchiBlVisualization >> fillBoxesLayer [
	"The boxes of the root nodes, placed by the layout of the map, each with its children in their grid"

	layoutClass new applyOn: boxesLayer topElementsCount: tree roots size.
	boxesLayer addChildren: (tree roots collect: [ :each | self boxForNode: each ])
]

{ #category : 'accessing' }
MiArchiBlVisualization >> layoutClass: aLayoutClass [
	"A subclass of MiBlLayout (required before #viewport)"

	layoutClass := aLayoutClass
]
