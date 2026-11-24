"
I lay out the root nodes of the Bloc architectural map on a circle (`ToBasicCircularLayout`, from Toplo).

## Collaborators & Context
- `MiArchiBlLayout`: my superclass, see it for how layouts are chosen and applied.
- `ToBasicCircularLayout`: does the work, inside an element of fixed size.

## Assumptions & Invariants
- The element is a square whose side is the diameter of the circle: about the perimeter the root nodes need (their number times `#nodeWidth`) divided by pi, and at least 300.
- `#nodeWidth` (150) is an estimate: wider boxes may overlap.

## Main API
- `#applyOn:topElementsCount:`, `#nodeWidth`; class side `#layoutName` ('Circular'), `#layoutDescription`.

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
	"The circle fills anElement: its diameter is about the perimeter needed by the nodes divided by pi"

	| diameter |
	diameter := (anInteger * self nodeWidth / Float pi) rounded max: 300.
	anElement layout: ToBasicCircularLayout new.
	anElement constraintsDo: [ :c |
			c horizontal exact: diameter.
			c vertical exact: diameter ]
]

{ #category : 'layout' }
MiArchiBlCircularLayout >> nodeWidth [
	"An estimate of the width of a root node, to make the circle large enough"

	^ 150
]
