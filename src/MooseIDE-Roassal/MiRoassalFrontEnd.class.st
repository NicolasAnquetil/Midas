"
I am the Roassal front-end of Midas: the browsers drawn with Roassal, plus the common ones (`MiFrontEnd`). I am the default front-end of the application when loaded (`#isDefault`).

## Collaborators & Context
- `MiFrontEnd`: my superclass, which offers my browsers with the common ones, under their names.
- My browsers are those that answer me from `#specificFrontEndClass`: `MiAbstractVisualizationBrowser` (in my package, MooseIDE-Roassal) and its subclasses, and the browsers that draw with Roassal without being one: DSM (`MiDSMBrowser`), meta browser (`MiMetaBrowser`, a UML map), layer visualization (`MiLayerVisualizationBrowser`), queries dashboard (`MiQueriesDashboardBrowser`, its results are Roassal shapes).
- The browsers are in the MooseIDE-Roassal-<tool> packages with the rest of the Roassal code of their tools (`MiArchitecturalMapBrowser` in MooseIDE-Roassal-ArchitecturalMap, `MiUMLBrowser` in MooseIDE-Roassal-UML, `MiMetaBrowser` in MooseIDE-Roassal-MetaBrowser...); their models stay in the packages of the tools (MooseIDE-<tool>, MooseIDE-Famix for UML, MooseIDE-Meta for the meta browser). The exception is the co-usage map: its browser is still in my package, because its model opens a settings dialog made of Roassal sliders.

## Assumptions & Invariants
- MooseIDE-Roassal does not refer to the MooseIDE-Roassal-<tool> packages: they require it.
- Stateless.

## Main API
- `MiApplication current frontEnd: MiRoassalFrontEnd new`
- everything from `MiFrontEnd`.

"
Class {
	#name : 'MiRoassalFrontEnd',
	#superclass : 'MiFrontEnd',
	#category : 'MooseIDE-Roassal-browsers',
	#package : 'MooseIDE-Roassal',
	#tag : 'browsers'
}

{ #category : 'testing' }
MiRoassalFrontEnd class >> isDefault [

	^ true
]
