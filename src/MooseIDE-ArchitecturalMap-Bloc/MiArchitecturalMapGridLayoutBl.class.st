"
I am a layout of the root nodes of an architectural map shown with Bloc: see my class-side #layoutDescription.
"
Class {
	#name : 'MiArchitecturalMapGridLayoutBl',
	#superclass : 'MiArchitecturalMapLayoutBl',
	#category : 'MooseIDE-ArchitecturalMap-Bloc',
	#package : 'MooseIDE-ArchitecturalMap-Bloc'
}

{ #category : 'accessing' }
MiArchitecturalMapGridLayoutBl class >> layoutDescription [

	^ 'A grid of about as many columns as rows'
]

{ #category : 'accessing' }
MiArchitecturalMapGridLayoutBl class >> layoutName [

	^ 'Grid'
]

{ #category : 'layout' }
MiArchitecturalMapGridLayoutBl >> applyOn: anElement topElementsCount: anInteger [

	anElement layout: (BlGridLayout horizontal
			 columnCount: (anInteger sqrt ceiling max: 1);
			 yourself).
	anElement constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ]
]
