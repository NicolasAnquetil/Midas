Class {
	#name : 'MiArchitecturalMenuItemStrategy',
	#superclass : 'HDefaultMenuItemStrategy',
	#category : 'MooseIDE-ArchitecturalMap-model',
	#package : 'MooseIDE-ArchitecturalMap',
	#tag : 'model'
}

{ #category : 'public' }
MiArchitecturalMenuItemStrategy >> menuItemClassesFor: aShape [

	| clazz |
	clazz := self classFor: aShape.
	^ MiArchitecturalNodeMenuItem subclasses , clazz subclasses
	  , { HMiInspectMenuItem }
]
