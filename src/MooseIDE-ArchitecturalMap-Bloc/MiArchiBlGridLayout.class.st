"
I lay out the root nodes of the Bloc architectural map in a grid of about as many columns as rows (`BlGridLayout`).

## Collaborators & Context
- `MiArchiBlLayout`: my superclass, see it for how layouts are chosen and applied.
- `BlGridLayout`: does the work.

## Assumptions & Invariants
- The number of columns is the ceiling of the square root of the number of root nodes, at least 1 (so an empty map is valid).
- The element is as large as its content.

## Main API
- `#applyOn:topElementsCount:`; class side `#layoutName` ('Grid'), `#layoutDescription`.

"
Class {
	#name : 'MiArchiBlGridLayout',
	#superclass : 'MiArchiBlLayout',
	#category : 'MooseIDE-ArchitecturalMap-Bloc-data',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'data'
}

{ #category : 'accessing' }
MiArchiBlGridLayout class >> layoutDescription [

	^ 'A grid of about as many columns as rows'
]

{ #category : 'accessing' }
MiArchiBlGridLayout class >> layoutName [

	^ 'Grid'
]

{ #category : 'layout' }
MiArchiBlGridLayout >> applyOn: anElement topElementsCount: anInteger [

	anElement layout: (BlGridLayout horizontal
			 columnCount: (anInteger sqrt ceiling max: 1);
			 yourself).
	anElement constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ]
]
