"
I am a front-end of Midas: the set of browser classes it opens. When a browser is opened (`MiAbstractBrowser class>>#openRunning:`), the front-end of the application says which class to open for it (`#browserClassFor:`): one of my browser classes if it replaces that browser, the browser itself otherwise.

## Collaborators & Context
- `MiApplication` (`#frontEnd`, `#frontEnd:`): holds the front-end in use, me by default.
- `MiAbstractBrowser class>>#frontEndClass`: asks the front-end of the application what to open for the receiver. A browser class says which browser it replaces with `#replacedBrowserClass` (class side, nil by default).
- Subclasses: `MiBlocFrontEnd`, the browsers drawn with Bloc and Toplo instead of Roassal.

## Assumptions & Invariants
- I hold no browser class: every browser opens as itself (the Roassal ones for the maps).
- A browser class replaces at most one browser, and a front-end has at most one browser class replacing a given browser.
- A browser class of a front-end does not replace itself, so opening it opens it.
- Stateless: the browser classes are computed when asked.

## Main API
- `MiApplication current frontEnd: MiBlocFrontEnd new` (or `MiFrontEnd new` for the default one).
- `#browserClassFor:` a browser class: the class to open. `#browserClasses`: those of this front-end.

"
Class {
	#name : 'MiFrontEnd',
	#superclass : 'Object',
	#category : 'MooseIDE-Core-Application',
	#package : 'MooseIDE-Core',
	#tag : 'Application'
}

{ #category : 'accessing' }
MiFrontEnd >> browserClassFor: aBrowserClass [
	"The class to open for aBrowserClass: the one of my browser classes that replaces it, aBrowserClass itself if none does"

	^ self browserClasses
		  detect: [ :each | each replacedBrowserClass == aBrowserClass ]
		  ifNone: [ aBrowserClass ]
]

{ #category : 'accessing' }
MiFrontEnd >> browserClasses [
	"The browser classes of this front-end, each opened instead of the browser it replaces (its class side #replacedBrowserClass). None: every browser opens as itself"

	^ #(  )
]
