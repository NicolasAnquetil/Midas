"
I am a Toplo circular layout that keeps the children inside the element I lay out: the circle of their centers is inset by half the size of the biggest child.

## Collaborators & Context
- `ToBasicCircularLayout` (Toplo): puts the center of each child on a circle (an ellipse) as large as the element, minus `inset`, 0 by default. So each child sticks out of the element by half its size, and the element clips it.
- `MiArchiBlCircularLayout`: gives me to the layer of the root boxes of the map.

## Assumptions & Invariants
- `inset` is set at each layout, from the measured children: half the largest width or height among them. Set by hand, it is replaced.
- The element must be large enough for the circle: with an inset larger than half its size, the circle is reversed (the radius is negative).

## Main API
- `anElement layout: MiArchiBlInsetCircularLayout new`, with an exact size.

"
Class {
	#name : 'MiArchiBlInsetCircularLayout',
	#superclass : 'ToBasicCircularLayout',
	#category : 'MooseIDE-ArchitecturalMap-Bloc-visualization',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'visualization'
}

{ #category : 'layout' }
MiArchiBlInsetCircularLayout >> layout: anElement in: aBounds context: aBlElementBoundsUpdateContext [
	"Inset the circle by half the size of the biggest child, measured just before, then lay out as Toplo does"

	inset := anElement children inject: 0 into: [ :max :each | max max: (each measuredWidth max: each measuredHeight) / 2 ].
	super layout: anElement in: aBounds context: aBlElementBoundsUpdateContext
]
