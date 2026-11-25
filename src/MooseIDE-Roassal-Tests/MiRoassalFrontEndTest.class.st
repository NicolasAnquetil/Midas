"
I test `MiRoassalFrontEnd`: it is the default front-end, lists all the browsers of its package, offers them with the common ones, one per name.

## Collaborators & Context
- `MiFrontEnd`: the common browsers (`MiFrontEndTest`).

## Assumptions & Invariants
- No test changes the front-end of the application.

## Main API
- The tests only.

"
Class {
	#name : 'MiRoassalFrontEndTest',
	#superclass : 'TestCase',
	#category : 'MooseIDE-Roassal-Tests',
	#package : 'MooseIDE-Roassal-Tests'
}

{ #category : 'tests' }
MiRoassalFrontEndTest >> testBrowserNamed [

	self assert: (MiRoassalFrontEnd new browserNamed: 'Architectural map') identicalTo: MiArchitecturalMapBrowser.
	self assert: (MiRoassalFrontEnd new browserClassFor: MiButterflyMapBrowser) identicalTo: MiButterflyMapBrowser
]

{ #category : 'tests' }
MiRoassalFrontEndTest >> testIsTheDefault [

	self assert: MiFrontEnd default class identicalTo: MiRoassalFrontEnd
]

{ #category : 'tests' }
MiRoassalFrontEndTest >> testListsAllTheBrowsersOfItsPackage [

	self
		assertCollection: MiRoassalFrontEnd new specificBrowserClasses
		hasSameElements: (MiRoassalFrontEnd package definedClasses select: [ :each | (each inheritsFrom: MiAbstractBrowser) and: [ each isAbstract not ] ])
]

{ #category : 'tests' }
MiRoassalFrontEndTest >> testOffersItsBrowsersAndTheCommonOnes [

	| browsers |
	browsers := MiRoassalFrontEnd new browserClasses.
	self assert: (browsers includesAll: MiRoassalFrontEnd new specificBrowserClasses).
	self assert: (browsers includesAll: MiFrontEnd new browserClasses).
	self assert: browsers size equals: MiRoassalFrontEnd new specificBrowserClasses size + MiFrontEnd new browserClasses size
]

{ #category : 'tests' }
MiRoassalFrontEndTest >> testOneBrowserPerName [

	| names |
	names := MiRoassalFrontEnd new browserNames.
	self assert: names asSet size equals: names size
]
