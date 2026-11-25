"
I am a front-end of Midas: the set of browsers it offers, each under its name. The browsers that depend on a graphics library (Roassal, Bloc) belong to the front-end of that library, defined in the same package as them; I offer the others, common to all the front-ends.

## Collaborators & Context
- Subclasses, each in the package of its browsers: `MiRoassalFrontEnd` (MooseIDE-Roassal), `MiBlocFrontEnd` (MooseIDE-Bloc). If a package is not loaded, its front-end and its browsers are not there.
- `MiApplication` (`#frontEnd`, `#frontEnd:`): holds the front-end in use, by default the one that says so (`#default`, `#isDefault`).
- `MiAbstractBrowser` (class side): `#browserName`, the name a browser is offered under (its menu label by default); `#isInMooseMenu`; `#frontEndClass`, what opens when the browser is opened (`#browserClassFor:`); `#browsersMenuOn:`, the Moose menu, made of my `#menuBrowserClasses`.

## Assumptions & Invariants
- Each subclass lists its own browsers (`#specificBrowserClasses`). The common browsers are all the concrete browsers that no loaded front-end lists (`#commonBrowserClasses`): a new browser that depends on no graphics library is in every front-end without being declared.
- The versions of a tool for two front-ends have the same name (e.g. 'Architectural map'), so opening one opens the version of the front-end in use; a front-end offers at most one browser per name.
- A browser that the front-end in use does not offer opens as itself (`#browserClassFor:`).
- I am abstract (`#isAbstract`): used alone (no front-end loaded, `#default`), I offer the common browsers only.
- Stateless: the browsers are computed when asked.

## Main API
- `MiApplication current frontEnd: MiBlocFrontEnd new` (or `MiRoassalFrontEnd new`).
- `#browserClasses`, `#browserNames`, `#browserNamed:` (and `#browserNamed:ifNone:`), `#menuBrowserClasses`, `#browserClassFor:`.
- A subclass: `#specificBrowserClasses`, and `#isDefault` on the class side.

"
Class {
	#name : 'MiFrontEnd',
	#superclass : 'Object',
	#category : 'MooseIDE-Core-Application',
	#package : 'MooseIDE-Core',
	#tag : 'Application'
}

{ #category : 'accessing' }
MiFrontEnd class >> allSpecificBrowserClasses [
	"The browser classes that belong to a front-end: those listed by any loaded front-end (whatever the receiver). Every other browser is common to all the front-ends"

	^ (MiFrontEnd allSubclasses flatCollect: [ :each | each new specificBrowserClasses ]) asIdentitySet
]

{ #category : 'instance creation' }
MiFrontEnd class >> default [
	"A new instance of the front-end of a new application: the loaded one that says it is the default (MiRoassalFrontEnd), or else me, with the common browsers only"

	^ (self allSubclasses detect: [ :each | each isDefault ] ifNone: [ self ]) new
]

{ #category : 'testing' }
MiFrontEnd class >> isAbstract [

	^ self == MiFrontEnd
]

{ #category : 'testing' }
MiFrontEnd class >> isDefault [
	"Whether I am the front-end of a new application, when my package is loaded"

	^ false
]

{ #category : 'accessing' }
MiFrontEnd >> browserClassFor: aBrowserClass [
	"The class to open when aBrowserClass is opened: the browser I offer under its name (the version of a map for my graphics library), aBrowserClass itself if I offer none"

	^ self browserNamed: aBrowserClass browserName ifNone: [ aBrowserClass ]
]

{ #category : 'accessing' }
MiFrontEnd >> browserClasses [
	"All the browsers I offer: the common ones and mine"

	^ self commonBrowserClasses , self specificBrowserClasses
]

{ #category : 'accessing' }
MiFrontEnd >> browserNamed: aString [

	^ self browserNamed: aString ifNone: [ NotFound signalFor: aString in: self ]
]

{ #category : 'accessing' }
MiFrontEnd >> browserNamed: aString ifNone: aBlock [
	"The browser I offer under the name aString (MiAbstractBrowser class>>#browserName)"

	^ self browserClasses detect: [ :each | each browserName = aString ] ifNone: aBlock
]

{ #category : 'accessing' }
MiFrontEnd >> browserNames [

	^ self browserClasses collect: [ :each | each browserName ] as: Array
]

{ #category : 'accessing' }
MiFrontEnd >> commonBrowserClasses [
	"The browsers of every front-end: the concrete browsers that no front-end lists as its own (they depend on no graphics library of a front-end)"

	| specific |
	specific := MiFrontEnd allSpecificBrowserClasses.
	^ MiAbstractBrowser allBrowsers reject: [ :each | specific includes: each ]
]

{ #category : 'accessing' }
MiFrontEnd >> menuBrowserClasses [
	"The browsers I put in the Moose menu"

	^ self browserClasses select: [ :each | each isInMooseMenu ]
]

{ #category : 'accessing' }
MiFrontEnd >> specificBrowserClasses [
	"The browsers that only I offer, because they depend on my graphics library. None here: a subclass lists its own"

	^ #(  )
]
