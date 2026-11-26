Class {
	#name : 'MiSystemComplexityMenuItemStrategy',
	#superclass : 'HDefaultMenuItemStrategy',
	#category : 'MooseIDE-Roassal-SystemComplexity-Menu',
	#package : 'MooseIDE-Roassal-SystemComplexity',
	#tag : 'Menu'
}

{ #category : 'public' }
MiSystemComplexityMenuItemStrategy >> menuItemClassesFor: aShape [

	| clazz |
	clazz := self classFor: aShape.
	^ clazz subclasses , { HMiInspectMenuItem }
]
