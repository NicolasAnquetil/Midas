"
I lay out the root nodes of the Bloc architectural map in rows, from left to right, wrapping at a fixed width (`BlFlowLayout horizontal`). I am the default layout of `MiArchitecturalMapBrowserBl`.

## Collaborators & Context
- `MiArchiBlLayout`: my superclass, see it for how layouts are chosen and applied.
- `BlFlowLayout`: does the work.

## Assumptions & Invariants
- The element is `#maxWidth` (800) wide and as tall as its content. I do not need the number of root nodes.

## Main API
- `#applyOn:topElementsCount:`, `#maxWidth`; class side `#layoutName` ('Flow'), `#layoutDescription`.

"
Class {
	#name : 'MiArchiBlFlowLayout',
	#superclass : 'MiArchiBlLayout',
	#category : 'MooseIDE-ArchitecturalMap-Bloc-data',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'data'
}

{ #category : 'accessing' }
MiArchiBlFlowLayout class >> layoutDescription [

	^ 'Rows from left to right'
]

{ #category : 'accessing' }
MiArchiBlFlowLayout class >> layoutName [

	^ 'Flow'
]

{ #category : 'layout' }
MiArchiBlFlowLayout >> applyOn: anElement topElementsCount: anInteger [

	anElement layout: BlFlowLayout horizontal.
	anElement constraintsDo: [ :c |
			c horizontal exact: self maxWidth.
			c vertical fitContent ]
]

{ #category : 'layout' }
MiArchiBlFlowLayout >> maxWidth [

	^ 800
]
