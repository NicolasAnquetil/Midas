Class {
	#name : 'MiArchitecturalMenuItemStrategy',
	#superclass : 'HDefaultMenuItemStrategy',
	#category : 'MooseIDE-ArchitecturalMap-Roassal-Menu',
	#package : 'MooseIDE-ArchitecturalMap-Roassal',
	#tag : 'Menu'
}

{ #category : 'public' }
MiArchitecturalMenuItemStrategy >> menuItemClassesFor: aShape [

	| clazz |
	clazz := self classFor: aShape.
	^ MiArchitecturalNodeMenuItem subclasses , clazz subclasses
	  , { HMiInspectMenuItem }
]
