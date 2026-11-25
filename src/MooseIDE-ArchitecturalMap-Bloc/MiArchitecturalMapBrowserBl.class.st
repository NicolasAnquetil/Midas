"
I am a browser that displays an architectural map with Bloc and Toplo, as `MiArchitecturalMapBrowser` does with Roassal, on the same model (`MiArchitecturalMapModel`). I accept and follow any `MooseObject`.

## Collaborators & Context
- `MiBlMapBrowser`: my superclass, for the Bloc space, its theme, and drawing the map in the UI process of the space.
- `MiArchitecturalMapModel` (`specModel`): holds the entities and the settings. It calls me back (`#runVisualization` after a change of the settings) and asks me the layouts it can offer (`#availableMapLayouts`, `#defaultMapLayout`: `MiBlLayout` subclasses).
- `MiArchiBlTreeBuilder` turns the model into a tree of nodes (`#buildTree`), and `MiArchiBlVisualization` (`view`) draws it (`#newVisualizationOn:`).
- The architectural map entry opens me instead of `MiArchitecturalMapBrowser` when the application says so (`MiArchitecturalMapBrowser class>>#frontEndClass`):
	`MiApplication current architecturalMapBrowserClass: MiArchitecturalMapBrowserBl`

## Assumptions & Invariants
- The selection is made in the map (`MiArchiBlVisualization`), which tells me (`#selectEntities:`); I keep it in the model (`MiArchitecturalMapModel>>#selectedEntities:`). `#miSelectedItem` answers the selected entities, all the entities if none. Each new drawing of the map starts with nothing selected. `#selectRelatedTo:` does nothing.

## Main API
- `MiArchitecturalMapBrowserBl open`, or through the architectural map entry once chosen in the application.
- `#followEntity:`: show the map of anEntity.
- `#availableMapLayouts`, `#defaultMapLayout`: the layouts, for the model.
- `#selectEntities:`: for the selection in the map. The rest of the API comes from `MiBlMapBrowser`.

"
Class {
	#name : 'MiArchitecturalMapBrowserBl',
	#superclass : 'MiBlMapBrowser',
	#category : 'MooseIDE-ArchitecturalMap-Bloc-browser',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'browser'
}

{ #category : 'accessing' }
MiArchitecturalMapBrowserBl class >> defaultPreferredExtent [

	^ 850 @ 520
]

{ #category : 'world menu' }
MiArchitecturalMapBrowserBl class >> menuItem [

	^ #MiArchitecturalMapBrowserBl
]

{ #category : 'instance creation' }
MiArchitecturalMapBrowserBl class >> newModel [

	^ MiArchitecturalMapModel new
]

{ #category : 'instance creation' }
MiArchitecturalMapBrowserBl class >> open [

	<script>
	^ super open
]

{ #category : 'specs' }
MiArchitecturalMapBrowserBl class >> title [

	^ 'Architectural map (Bloc)'
]

{ #category : 'layouts' }
MiArchitecturalMapBrowserBl >> availableMapLayouts [

	^ MiBlLayout availableLayouts
]

{ #category : 'building' }
MiArchitecturalMapBrowserBl >> buildTree [

	^ MiArchiBlTreeBuilder new
		  mapModel: specModel;
		  build;
		  yourself
]

{ #category : 'testing' }
MiArchitecturalMapBrowserBl >> canFollowEntity: anEntity [

	^ anEntity isMooseObject
]

{ #category : 'testing' }
MiArchitecturalMapBrowserBl >> canReceiveEntity: anEntity [

	^ anEntity isMooseObject
]

{ #category : 'layouts' }
MiArchitecturalMapBrowserBl >> defaultMapLayout [

	^ MiBlFlowLayout
]

{ #category : 'actions' }
MiArchitecturalMapBrowserBl >> followEntity: anEntity [

	super followEntity: anEntity.
	specModel entities: anEntity asMooseGroup.
	self runVisualization
]

{ #category : 'accessing' }
MiArchitecturalMapBrowserBl >> miSelectedItem [
	"The entities selected in the map, all the entities if none is selected"

	specModel entities ifNil: [ ^ #(  ) ].
	^ specModel miSelectedItem
]

{ #category : 'building' }
MiArchitecturalMapBrowserBl >> newVisualizationOn: aTree [

	^ MiArchiBlVisualization new
		  tree: aTree;
		  layoutClass: specModel layout;
		  yourself
]

{ #category : 'actions' }
MiArchitecturalMapBrowserBl >> selectEntities: someEntities [
	"Told by the map when its selection changes: the model keeps it (#miSelectedItem)"

	specModel selectedEntities: someEntities
]

{ #category : 'actions' }
MiArchitecturalMapBrowserBl >> selectRelatedTo: anEntity [
	"Not yet: the map only displays"

	
]
