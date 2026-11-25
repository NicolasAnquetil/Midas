"
I lay out the root nodes of a Bloc map (a MiBlVisualization) in a grid of about as many columns as rows (`BlGridLayout`).

## Collaborators & Context
- `MiBlLayout`: my superclass, see it for how layouts are chosen and applied.
- `BlGridLayout`: does the work.
- `MiBlVisualization>>#childrenContainerFor:` also uses me, whatever the layout of the map, to lay out the children of an expanded node in its box: a square block rather than one long line.

## Assumptions & Invariants
- The number of columns is the ceiling of the square root of the number of nodes laid out (root nodes, or children of a node), at least 1 (so an empty map is valid).
- The element is as large as its content.

## Main API
- `#applyOn:topElementsCount:`; class side `#layoutName` ('Grid'), `#layoutDescription`.

"
Class {
	#name : 'MiBlGridLayout',
	#superclass : 'MiBlLayout',
	#category : 'MooseIDE-Visualization-Bloc-layouts',
	#package : 'MooseIDE-Visualization-Bloc',
	#tag : 'layouts'
}

{ #category : 'accessing' }
MiBlGridLayout class >> layoutDescription [

	^ 'A grid of about as many columns as rows'
]

{ #category : 'accessing' }
MiBlGridLayout class >> layoutName [

	^ 'Grid'
]

{ #category : 'layout' }
MiBlGridLayout >> applyOn: anElement topElementsCount: anInteger [

	anElement layout: (BlGridLayout horizontal
			 columnCount: (anInteger sqrt ceiling max: 1);
			 yourself).
	anElement constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ]
]
