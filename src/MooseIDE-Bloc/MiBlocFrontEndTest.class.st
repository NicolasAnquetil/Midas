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
	#category : 'MooseIDE-Bloc-tests',
	#package : 'MooseIDE-Bloc',
	#tag : 'tests'
}

{ #category : 'tests' }
MiBlocFrontEndTest >> testBrowserNamed [
	"Each browser of mine is found under its name, and opens as itself (the tests of the maps check that a Bloc map opens instead of its Roassal version)"

	| frontEnd |
	frontEnd := MiBlocFrontEnd new.
	frontEnd specificBrowserClasses do: [ :each |
			self assert: (frontEnd browserNamed: each browserName) identicalTo: each.
			self assert: (frontEnd browserClassFor: each) identicalTo: each ]
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
MiBlocFrontEndTest >> testOffersOnlyBlocBrowsers [

	self assert: (MiBlocFrontEnd new specificBrowserClasses allSatisfy: [ :each | each inheritsFrom: MiBlMapBrowser ])
]

{ #category : 'tests' }
MiBlocFrontEndTest >> testOneBrowserPerName [

	| names |
	names := MiBlocFrontEnd new browserNames.
	self assert: names asSet size equals: names size
]
