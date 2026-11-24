"
I lay out the root nodes of the Bloc architectural map in one column (`BlLinearLayout vertical`).

## Collaborators & Context
- `MiArchiBlLayout`: my superclass, see it for how layouts are chosen and applied.
- `BlLinearLayout`: does the work.

## Assumptions & Invariants
- The element is as large as its content. I do not need the number of root nodes.

## Main API
- `#applyOn:topElementsCount:`; class side `#layoutName` ('Linear'), `#layoutDescription`.

"
Class {
	#name : 'MiArchiBlLinearLayout',
	#superclass : 'MiArchiBlLayout',
	#category : 'MooseIDE-ArchitecturalMap-Bloc-data',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'data'
}

{ #category : 'accessing' }
MiArchiBlLinearLayout class >> layoutDescription [

	^ 'One column'
]

{ #category : 'accessing' }
MiArchiBlLinearLayout class >> layoutName [

	^ 'Linear'
]

{ #category : 'layout' }
MiArchiBlLinearLayout >> applyOn: anElement topElementsCount: anInteger [

	anElement layout: BlLinearLayout vertical.
	anElement constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ]
]
