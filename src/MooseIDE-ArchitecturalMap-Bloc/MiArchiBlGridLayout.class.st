"
I am a layout of the root nodes of an architectural map shown with Bloc: see my class-side #layoutDescription.
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
