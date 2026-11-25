"
I test `MiFrontEnd`, the default front-end, and how the application holds it (`MiApplication>>#frontEnd`).

## Collaborators & Context
- The front-ends that replace browsers (`MiBlocFrontEnd`) are tested with the browsers they open (e.g. `MiArchitecturalMapBrowserBlTest`).

## Assumptions & Invariants
- `MiAbstractApplicationTest` gives each test its own application (`#application`): no test changes the front-end in use.

## Main API
- The tests only.

"
Class {
	#name : 'MiFrontEndTest',
	#superclass : 'MiAbstractApplicationTest',
	#category : 'MooseIDE-Tests-Application',
	#package : 'MooseIDE-Tests',
	#tag : 'Application'
}

{ #category : 'tests' }
MiFrontEndTest >> testApplicationHasTheDefaultFrontEnd [

	self assert: self application frontEnd class identicalTo: MiFrontEnd
]

{ #category : 'tests' }
MiFrontEndTest >> testBrowserReplacesNoneByDefault [

	self assert: MiArchitecturalMapBrowser replacedBrowserClass isNil
]

{ #category : 'tests' }
MiFrontEndTest >> testDefaultFrontEndOpensEachBrowserAsItself [

	self assert: MiFrontEnd new browserClasses isEmpty.
	self assert: (MiFrontEnd new browserClassFor: MiArchitecturalMapBrowser) identicalTo: MiArchitecturalMapBrowser
]
