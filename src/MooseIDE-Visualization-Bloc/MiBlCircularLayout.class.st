"
I lay out the root nodes of a Bloc map (a MiBlVisualization) on a circle (`MiBlFittingCircularLayout`).

## Collaborators & Context
- `MiBlLayout`: my superclass, see it for how layouts are chosen and applied.
- `MiBlFittingCircularLayout`: does the work. It sizes the circle from the boxes, at each layout pass.

## Assumptions & Invariants
- The element is as large as its content (fitContent): the circle and the boxes on it.
- Each box gets a part of the circle in proportion to its size, so an expanded package makes room for itself, and neighbours do not overlap.

## Main API
- `#applyOn:topElementsCount:`; class side `#layoutName` ('Circular'), `#layoutDescription`.

"
Class {
	#name : 'MiBlCircularLayout',
	#superclass : 'MiBlLayout',
	#category : 'MooseIDE-Visualization-Bloc-layouts',
	#package : 'MooseIDE-Visualization-Bloc',
	#tag : 'layouts'
}

{ #category : 'accessing' }
MiBlCircularLayout class >> layoutDescription [

	^ 'On a circle'
]

{ #category : 'accessing' }
MiBlCircularLayout class >> layoutName [

	^ 'Circular'
]

{ #category : 'layout' }
MiBlCircularLayout >> applyOn: anElement topElementsCount: anInteger [
	"The root nodes on a circle sized from their boxes (MiBlFittingCircularLayout), anElement as big as needed"

	anElement layout: MiBlFittingCircularLayout new.
	anElement constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ]
]
