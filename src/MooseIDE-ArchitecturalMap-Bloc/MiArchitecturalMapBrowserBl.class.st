"
I am a browser that displays an architectural map with Bloc and Toplo, as MiArchitecturalMapBrowser does with Roassal, on the same model (MiArchitecturalMapModel).
Accepted entities: a MooseObject.

The model calls me back (#runVisualization after a change of the settings) and asks me the layouts it can offer (#availableMapLayouts, #defaultMapLayout: MiArchitecturalMapLayoutBl subclasses).

The map is shown in a Bloc space embedded in Spec (SpBlSpaceInMorphPresenter), drawn by a MiArchitecturalMapViewBl from a MiArchitecturalMapTreeBl. Drag to move the map, mouse wheel to zoom.

I am opened instead of MiArchitecturalMapBrowser when the application says so:
	MiApplication current architecturalMapBrowserClass: MiArchitecturalMapBrowserBl.
"
Class {
	#name : 'MiArchitecturalMapBrowserBl',
	#superclass : 'MiAbstractBrowser',
	#instVars : [
		'mapPresenter',
		'view'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc',
	#package : 'MooseIDE-ArchitecturalMap-Bloc'
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

	^ MiArchitecturalMapLayoutBl availableLayouts
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

	^ MiArchitecturalMapFlowLayoutBl
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
	tree := MiArchitecturalMapTreeBl new
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
	view := MiArchitecturalMapViewBl new
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
	"The MiArchitecturalMapViewBl shown, nil before the first entities"

	^ view
]
