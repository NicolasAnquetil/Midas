"
I am a layout of the root nodes of an architectural map shown with Bloc: see my class-side #layoutDescription.
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
