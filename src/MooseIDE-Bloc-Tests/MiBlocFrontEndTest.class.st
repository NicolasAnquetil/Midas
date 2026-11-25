"
I test `MiBlocFrontEnd`: it lists all the browsers of its package, offers them with the common ones, one per name, under the names of the Roassal maps, and puts them in the Moose menu.

## Collaborators & Context
- `MiFrontEnd`: the common browsers (`MiFrontEndTest`).

## Assumptions & Invariants
- No test changes the front-end of the application.

## Main API
- The tests only.

"
Class {
	#name : 'MiBlocFrontEndTest',
	#superclass : 'TestCase',
	#category : 'MooseIDE-Bloc-Tests',
	#package : 'MooseIDE-Bloc-Tests'
}

{ #category : 'tests' }
MiBlocFrontEndTest >> testListsAllTheBrowsersOfItsPackage [

	self
		assertCollection: MiBlocFrontEnd new specificBrowserClasses
		hasSameElements: (MiBlocFrontEnd package definedClasses select: [ :each | (each inheritsFrom: MiAbstractBrowser) and: [ each isAbstract not ] ])
]

{ #category : 'tests' }
MiBlocFrontEndTest >> testMapsUnderTheNamesOfTheRoassalOnes [
	"The names of the Roassal maps give the Bloc ones (opening a Roassal map opens its Bloc version: see MiArchitecturalMapBrowserBlTest)"

	self assert: (MiBlocFrontEnd new browserNamed: 'Architectural map') identicalTo: MiArchitecturalMapBrowserBl.
	self assert: (MiBlocFrontEnd new browserNamed: 'Butterfly map') identicalTo: MiButterflyMapBrowserBl.
	self assert: (MiBlocFrontEnd new browserClassFor: MiButterflyMapBrowserBl) identicalTo: MiButterflyMapBrowserBl
]

{ #category : 'tests' }
MiBlocFrontEndTest >> testMenu [

	self assert: (MiBlocFrontEnd new menuBrowserClasses includesAll: { MiArchitecturalMapBrowserBl. MiButterflyMapBrowserBl })
]

{ #category : 'tests' }
MiBlocFrontEndTest >> testOffersItsBrowsersAndTheCommonOnes [
	"And no browser of another front-end"

	| browsers mine |
	browsers := MiBlocFrontEnd new browserClasses.
	mine := MiBlocFrontEnd new specificBrowserClasses.
	self assert: (browsers includesAll: mine).
	self assert: (browsers includesAll: MiFrontEnd new browserClasses).
	self deny: (browsers anySatisfy: [ :each | (MiFrontEnd allSpecificBrowserClasses includes: each) and: [ (mine includes: each) not ] ])
]

{ #category : 'tests' }
MiBlocFrontEndTest >> testOneBrowserPerName [

	| names |
	names := MiBlocFrontEnd new browserNames.
	self assert: names asSet size equals: names size
]
