"
I am a Bloc basic layout (children placed at their `position:`) that also supports fitContent: the element I lay out is as big as needed to contain all its children, with their right and bottom margins.

## Collaborators & Context
- `BlBasicLayout`: places each child at the position it requested. Its measure (from `BlLayout`) does not support fitContent: an element with a basic layout and fitContent stays 0@0.
- `MiBlVisualization>>#freezeLayoutOf:` gives me to a container of boxes at the first move of one of its children: the boxes stay where they are, and the container grows to contain them when one is moved or drawn again bigger (expanded).

## Assumptions & Invariants
- The size is computed during the measure, from the position requested by each child (`constraints position`, applied in the same layout pass) and its measured extent. So it is right in the same pass, even for a child just added or resized.
- Negative positions are not supported (the top left corner of the element is 0@0): the visualization keeps children at the right of and below their margins.
- Children ignored by the layout are measured as by `BlBasicLayout`, and do not count in the size.

## Main API
- `aContainer layout: MiBlFittingBasicLayout new`, with fitContent constraints (for an exact constraint, the exact size is kept).

"
Class {
	#name : 'MiBlFittingBasicLayout',
	#superclass : 'BlBasicLayout',
	#category : 'MooseIDE-Visualization-Bloc-layouts',
	#package : 'MooseIDE-Visualization-Bloc',
	#tag : 'layouts'
}

{ #category : 'measure' }
MiBlFittingBasicLayout >> measure: anElement with: anExtentSpec [
	"Measure the children (as a basic layout), then take the size that contains them all, with their right and bottom margins, as far as anExtentSpec allows (fitContent: all of it; exact: the exact size)"

	| corner |
	super measure: anElement with: anExtentSpec.
	corner := anElement children accountedByLayout
		          inject: 0 @ 0
		          into: [ :max :each |
		          max max: each constraints position + each measuredExtent + (each margin right @ each margin bottom) ].
	anElement measuredExtent: (anExtentSpec extentForWidth: corner x height: corner y)
]
