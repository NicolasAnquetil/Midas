"
I am the abstract superclass of the layouts that arrange the root nodes of the Bloc architectural map. A layout sets the Bloc layout and the size constraints of the element holding the root boxes.

## Collaborators & Context
- `MiArchitecturalMapBrowserBl`: offers my subclasses to its model (`#availableMapLayouts`, which answers `MiArchiBlLayout class>>#availableLayouts`, and `#defaultMapLayout`).
- `MiArchitecturalMapModel` / its settings: keep the chosen class (`#layout`) and show `#layoutName` and `#layoutDescription` in the settings.
- `MiArchiBlVisualization>>#buildNodesLayer`: creates an instance of the chosen class and sends it `#applyOn:topElementsCount:`.
- Subclasses: `MiArchiBlFlowLayout`, `MiArchiBlGridLayout`, `MiArchiBlLinearLayout`, `MiArchiBlCircularLayout`. They use Bloc and Toplo layouts.

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
	#name : 'MiArchiBlLayout',
	#superclass : 'Object',
	#category : 'MooseIDE-ArchitecturalMap-Bloc-data',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'data'
}

{ #category : 'accessing' }
MiArchiBlLayout class >> availableLayouts [
	"What MiArchitecturalMapBrowserBl>>availableMapLayouts answers"

	^ {
		  MiArchiBlFlowLayout.
		  MiArchiBlGridLayout.
		  MiArchiBlLinearLayout.
		  MiArchiBlCircularLayout }
]

{ #category : 'accessing' }
MiArchiBlLayout class >> isAbstract [

	^ self == MiArchiBlLayout
]

{ #category : 'accessing' }
MiArchiBlLayout class >> layoutDescription [
	"Shown in the map settings, as help"

	^ self layoutName
]

{ #category : 'accessing' }
MiArchiBlLayout class >> layoutName [
	"Shown in the map settings"

	^ self subclassResponsibility
]

{ #category : 'layout' }
MiArchiBlLayout >> applyOn: anElement topElementsCount: anInteger [
	"Lay out the root nodes of the map.
	anElement is the element that will hold one child element per root node (nodesLayer in MiArchiBlVisualization>>#buildNodesLayer). Set its Bloc layout (e.g. a BlGridLayout) and its size constraints (e.g. fitContent).
	anInteger is the number of root nodes. It is given because this method is called before the children are added to anElement, so they cannot be counted there. Some layouts need it, e.g. MiArchiBlGridLayout uses it to choose its number of columns."

	self subclassResponsibility
]
