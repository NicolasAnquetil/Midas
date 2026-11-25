"
I am the Bloc front-end of Midas: the browsers drawn with Bloc and Toplo, plus the common ones (`MiFrontEnd`). A map I offer has the name of its Roassal version, so it opens instead of it.

## Collaborators & Context
- `MiFrontEnd`: my superclass, which offers my `#specificBrowserClasses` with the common browsers, under their names.
- My browsers are in my package, MooseIDE-Bloc: `MiBlMapBrowser` and its subclasses (`MiArchitecturalMapBrowserBl`, `MiButterflyMapBrowserBl`). Their visualizations stay in the -Bloc packages of the tools (MooseIDE-ArchitecturalMap-Bloc...), the generic one in MooseIDE-Visualization-Bloc.
- `MiApplication>>#frontEnd:` installs me.

## Assumptions & Invariants
- I list all the concrete browsers of my package, and only them.
- The Roassal tools without a Bloc version are not offered: they need Roassal.
- Stateless.

## Main API
- `MiApplication current frontEnd: MiBlocFrontEnd new`
- `#specificBrowserClasses`; the rest from `MiFrontEnd`.

"
Class {
	#name : 'MiBlocFrontEnd',
	#superclass : 'MiFrontEnd',
	#category : 'MooseIDE-Bloc-front-end',
	#package : 'MooseIDE-Bloc',
	#tag : 'front-end'
}

{ #category : 'accessing' }
MiBlocFrontEnd >> specificBrowserClasses [
	"The browsers drawn with Bloc and Toplo"

	^ {
		  MiArchitecturalMapBrowserBl.
		  MiButterflyMapBrowserBl }
]
