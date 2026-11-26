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
	#category : 'MooseIDE-Roassal-tests',
	#package : 'MooseIDE-Roassal',
	#tag : 'tests'
}

{ #category : 'tests' }
MiRoassalFrontEndTest >> testBrowserNamed [
	"Each browser of mine is found under its name, and opens as itself (the tests of the maps check their own browsers)"

	| frontEnd |
	frontEnd := MiRoassalFrontEnd new.
	frontEnd specificBrowserClasses do: [ :each |
			self assert: (frontEnd browserNamed: each browserName) identicalTo: each.
			self assert: (frontEnd browserClassFor: each) identicalTo: each ]
]

{ #category : 'tests' }
MiRoassalFrontEndTest >> testIsTheDefault [

	self assert: MiFrontEnd default class identicalTo: MiRoassalFrontEnd
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
MiRoassalFrontEndTest >> testOffersTheBrowsersOfItsPackage [
	"The Roassal browsers of the tools not split yet are in my package; those of the split tools, in their MooseIDE-Roassal-<tool> packages, are checked by the tests of these packages"

	self
		assertCollection: MiRoassalFrontEnd new specificBrowserClasses
		includesAll:
		(MiRoassalFrontEnd package definedClasses select: [ :each | (each inheritsFrom: MiAbstractBrowser) and: [ each isAbstract not ] ])
]

{ #category : 'tests' }
MiRoassalFrontEndTest >> testOneBrowserPerName [

	| names |
	names := MiRoassalFrontEnd new browserNames.
	self assert: names asSet size equals: names size
]
