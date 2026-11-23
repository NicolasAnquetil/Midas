"
I am a layout of the root nodes of an architectural map shown with Bloc: see my class-side #layoutDescription.
"
Class {
	#name : 'MiArchitecturalMapCircularLayoutBl',
	#superclass : 'MiArchitecturalMapLayoutBl',
	#category : 'MooseIDE-ArchitecturalMap-Bloc',
	#package : 'MooseIDE-ArchitecturalMap-Bloc'
}

{ #category : 'accessing' }
MiArchitecturalMapCircularLayoutBl class >> layoutDescription [

	^ 'On a circle'
]

{ #category : 'accessing' }
MiArchitecturalMapCircularLayoutBl class >> layoutName [

	^ 'Circular'
]

{ #category : 'layout' }
MiArchitecturalMapCircularLayoutBl >> applyOn: anElement topElementsCount: anInteger [
	"The circle fills anElement: its diameter is about the perimeter needed by the nodes divided by pi"

	| diameter |
	diameter := (anInteger * self nodeWidth / Float pi) rounded max: 300.
	anElement layout: ToBasicCircularLayout new.
	anElement constraintsDo: [ :c |
			c horizontal exact: diameter.
			c vertical exact: diameter ]
]

{ #category : 'layout' }
MiArchitecturalMapCircularLayoutBl >> nodeWidth [
	"An estimate of the width of a root node, to make the circle large enough"

	^ 150
]
