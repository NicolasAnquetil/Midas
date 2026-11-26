"
I am a browser that displays a butterfly map with Bloc and Toplo, as `MiButterflyMapBrowser` does with Roassal, on the same model (`MiButterflyMapModel`): an entity in the middle, its clients on the left and its providers on the right, level by level. I accept and follow any Moose entity, which becomes the central one.

## Collaborators & Context
- `MiBlMapBrowser`: my superclass, for the Bloc space, its theme, and drawing the map in the UI process of the space.
- `MiButterflyMapModel` (`specModel`): holds the central entity and the queries of the settings (children, clients, providers). Changing the central entity, or the settings, makes it call me back (`#runVisualization`).
- `MiButterflyBlTree` turns the model into the butterfly (`#buildTree`), and `MiButterflyBlVisualization` (`view`) draws it (`#newVisualizationOn:`).
- I am a browser of the Bloc front-end (`MiBlocFrontEnd`), under the name of the Roassal map (`#menuLabel`, hence `#browserName`): with that front-end, the Moose menu offers me, and opening `MiButterflyMapBrowser` opens me:
	`MiApplication current frontEnd: MiBlocFrontEnd new`

## Assumptions & Invariants
- The selection is made in the map, which tells me (`#selectEntities:`); I keep it in the model (`MiButterflyMapModel>>#selectedEntities:`). `#miSelectedItem` answers the selected entities, the central entity if none. Each new drawing starts with nothing selected.
- Be central node, in the menu of a box, makes its entity the central one (`#centralEntity:`): the whole map is built and drawn again.

## Main API
- `MiButterflyMapBrowserBl open`, or through the butterfly map entry with the Bloc front-end.
- `#followEntity:`: show the butterfly map of anEntity. `#centralEntity:`: the same, from the map.
- `#selectEntities:`: for the selection in the map. The rest of the API comes from `MiBlMapBrowser`.

"
Class {
	#name : 'MiButterflyMapBrowserBl',
	#superclass : 'MiBlMapBrowser',
	#category : 'MooseIDE-Bloc-ButterflyMap-browser',
	#package : 'MooseIDE-Bloc-ButterflyMap',
	#tag : 'browser'
}

{ #category : 'accessing' }
MiButterflyMapBrowserBl class >> defaultPreferredExtent [

	^ 850 @ 520
]

{ #category : 'world menu' }
MiButterflyMapBrowserBl class >> menuIconName [

	^ #mooseButterfly
]

{ #category : 'world menu' }
MiButterflyMapBrowserBl class >> menuItem [

	^ #MiButterflyMapBrowserBl
]

{ #category : 'world menu' }
MiButterflyMapBrowserBl class >> menuLabel [
	"The name of the Roassal version (#browserName): the Bloc front-end offers me in its place"

	^ 'Butterfly map'
]

{ #category : 'world menu' }
MiButterflyMapBrowserBl class >> menuPriority [

	^ self menuVisualizationToolsPriority + 2
]

{ #category : 'instance creation' }
MiButterflyMapBrowserBl class >> newModel [

	^ MiButterflyMapModel new
]

{ #category : 'instance creation' }
MiButterflyMapBrowserBl class >> open [

	<script>
	^ super open
]

{ #category : 'specs' }
MiButterflyMapBrowserBl class >> title [

	^ 'Butterfly map (Bloc)'
]

{ #category : 'building' }
MiButterflyMapBrowserBl >> buildTree [

	^ MiButterflyBlTree new
		  mapModel: specModel;
		  build;
		  yourself
]

{ #category : 'testing' }
MiButterflyMapBrowserBl >> canFollowEntity: anEntity [

	^ anEntity isMooseEntity
]

{ #category : 'actions' }
MiButterflyMapBrowserBl >> centralEntity: anEntity [
	"Asked by the menu of a box of the map (Be central node): draw the map of anEntity instead"

	specModel currentEntity: anEntity
]

{ #category : 'actions' }
MiButterflyMapBrowserBl >> followEntity: anEntity [
	"The map of anEntity: the model draws it again (MiButterflyMapModel>>#currentEntity: sends #runVisualization)"

	super followEntity: anEntity.
	specModel currentEntity: anEntity
]

{ #category : 'brokerage' }
MiButterflyMapBrowserBl >> itemsFor: aClass [

	^ self application itemsFor: aClass
]

{ #category : 'accessing' }
MiButterflyMapBrowserBl >> miSelectedItem [
	"The entities selected in the map, the central entity if none is selected"

	^ specModel miSelectedItem
]

{ #category : 'building' }
MiButterflyMapBrowserBl >> newVisualizationOn: aTree [

	^ MiButterflyBlVisualization new
		  tree: aTree;
		  yourself
]

{ #category : 'actions' }
MiButterflyMapBrowserBl >> selectEntities: someEntities [
	"Told by the map when its selection changes: the model keeps it (#miSelectedItem)"

	specModel selectedEntities: someEntities
]
