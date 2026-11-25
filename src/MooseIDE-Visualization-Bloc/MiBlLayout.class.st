"
I am the abstract superclass of the layouts that arrange the root nodes of a Bloc map (a MiBlVisualization). A layout sets the Bloc layout and the size constraints of the element holding the root boxes.

## Collaborators & Context
- `MiArchitecturalMapBrowserBl` (the only map that offers a choice of layouts): offers my subclasses to its model (`#availableMapLayouts`, which answers `MiBlLayout class>>#availableLayouts`, and `#defaultMapLayout`).
- `MiArchitecturalMapModel` / its settings: keep the chosen class (`#layout`) and show `#layoutName` and `#layoutDescription` in the settings.
- `MiArchiBlVisualization>>#fillBoxesLayer`: creates an instance of the chosen class and sends it `#applyOn:topElementsCount:`.
- Subclasses: `MiBlFlowLayout`, `MiBlGridLayout`, `MiBlLinearLayout`, `MiBlCircularLayout`. They use Bloc and Toplo layouts.

## Assumptions & Invariants
- The settings handle classes, not instances, as in the Roassal version of the map: what describes a layout is on the class side.
- `#applyOn:topElementsCount:` is sent before the root boxes are added to the element, so it gets their number instead of counting them.
- I am stateless: an instance is only used once, to configure one element.
- A new subclass must be added to `#availableLayouts` to be offered.

## Main API
- Class side: `#availableLayouts` (the classes offered), `#layoutName` (subclass responsibility, the label in the settings), `#layoutDescription` (the help, the name by default), `#isAbstract`.
- Instance side: `#applyOn: anElement topElementsCount: anInteger` (subclass responsibility).

"
Class {
	#name : 'MiBlLayout',
	#superclass : 'Object',
	#category : 'MooseIDE-Visualization-Bloc-layouts',
	#package : 'MooseIDE-Visualization-Bloc',
	#tag : 'layouts'
}

{ #category : 'accessing' }
MiBlLayout class >> availableLayouts [
	"The layouts offered in the settings of a map, e.g. MiArchitecturalMapBrowserBl>>availableMapLayouts"

	^ {
		  MiBlFlowLayout.
		  MiBlGridLayout.
		  MiBlLinearLayout.
		  MiBlCircularLayout }
]

{ #category : 'testing' }
MiBlLayout class >> isAbstract [

	^ self == MiBlLayout
]

{ #category : 'accessing' }
MiBlLayout class >> layoutDescription [
	"Shown in the map settings, as help"

	^ self layoutName
]

{ #category : 'accessing' }
MiBlLayout class >> layoutName [
	"Shown in the map settings"

	^ self subclassResponsibility
]

{ #category : 'layout' }
MiBlLayout >> applyOn: anElement topElementsCount: anInteger [
	"Lay out the root nodes of the map.
	anElement is the element that will hold one child element per root node (the boxes layer of a MiBlVisualization, #fillBoxesLayer). Set its Bloc layout (e.g. a BlGridLayout) and its size constraints (e.g. fitContent).
	anInteger is the number of root nodes. It is given because this method is called before the children are added to anElement, so they cannot be counted there. Some layouts need it, e.g. MiBlGridLayout uses it to choose its number of columns."

	self subclassResponsibility
]
