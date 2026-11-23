"
I am a layout of the root nodes of an architectural map shown with Bloc: see my class-side #layoutDescription.
"
Class {
	#name : 'MiArchitecturalMapLinearLayoutBl',
	#superclass : 'MiArchitecturalMapLayoutBl',
	#category : 'MooseIDE-ArchitecturalMap-Bloc',
	#package : 'MooseIDE-ArchitecturalMap-Bloc'
}

{ #category : 'accessing' }
MiArchitecturalMapLinearLayoutBl class >> layoutDescription [

	^ 'One column'
]

{ #category : 'accessing' }
MiArchitecturalMapLinearLayoutBl class >> layoutName [

	^ 'Linear'
]

{ #category : 'layout' }
MiArchitecturalMapLinearLayoutBl >> applyOn: anElement topElementsCount: anInteger [

	anElement layout: BlLinearLayout vertical.
	anElement constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ]
]
