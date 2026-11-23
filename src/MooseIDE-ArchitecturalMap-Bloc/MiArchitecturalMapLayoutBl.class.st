"
I am a layout of the root nodes of an architectural map shown with Bloc (MiArchitecturalMapBrowserBl).

My subclasses (the classes, as the Roassal layouts are) are what MiArchitecturalMapBrowserBl>>availableMapLayouts answers: the map settings show their class-side #layoutName and #layoutDescription. An instance lays out the element holding the root nodes (#applyOn:count:).
"
Class {
	#name : 'MiArchitecturalMapLayoutBl',
	#superclass : 'Object',
	#category : 'MooseIDE-ArchitecturalMap-Bloc',
	#package : 'MooseIDE-ArchitecturalMap-Bloc'
}

{ #category : 'accessing' }
MiArchitecturalMapLayoutBl class >> availableLayouts [
	"What MiArchitecturalMapBrowserBl>>availableMapLayouts answers"

	^ {
		  MiArchitecturalMapFlowLayoutBl.
		  MiArchitecturalMapGridLayoutBl.
		  MiArchitecturalMapLinearLayoutBl.
		  MiArchitecturalMapCircularLayoutBl }
]

{ #category : 'accessing' }
MiArchitecturalMapLayoutBl class >> isAbstract [

	^ self == MiArchitecturalMapLayoutBl
]

{ #category : 'accessing' }
MiArchitecturalMapLayoutBl class >> layoutDescription [
	"Shown in the map settings, as help"

	^ self layoutName
]

{ #category : 'accessing' }
MiArchitecturalMapLayoutBl class >> layoutName [
	"Shown in the map settings"

	^ self subclassResponsibility
]

{ #category : 'layout' }
MiArchitecturalMapLayoutBl >> applyOn: anElement count: anInteger [
	"Lay out the anInteger children of anElement (the root nodes of the map), setting its layout and its size constraints"

	self subclassResponsibility
]
