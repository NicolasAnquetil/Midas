"
I stand for the browser of a `MiArchiBlVisualization` in its tests: I record what the visualization asks its browser, instead of doing it (no inspector opened, nothing propagated on a bus).

## Collaborators & Context
- `MiArchiBlVisualization`: asks its browser to inspect or propagate the entity of a node, from the menu of its box.
- `MiArchitecturalMapBrowserBl`: the real browser, which I replace. I answer the same messages.
- `MiArchiBlVisualizationTest`: gives me to the visualization (`#browser:`) and checks my `#requests`.

## Assumptions & Invariants
- `requests` keeps the requests in the order received, as associations: action symbol -> entity (`#inspect -> anEntity`, `#propagate -> anEntity`).

## Main API
- `#inspectEntity:`, `#propagateEntity:`: the messages of the browser.
- `#requests`.

"
Class {
	#name : 'MiArchiBlBrowserFixture',
	#superclass : 'Object',
	#instVars : [
		'requests'
	],
	#category : 'MooseIDE-Bloc-ArchitecturalMap-Tests',
	#package : 'MooseIDE-Bloc-ArchitecturalMap',
	#tag : 'Tests'
}

{ #category : 'initialization' }
MiArchiBlBrowserFixture >> initialize [

	super initialize.
	requests := OrderedCollection new
]

{ #category : 'actions' }
MiArchiBlBrowserFixture >> inspectEntity: anEntity [

	requests add: #inspect -> anEntity
]

{ #category : 'actions' }
MiArchiBlBrowserFixture >> propagateEntity: anEntity [

	requests add: #propagate -> anEntity
]

{ #category : 'actions' }
MiArchiBlBrowserFixture >> requests [

	^ requests
]

{ #category : 'actions' }
MiArchiBlBrowserFixture >> selectEntities: someEntities [

	requests add: #select -> someEntities asArray
]
