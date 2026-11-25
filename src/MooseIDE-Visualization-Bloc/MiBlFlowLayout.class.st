"
I lay out the root nodes of a Bloc map (a MiBlVisualization) in rows, from left to right, wrapping at a fixed width (`BlFlowLayout horizontal`). I am the default layout of the Bloc architectural map (`MiArchitecturalMapBrowserBl`).

## Collaborators & Context
- `MiBlLayout`: my superclass, see it for how layouts are chosen and applied.
- `BlFlowLayout`: does the work.

## Assumptions & Invariants
- The element is `#maxWidth` (800) wide and as tall as its content. I do not need the number of root nodes.

## Main API
- `#applyOn:topElementsCount:`, `#maxWidth`; class side `#layoutName` ('Flow'), `#layoutDescription`.

"
Class {
	#name : 'MiBlFlowLayout',
	#superclass : 'MiBlLayout',
	#category : 'MooseIDE-Visualization-Bloc-layouts',
	#package : 'MooseIDE-Visualization-Bloc',
	#tag : 'layouts'
}

{ #category : 'accessing' }
MiBlFlowLayout class >> layoutDescription [

	^ 'Rows from left to right'
]

{ #category : 'accessing' }
MiBlFlowLayout class >> layoutName [

	^ 'Flow'
]

{ #category : 'layout' }
MiBlFlowLayout >> applyOn: anElement topElementsCount: anInteger [

	anElement layout: BlFlowLayout horizontal.
	anElement constraintsDo: [ :c |
			c horizontal exact: self maxWidth.
			c vertical fitContent ]
]

{ #category : 'layout' }
MiBlFlowLayout >> maxWidth [

	^ 800
]
