"
I am the abstract superclass of the layouts that arrange the root nodes of the Bloc architectural map (MiArchitecturalMapBrowserBl).

The list of layouts the user can pick in the map settings is MiArchitecturalMapLayoutBl class>>#availableLayouts. It contains classes, not instances, as in the Roassal version of the map. This is why each subclass defines on its class side:
- #layoutName: the label shown in the settings
- #layoutDescription: the help text (by default, the name)

When a layout is chosen, the browser creates an instance and sends it #applyOn:topElementsCount:, with the element holding the root nodes and their number. The instance sets that element's layout and size constraints.
"
Class {
	#name : 'MiArchitecturalMapLayoutBl',
	#superclass : 'Object',
	#category : 'MooseIDE-ArchitecturalMap-Bloc',
	#package : 'MooseIDE-ArchitecturalMap-Bloc'
}

{ #category : 'accessing' }
MiArchitecturalMapLayoutBl class >> availableLayouts [
	"What MiArchitecturalMapBrowserBl>>availableMapLayouts answers"

	^ {
		  MiArchitecturalMapFlowLayoutBl.
		  MiArchitecturalMapGridLayoutBl.
		  MiArchitecturalMapLinearLayoutBl.
		  MiArchitecturalMapCircularLayoutBl }
]

{ #category : 'accessing' }
MiArchitecturalMapLayoutBl class >> isAbstract [

	^ self == MiArchitecturalMapLayoutBl
]

{ #category : 'accessing' }
MiArchitecturalMapLayoutBl class >> layoutDescription [
	"Shown in the map settings, as help"

	^ self layoutName
]

{ #category : 'accessing' }
MiArchitecturalMapLayoutBl class >> layoutName [
	"Shown in the map settings"

	^ self subclassResponsibility
]

{ #category : 'layout' }
MiArchitecturalMapLayoutBl >> applyOn: anElement topElementsCount: anInteger [
	"Lay out the root nodes of the map.
	anElement is the element that will hold one child element per root node (nodesLayer in MiArchitecturalMapViewBl>>#build). Set its Bloc layout (e.g. a BlGridLayout) and its size constraints (e.g. fitContent).
	anInteger is the number of root nodes. It is given because this method is called before the children are added to anElement, so they cannot be counted there. Some layouts need it, e.g. MiArchitecturalMapGridLayoutBl uses it to choose its number of columns."

	self subclassResponsibility
]
