"
I am the abstract superclass of the Midas browsers that draw a map with Bloc and Toplo (`MiBlVisualization`). I hold what they share: the Bloc space embedded in Spec, its Toplo theme, and drawing a new map each time the model changes, in the UI process of the space.

## Collaborators & Context
- Subclasses: `MiArchitecturalMapBrowserBl`, `MiButterflyMapBrowserBl`. Each is the Bloc front-end of a Roassal browser, on the same model, opened instead of it when the application says so.
- `SpBlSpaceInMorphPresenter` (`mapPresenter`): embeds the Bloc space of the map in Spec. I give the space a Toplo theme, light or dark like the Pharo theme (`#toploTheme`).
- The visualization (`view`, a `MiBlVisualization` subclass made by `#newVisualizationOn:`): I am its browser. It tells me the selected entities (`#selectEntities:`), and the menu of a box asks me to inspect (`MiInspectorBrowser`) or propagate (on my buses) the entity of its node.
- `MiAbstractBrowser`: I am a Midas browser (bus, follow / receive entities). I am not in the world menu (`#buildItemInMenu:action:`).

## Assumptions & Invariants
- I am abstract (`#isAbstract`): subclasses define `#buildTree`, `#newVisualizationOn:` and `#selectEntities:`.
- The tree is built in the calling process (`#runVisualization`), but drawn in the Bloc UI process of the space (`#showTree:`, through `BlSpace>>#defer:`): Bloc elements must only be touched there.
- The theme is installed in the UI process too, before the first drawing (deferred blocks run in order, see `#initializePresenters`).
- Each run replaces the whole drawing: a new visualization replaces the children of the space root, and starts with nothing selected (`#selectEntities:` with none).
- `view` is nil until the first drawing.

## Main API
- A subclass: `#buildTree` (the tree of the map, from the model), `#newVisualizationOn:` (the visualization for it), `#selectEntities:` (keep the selection).
- `#runVisualization`: rebuild and redraw the map from the model.
- `#inspectEntity:`, `#propagateEntity:`: for the menu of the boxes of the map.
- `#space`, `#view`: the Bloc space and the visualization shown.

"
Class {
	#name : 'MiBlMapBrowser',
	#superclass : 'MiAbstractBrowser',
	#instVars : [
		'mapPresenter',
		'view'
	],
	#category : 'MooseIDE-Visualization-Bloc-browser',
	#package : 'MooseIDE-Visualization-Bloc',
	#tag : 'browser'
}

{ #category : 'menu' }
MiBlMapBrowser class >> buildItemInMenu: aMenu action: aBlock [
	"Not in the world menu: a map opens a Bloc front-end when the application says so"

	^ nil
]

{ #category : 'testing' }
MiBlMapBrowser class >> isAbstract [

	^ self == MiBlMapBrowser
]

{ #category : 'building' }
MiBlMapBrowser >> buildTree [
	"Answer the tree of the map, built from the model. Sent in the calling process, not in the UI process of the space (#runVisualization)"

	^ self subclassResponsibility
]

{ #category : 'initialization' }
MiBlMapBrowser >> initializePresenters [
	"The theme is given to the space in its own process (BlSpace>>#defer:): its pulse loop already runs, and installing the theme adds event handlers to the root that the loop may use at once (a focus event reached the skin state generator of the root before it knew its element: 'isEnabled sent to nil'). Deferred blocks run in order, so the theme is there before the map is drawn (#runVisualization defers too)"

	super initializePresenters.
	mapPresenter := self instantiate: SpBlSpaceInMorphPresenter.
	self space defer: [ self space toTheme: self toploTheme ].
	self layout: (SpBoxLayout newTopToBottom
			 add: mapPresenter;
			 yourself)
]

{ #category : 'actions' }
MiBlMapBrowser >> inspectEntity: anEntity [
	"Asked by the menu of a box of the map"

	MiInspectorBrowser inspect: anEntity
]

{ #category : 'building' }
MiBlMapBrowser >> newVisualizationOn: aTree [
	"Answer a new visualization (a MiBlVisualization subclass) of aTree. #showTree: then gives it its token source and its browser"

	^ self subclassResponsibility
]

{ #category : 'actions' }
MiBlMapBrowser >> propagateEntity: anEntity [
	"Asked by the menu of a box of the map: propagate anEntity on my buses, as the other maps do, without receiving it back"

	self freezeDuring: [ anEntity miPropagateOn: self buses ]
]

{ #category : 'actions' }
MiBlMapBrowser >> runVisualization [
	"Build the tree from the model here (#buildTree), then show it in the UI process of the Bloc space: an element in an opened space must only be changed there (#defer:)"

	| tree |
	tree := self buildTree.
	self space defer: [ self showTree: tree ]
]

{ #category : 'actions' }
MiBlMapBrowser >> selectEntities: someEntities [
	"Told by the map when its selection changes, and with none when a new drawing starts (#showTree:)"

	^ self subclassResponsibility
]

{ #category : 'building' }
MiBlMapBrowser >> showTree: aTree [
	"A new drawing of the map, in the UI process of the space: it replaces the whole previous one. Nothing is selected in it, so the selection is told empty"

	| root |
	root := self space root.
	view := (self newVisualizationOn: aTree)
		        tokenSource: root;
		        browser: self;
		        yourself.
	self selectEntities: #(  ).
	root removeChildren.
	root addChild: view viewport
]

{ #category : 'accessing' }
MiBlMapBrowser >> space [

	^ mapPresenter space
]

{ #category : 'styling' }
MiBlMapBrowser >> toploTheme [
	"A Toplo theme light or dark as the Pharo one"

	^ Smalltalk ui theme backgroundColor luminance < 0.5
		  ifTrue: [ ToRawDarkTheme new ]
		  ifFalse: [ ToRawTheme new ]
]

{ #category : 'accessing' }
MiBlMapBrowser >> view [
	"The visualization shown (a MiBlVisualization subclass), nil before the first entities"

	^ view
]
