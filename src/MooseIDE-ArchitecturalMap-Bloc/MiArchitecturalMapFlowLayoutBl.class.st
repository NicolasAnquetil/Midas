"
I am a layout of the root nodes of an architectural map shown with Bloc: see my class-side #layoutDescription.
"
Class {
	#name : 'MiArchitecturalMapFlowLayoutBl',
	#superclass : 'MiArchitecturalMapLayoutBl',
	#category : 'MooseIDE-ArchitecturalMap-Bloc',
	#package : 'MooseIDE-ArchitecturalMap-Bloc'
}

{ #category : 'accessing' }
MiArchitecturalMapFlowLayoutBl class >> layoutDescription [

	^ 'Rows from left to right'
]

{ #category : 'accessing' }
MiArchitecturalMapFlowLayoutBl class >> layoutName [

	^ 'Flow'
]

{ #category : 'layout' }
MiArchitecturalMapFlowLayoutBl >> applyOn: anElement count: anInteger [

	anElement layout: BlFlowLayout horizontal.
	anElement constraintsDo: [ :c |
			c horizontal exact: self maxWidth.
			c vertical fitContent ]
]

{ #category : 'layout' }
MiArchitecturalMapFlowLayoutBl >> maxWidth [

	^ 800
]
