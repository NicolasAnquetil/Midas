"
I am a Bloc layout that places the children on a circle sized from the children themselves, and makes the element I lay out as big as needed (fitContent).

## Collaborators & Context
- `BlBasicLayout`: my superclass, for the measure of the children and the children ignored by the layout.
- `MiArchiBlCircularLayout`: gives me to the layer of the root boxes of the map. Replaces `ToBasicCircularLayout` (Toplo), which puts the centers of the children at equal angles on a circle as large as the element: boxes sticking out of the element by half their size, and big boxes (an expanded package) overlapping their neighbours.

## Assumptions & Invariants
- Each child gets a part of the circle in proportion to its span: its diagonal plus `#gap`. So a big child gets more room, and neighbours do not overlap.
- The radius is such that the chord between the centers of two neighbours is their span: the sum of the spans divided by 2·n·sin(π/n) for n children (exact when all spans are equal), and at least `#minimumRadius`.
- The element is a square: the diameter plus the biggest side of a child, so all the children are inside it.
- All this is computed at each layout pass from the measured children: when a child grows (expanded) or shrinks, the circle follows.
- The first child is at the right of the center (angle 0), the others follow clockwise (y goes down).

## Main API
- `anElement layout: MiArchiBlFittingCircularLayout new`, with fitContent constraints.
- `#gap`, `#minimumRadius`.

"
Class {
	#name : 'MiArchiBlFittingCircularLayout',
	#superclass : 'BlBasicLayout',
	#category : 'MooseIDE-ArchitecturalMap-Bloc-visualization',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'visualization'
}

{ #category : 'layout' }
MiArchiBlFittingCircularLayout >> gap [
	"Room left between two neighbours on the circle"

	^ 20
]

{ #category : 'layout' }
MiArchiBlFittingCircularLayout >> layout: anElement in: aBounds context: aContext [
	"Place the center of each child in the middle of its part of the circle"

	| children center radius total angle |
	children := anElement children accountedByLayout.
	children isEmpty ifFalse: [
			center := anElement measuredExtent / 2.
			radius := self radiusFor: children.
			total := children inject: 0 into: [ :sum :each | sum + (self spanOf: each) ].
			angle := 0.
			children do: [ :each |
					| sweep middle position |
					sweep := 2 * Float pi * (self spanOf: each) / total.
					middle := angle + (sweep / 2).
					position := center + (radius * middle cos @ (radius * middle sin)).
					each applyLayoutIn: (position - (each measuredExtent / 2) extent: each measuredExtent) context: aContext.
					angle := angle + sweep ] ].
	self layoutIgnored: anElement context: aContext
]

{ #category : 'layout' }
MiArchiBlFittingCircularLayout >> measure: anElement with: anExtentSpec [
	"Measure the children, then take the size of the circle plus the biggest side of a child, as far as anExtentSpec allows"

	| children side |
	super measure: anElement with: anExtentSpec.
	children := anElement children accountedByLayout.
	side := 2 * (self radiusFor: children)
	        + (children inject: 0 into: [ :max :each | max max: (each measuredWidth max: each measuredHeight) ]).
	anElement measuredExtent: (anExtentSpec extentForWidth: side height: side)
]

{ #category : 'layout' }
MiArchiBlFittingCircularLayout >> minimumRadius [

	^ 150
]

{ #category : 'layout' }
MiArchiBlFittingCircularLayout >> radiusFor: someChildren [
	"The radius such that the chord between two neighbours is about their span"

	| n total |
	n := someChildren size.
	n < 2 ifTrue: [ ^ self minimumRadius ].
	total := someChildren inject: 0 into: [ :sum :each | sum + (self spanOf: each) ].
	^ total / (2 * n * (Float pi / n) sin) max: self minimumRadius
]

{ #category : 'layout' }
MiArchiBlFittingCircularLayout >> spanOf: aChild [
	"The room aChild needs on the circle: its diagonal (so whatever its angle on the circle) and a gap"

	^ aChild measuredExtent r + self gap
]
