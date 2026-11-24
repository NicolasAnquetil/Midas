"
I lay out the root nodes of the Bloc architectural map on a circle (`ToBasicCircularLayout`, from Toplo).

## Collaborators & Context
- `MiArchiBlLayout`: my superclass, see it for how layouts are chosen and applied.
- `MiArchiBlInsetCircularLayout` (a `ToBasicCircularLayout` of Toplo): does the work, inside an element of fixed size, keeping the boxes inside it.

## Assumptions & Invariants
- The circle of the centers of the boxes has a diameter of about the perimeter the root nodes need (their number times `#nodeWidth`) divided by pi, and at least 300. The element is a square larger by `#nodeWidth`, so that the boxes on the circle are inside it (the circle is inset by half the biggest box).
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
	"The circle of the centers of the nodes has a diameter of about the perimeter needed by the nodes divided by pi. anElement is larger by #nodeWidth (the estimated width of a box), so the boxes on the circle are inside it (MiArchiBlInsetCircularLayout insets the circle by half the biggest box)"

	| diameter |
	diameter := (anInteger * self nodeWidth / Float pi) rounded max: 300.
	anElement layout: MiArchiBlInsetCircularLayout new.
	anElement constraintsDo: [ :c |
			c horizontal exact: diameter + self nodeWidth.
			c vertical exact: diameter + self nodeWidth ]
]

{ #category : 'layout' }
MiArchiBlCircularLayout >> nodeWidth [
	"An estimate of the width of a root node, to make the circle large enough"

	^ 150
]
