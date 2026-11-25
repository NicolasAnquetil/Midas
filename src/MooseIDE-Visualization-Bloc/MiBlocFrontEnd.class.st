"
I am the Bloc front-end of Midas: the maps drawn with Bloc and Toplo open instead of their Roassal versions. The other browsers open as themselves.

## Collaborators & Context
- `MiFrontEnd`: my superclass, which uses my `#browserClasses` to answer `#browserClassFor:`.
- `MiBlMapBrowser`: my browser classes are its concrete subclasses (`MiArchitecturalMapBrowserBl`, `MiButterflyMapBrowserBl`...). Each says, on its class side, which browser it replaces (`#replacedBrowserClass`).
- `MiApplication>>#frontEnd:` installs me.

## Assumptions & Invariants
- I find my browser classes when asked: a new Bloc map, once loaded, is part of me without changing me. So I do not need to know their packages (they depend on mine).
- Stateless.

## Main API
- `MiApplication current frontEnd: MiBlocFrontEnd new`
- `#browserClasses`, `#browserClassFor:` (from `MiFrontEnd`).

"
Class {
	#name : 'MiBlocFrontEnd',
	#superclass : 'MiFrontEnd',
	#category : 'MooseIDE-Visualization-Bloc-browser',
	#package : 'MooseIDE-Visualization-Bloc',
	#tag : 'browser'
}

{ #category : 'accessing' }
MiBlocFrontEnd >> browserClasses [
	"The Bloc browsers: every concrete subclass of MiBlMapBrowser, each opened instead of the Roassal browser it replaces"

	^ MiBlMapBrowser allSubclasses reject: [ :each | each isAbstract ]
]
