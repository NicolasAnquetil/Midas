"
I am a layout of the root nodes of an architectural map shown with Bloc: see my class-side #layoutDescription.
"
Class {
	#name : 'MiArchiBlFlowLayout',
	#superclass : 'MiArchiBlLayout',
	#category : 'MooseIDE-ArchitecturalMap-Bloc-data',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'data'
}

{ #category : 'accessing' }
MiArchiBlFlowLayout class >> layoutDescription [

	^ 'Rows from left to right'
]

{ #category : 'accessing' }
MiArchiBlFlowLayout class >> layoutName [

	^ 'Flow'
]

{ #category : 'layout' }
MiArchiBlFlowLayout >> applyOn: anElement topElementsCount: anInteger [

	anElement layout: BlFlowLayout horizontal.
	anElement constraintsDo: [ :c |
			c horizontal exact: self maxWidth.
			c vertical fitContent ]
]

{ #category : 'layout' }
MiArchiBlFlowLayout >> maxWidth [

	^ 800
]
