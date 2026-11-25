"
I test `MiFrontEnd`: the common browsers (those of no front-end), finding a browser by its name, what opens for a browser it does not offer, its Moose menu, and the default front-end of the application.

## Collaborators & Context
- `MiAbstractApplicationTest` gives each test its own application (`#application`): no test changes the front-end in use.
- The front-ends of the graphics libraries are tested in their own test packages (`MiRoassalFrontEndTest`, `MiBlocFrontEndTest`).

## Assumptions & Invariants
- The tag browser is a common browser (it depends on no graphics library).

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

	self assert: self application frontEnd class identicalTo: MiFrontEnd default class
]

{ #category : 'tests' }
MiFrontEndTest >> testBrowserNamed [

	self assert: (MiFrontEnd new browserNamed: MiTagBrowser browserName) identicalTo: MiTagBrowser.
	self assert: (MiFrontEnd new browserNamed: 'no such browser' ifNone: [ #none ]) equals: #none
]

{ #category : 'tests' }
MiFrontEndTest >> testBrowserNotOfferedOpensAsItself [
	"A browser of a front-end, opened with only the common browsers, opens as itself"

	| specific |
	specific := MiFrontEnd allSpecificBrowserClasses anyOne.
	self assert: (MiFrontEnd new browserClassFor: specific) identicalTo: specific
]

{ #category : 'tests' }
MiFrontEndTest >> testCommonBrowsersAreInNoFrontEnd [
	"MiFrontEnd offers the browsers of no front-end, e.g. the tag browser"

	| common |
	common := MiFrontEnd new browserClasses.
	self assert: (common includes: MiTagBrowser).
	self deny: (common anySatisfy: [ :each | MiFrontEnd allSpecificBrowserClasses includes: each ])
]

{ #category : 'tests' }
MiFrontEndTest >> testMenuBrowsers [

	self assert: (MiFrontEnd new menuBrowserClasses allSatisfy: [ :each | each isInMooseMenu ]).
	self assert: (MiFrontEnd new menuBrowserClasses includes: MiTagBrowser)
]
