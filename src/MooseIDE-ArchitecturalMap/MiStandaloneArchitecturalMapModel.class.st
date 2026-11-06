"
Experimental: an architectural map model usable without a browser (e.g. from a GLSP server), while still working inside MiArchitecturalMapBrowser.
Usage: MiStandaloneArchitecturalMapModel new entities: (MooseModel root allModels first allModelPackages)
"
Class {
	#name : 'MiStandaloneArchitecturalMapModel',
	#superclass : 'MiArchitecturalMapModel',
	#category : 'MooseIDE-ArchitecturalMap-GLSP',
	#package : 'MooseIDE-ArchitecturalMap',
	#tag : 'GLSP'
}

{ #category : 'accessing' }
MiStandaloneArchitecturalMapModel >> currentApplication [

	^ browser ifNil: [ MiApplication current ] ifNotNil: [ browser application ]
]

{ #category : 'initialization' }
MiStandaloneArchitecturalMapModel >> initialize [

	super initialize.
	self initializeSettings
]

{ #category : 'accessing' }
MiStandaloneArchitecturalMapModel >> layout: aRoassalLayoutClass [
	"The Roassal layout class of the root nodes, e.g. RSFlowLayout (default) or RSCircleLayout"

	layout := aRoassalLayoutClass
]
