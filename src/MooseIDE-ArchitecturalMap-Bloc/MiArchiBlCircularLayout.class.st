"
I lay out the root nodes of the Bloc architectural map on a circle (`MiArchiBlFittingCircularLayout`).

## Collaborators & Context
- `MiArchiBlLayout`: my superclass, see it for how layouts are chosen and applied.
- `MiArchiBlFittingCircularLayout`: does the work. It sizes the circle from the boxes, at each layout pass.

## Assumptions & Invariants
- The element is as large as its content (fitContent): the circle and the boxes on it.
- Each box gets a part of the circle in proportion to its size, so an expanded package makes room for itself, and neighbours do not overlap.

## Main API
- `#applyOn:topElementsCount:`; class side `#layoutName` ('Circular'), `#layoutDescription`.

"
Class {
	#name : 'MiArchiBlCircularLayout',
	#superclass : 'MiArchiBlLayout',
	#category : 'MooseIDE-ArchitecturalMap-Bloc-data',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'data'
}

{ #category : 'accessing' }
MiArchiBlCircularLayout class >> layoutDescription [

	^ 'On a circle'
]

{ #category : 'accessing' }
MiArchiBlCircularLayout class >> layoutName [

	^ 'Circular'
]

{ #category : 'layout' }
MiArchiBlCircularLayout >> applyOn: anElement topElementsCount: anInteger [
	"The root nodes on a circle sized from their boxes (MiArchiBlFittingCircularLayout), anElement as big as needed"

	anElement layout: MiArchiBlFittingCircularLayout new.
	anElement constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ]
]
