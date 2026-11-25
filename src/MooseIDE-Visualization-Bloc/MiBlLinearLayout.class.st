"
I lay out the root nodes of a Bloc map (a MiBlVisualization) in one column (`BlLinearLayout vertical`).

## Collaborators & Context
- `MiBlLayout`: my superclass, see it for how layouts are chosen and applied.
- `BlLinearLayout`: does the work.

## Assumptions & Invariants
- The element is as large as its content. I do not need the number of root nodes.

## Main API
- `#applyOn:topElementsCount:`; class side `#layoutName` ('Linear'), `#layoutDescription`.

"
Class {
	#name : 'MiBlLinearLayout',
	#superclass : 'MiBlLayout',
	#category : 'MooseIDE-Visualization-Bloc-layouts',
	#package : 'MooseIDE-Visualization-Bloc',
	#tag : 'layouts'
}

{ #category : 'accessing' }
MiBlLinearLayout class >> layoutDescription [

	^ 'One column'
]

{ #category : 'accessing' }
MiBlLinearLayout class >> layoutName [

	^ 'Linear'
]

{ #category : 'layout' }
MiBlLinearLayout >> applyOn: anElement topElementsCount: anInteger [

	anElement layout: BlLinearLayout vertical.
	anElement constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ]
]
