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

{ #category : 'world menu' }
MiArchitecturalMapBrowserBl class >> buildItemInMenu: aMenu action: aBlock [
	"Not listed with the other browsers: the entry of the architectural map opens me when the application says so (MiArchitecturalMapBrowser class>>frontEndClass)"

	^ nil
]

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

{ #category : 'initialization' }
MiArchitecturalMapBrowserBl >> initializePresenters [
	"The theme is given to the space in its own process (BlSpace>>#defer:): its pulse loop already runs, and installing the theme adds event handlers to the root that the loop may use at once (a focus event reached the skin state generator of the root before it knew its element: 'isEnabled sent to nil'). Deferred blocks run in order, so the theme is there before the map is drawn (#runVisualization defers too)"

	super initializePresenters.
	mapPresenter := self instantiate: SpBlSpaceInMorphPresenter.
	self space defer: [ self space toTheme: self toploTheme ].
	self layout: (SpBoxLayout newTopToBottom
			 add: mapPresenter;
			 yourself)
]

{ #category : 'actions' }
MiArchitecturalMapBrowserBl >> inspectEntity: anEntity [
	"Asked by the menu of a box of the map"

	MiInspectorBrowser inspect: anEntity
]

{ #category : 'accessing' }
MiArchitecturalMapBrowserBl >> miSelectedItem [
	"The entities selected in the map, all the entities if none is selected"

	specModel entities ifNil: [ ^ #(  ) ].
	^ specModel miSelectedItem
]

{ #category : 'actions' }
MiArchitecturalMapBrowserBl >> propagateEntity: anEntity [
	"Asked by the menu of a box of the map: propagate anEntity on my buses, as the other maps do, without receiving it back"

	self freezeDuring: [ anEntity miPropagateOn: self buses ]
]

{ #category : 'actions' }
MiArchitecturalMapBrowserBl >> runVisualization [
	"Build the tree from the model here, then show it in the UI process of the Bloc space: an element in an opened space must only be changed there (#defer:)"

	| tree |
	tree := MiArchiBlTreeBuilder new
		        mapModel: specModel;
		        build;
		        yourself.
	self space defer: [ self showTree: tree ]
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

{ #category : 'building' }
MiArchitecturalMapBrowserBl >> showTree: aTree [
	"A new drawing of the map: nothing is selected in it, so nothing is in the model either"

	| root |
	root := self space root.
	view := MiArchiBlVisualization new
		        tree: aTree;
		        layoutClass: specModel layout;
		        tokenSource: root;
		        browser: self;
		        yourself.
	specModel selectedEntities: #(  ).
	root removeChildren.
	root addChild: view viewport
]

{ #category : 'accessing' }
MiArchitecturalMapBrowserBl >> space [

	^ mapPresenter space
]

{ #category : 'styling' }
MiArchitecturalMapBrowserBl >> toploTheme [
	"A Toplo theme light or dark as the Pharo one"

	^ Smalltalk ui theme backgroundColor luminance < 0.5
		  ifTrue: [ ToRawDarkTheme new ]
		  ifFalse: [ ToRawTheme new ]
]

{ #category : 'accessing' }
MiArchitecturalMapBrowserBl >> view [
	"The MiArchiBlVisualization shown, nil before the first entities"

	^ view
]
