"
I am a browser that displays an architectural map with Bloc and Toplo, as `MiArchitecturalMapBrowser` does with Roassal, on the same model (`MiArchitecturalMapModel`). I accept and follow any `MooseObject`.

## Collaborators & Context
- `MiArchitecturalMapModel` (`specModel`): holds the entities and the settings. It calls me back (`#runVisualization` after a change of the settings) and asks me the layouts it can offer (`#availableMapLayouts`, `#defaultMapLayout`: `MiArchiBlLayout` subclasses).
- `MiArchiBlTreeBuilder` turns the model into a tree of nodes, and `MiArchiBlVisualization` (`view`) draws it.
- `SpBlSpaceInMorphPresenter` (`mapPresenter`): embeds the Bloc space of the map in Spec. I give the space a Toplo theme, light or dark like the Pharo theme (`#toploTheme`).
- `MiAbstractBrowser`: I am a Midas browser (bus, follow / receive entities). I am not in the world menu: the architectural map entry opens me instead of `MiArchitecturalMapBrowser` when the application says so (`MiArchitecturalMapBrowser class>>#frontEndClass`):
	`MiApplication current architecturalMapBrowserClass: MiArchitecturalMapBrowserBl`

## Assumptions & Invariants
- The tree is built in the calling process (`#runVisualization`), but drawn in the Bloc UI process of the space (`#showTree:`, through `#enqueueTask:`): Bloc elements must only be touched there.
- Each run replaces the whole drawing: a new `MiArchiBlVisualization` is made and replaces the children of the space root.
- `view` is nil until the first entities are shown.
- Display only for now: no selection (`#selectRelatedTo:` does nothing, `#miSelectedItem` answers all the entities).

## Main API
- `MiArchitecturalMapBrowserBl open`, or through the architectural map entry once chosen in the application.
- `#followEntity:`: show the map of anEntity.
- `#runVisualization`: rebuild and redraw the map from the model.
- `#availableMapLayouts`, `#defaultMapLayout`: the layouts, for the model.
- `#space`, `#view`: the Bloc space and the visualization shown.

"
Class {
	#name : 'MiArchitecturalMapBrowserBl',
	#superclass : 'MiAbstractBrowser',
	#instVars : [
		'mapPresenter',
		'view'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc-browser',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'browser'
}

{ #category : 'world menu' }
MiArchitecturalMapBrowserBl class >> buildItemInMenu: aMenu action: aBlock [
	"Not listed with the other browsers: the entry of the architectural map opens me when the application says so (MiArchitecturalMapBrowser class>>frontEndClass)"

	^ nil
]

{ #category : 'specs' }
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

	^ MiArchiBlLayout availableLayouts
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

	^ MiArchiBlFlowLayout
]

{ #category : 'actions' }
MiArchitecturalMapBrowserBl >> followEntity: anEntity [

	super followEntity: anEntity.
	specModel entities: anEntity asMooseGroup.
	self runVisualization
]

{ #category : 'initialization' }
MiArchitecturalMapBrowserBl >> initializePresenters [

	super initializePresenters.
	mapPresenter := self instantiate: SpBlSpaceInMorphPresenter.
	self space toTheme: self toploTheme.
	self layout: (SpBoxLayout newTopToBottom
			 add: mapPresenter;
			 yourself)
]

{ #category : 'actions' }
MiArchitecturalMapBrowserBl >> miSelectedItem [

	^ specModel entities ifNil: [ #(  ) ]
]

{ #category : 'actions' }
MiArchitecturalMapBrowserBl >> runVisualization [
	"Build the map from the model and show it, in the UI process of Bloc"

	| tree |
	tree := MiArchiBlTreeBuilder new
		        mapModel: specModel;
		        build;
		        yourself.
	self space enqueueTask: (BlTaskAction new action: [ self showTree: tree ])
]

{ #category : 'actions' }
MiArchitecturalMapBrowserBl >> selectRelatedTo: anEntity [
	"Not yet: the map only displays"

	
]

{ #category : 'building' }
MiArchitecturalMapBrowserBl >> showTree: aTree [

	| root |
	root := self space root.
	view := MiArchiBlVisualization new
		        tree: aTree;
		        layoutClass: specModel layout;
		        tokenSource: root;
		        yourself.
	root removeChildren.
	root addChild: view element
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
