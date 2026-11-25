"
I am the Roassal front-end of Midas: the browsers drawn with Roassal, plus the common ones (`MiFrontEnd`). I am the default front-end of the application when loaded (`#isDefault`).

## Collaborators & Context
- `MiFrontEnd`: my superclass, which offers my `#specificBrowserClasses` with the common browsers, under their names.
- My browsers are in my package, MooseIDE-Roassal: `MiAbstractVisualizationBrowser` and its subclasses (architectural map, butterfly map, class blueprint, co-usage map, distribution map, heat map, system complexity, UML). Their models and Roassal builders stay in the packages of the tools.

## Assumptions & Invariants
- I list all the concrete browsers of my package, and only them.
- Stateless.

## Main API
- `MiApplication current frontEnd: MiRoassalFrontEnd new`
- `#specificBrowserClasses`; the rest from `MiFrontEnd`.

"
Class {
	#name : 'MiRoassalFrontEnd',
	#superclass : 'MiFrontEnd',
	#category : 'MooseIDE-Roassal-front-end',
	#package : 'MooseIDE-Roassal',
	#tag : 'front-end'
}

{ #category : 'testing' }
MiRoassalFrontEnd class >> isDefault [

	^ true
]

{ #category : 'accessing' }
MiRoassalFrontEnd >> specificBrowserClasses [
	"The browsers drawn with Roassal"

	^ {
		  MiArchitecturalMapBrowser.
		  MiButterflyMapBrowser.
		  MiClassBlueprintBrowser.
		  MiCoUsageMapBrowser.
		  MiDistributionMapBrowser.
		  MiHeatMapBrowser.
		  MiSystemComplexityBrowser.
		  MiUMLBrowser }
]
