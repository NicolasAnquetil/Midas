"
I am the Bloc front-end of Midas: the browsers drawn with Bloc and Toplo, plus the common ones (`MiFrontEnd`). A map I offer has the name of its Roassal version, so it opens instead of it.

## Collaborators & Context
- `MiFrontEnd`: my superclass, which offers my browsers with the common ones, under their names.
- My browsers are those that answer me from `#specificFrontEndClass`: `MiBlMapBrowser` (in my package, MooseIDE-Bloc) and its subclasses. These are in the MooseIDE-Bloc-<tool> packages with the visualizations of their tools: `MiArchitecturalMapBrowserBl` in MooseIDE-Bloc-ArchitecturalMap, `MiButterflyMapBrowserBl` in MooseIDE-Bloc-ButterflyMap. The generic visualization is in MooseIDE-Visualization-Bloc.
- `MiApplication>>#frontEnd:` installs me.

## Assumptions & Invariants
- MooseIDE-Bloc does not refer to the MooseIDE-Bloc-<tool> packages: they require it.
- The Roassal tools without a Bloc version are not offered: they need Roassal.
- Stateless.

## Main API
- `MiApplication current frontEnd: MiBlocFrontEnd new`
- everything from `MiFrontEnd`.

"
Class {
	#name : 'MiBlocFrontEnd',
	#superclass : 'MiFrontEnd',
	#category : 'MooseIDE-Bloc-browsers',
	#package : 'MooseIDE-Bloc',
	#tag : 'browsers'
}
