"
I am the butterfly drawn by the Bloc butterfly map: a central node, its clients on the left and its providers on the right, level by level. I build it from a `MiButterflyMapModel` and change it as the menus of the map ask (add or remove a level, add or remove the dependencies of a node, remove a node).

## Collaborators & Context
- `MiButterflyMapModel` (`mapModel`): gives the central entity (`#currentEntity`), the clients (`#leftEntitiesFor:`), the providers (`#rightEntitiesFor:`) and the children (`#childrenFor:`) of an entity, by the queries of its settings.
- `MiButterflyBlNode`: my nodes. A node of the butterfly knows its `side`, its `anchor` and its `expansions`; the children of an entity are nodes inside its box (no side).
- `MiBlDependency`: `#visibleDependencies` gives one per node of the butterfly, between it and its anchor.
- `MiButterflyMapBrowserBl>>#buildTree` creates and builds me; `MiButterflyBlVisualization` draws my levels in columns and changes me from its menus.

## Assumptions & Invariants
- `mapModel` must be set before `#build`. `#build` starts again from the model: the central node and one level on each side.
- Levels: level 1 is the expansions of the central node on a side, level n+1 the expansions of the nodes of level n. `#levelsOn:` computes them each time from the nodes, so they always follow the changes.
- A node is expanded at most once per side (`#expand:on:` does nothing if it already has expansions there): to ask the model again, remove its dependencies first.
- The expansions of a node are sorted by name; the children inside a box too. An entity can have several nodes, but not inside its own box (no cycle in the children).
- `#removeLevel` keeps the first level; `#remove:` keeps the central node.
- Not thread-safe: built in the calling process, then changed only in the UI process of the Bloc space (by the menus).

## Main API
- `MiButterflyBlTree new mapModel: aButterflyMapModel; build; yourself`
- `#central`, `#roots` (all the nodes of the butterfly), `#leftLevels`, `#rightLevels`, `#depth`, `#visibleDependencies`.
- Changes: `#addLevel`, `#removeLevel`, `#addDependenciesOf:` (with `#canAddDependenciesOf:`), `#removeDependenciesOf:`, `#remove:`.

"
Class {
	#name : 'MiButterflyBlTree',
	#superclass : 'Object',
	#instVars : [
		'mapModel',
		'central'
	],
	#category : 'MooseIDE-Bloc-ButterflyMap-data',
	#package : 'MooseIDE-Bloc-ButterflyMap',
	#tag : 'data'
}

{ #category : 'changing' }
MiButterflyBlTree >> addDependenciesOf: aNode [
	"Add the next level for aNode only: its clients (left) or providers (right), both for the central node"

	(self sidesOf: aNode) do: [ :each | self expand: aNode on: each ]
]

{ #category : 'changing' }
MiButterflyBlTree >> addLevel [
	"Add a level on each side: the clients (left) or providers (right) of each node of the outermost level, of the central node if the side has none yet. A side whose outermost nodes have none does not grow"

	central ifNil: [ ^ self ].
	#( #left #right ) do: [ :aSide |
			((self levelsOn: aSide) ifEmpty: [ { { central } } ]) last do: [ :each | self expand: each on: aSide ] ]
]

{ #category : 'building' }
MiButterflyBlTree >> build [
	"The central node, with its clients and providers (one level each side). Builds everything again, so it can be sent again"

	central := nil.
	mapModel currentEntity ifNil: [ ^ self ].
	central := self nodeFor: mapModel currentEntity side: #center.
	self addLevel
]

{ #category : 'testing' }
MiButterflyBlTree >> canAddDependenciesOf: aNode [
	"Whether #addDependenciesOf: would ask the model: aNode has no expansion on one of its sides"

	^ (self sidesOf: aNode) anySatisfy: [ :each | (self expansionsOf: aNode on: each) isEmpty ]
]

{ #category : 'accessing' }
MiButterflyBlTree >> central [
	"The node of the central entity, nil if the model has none"

	^ central
]

{ #category : 'querying' }
MiButterflyBlTree >> depth [
	"The number of levels of the longest side"

	^ self leftLevels size max: self rightLevels size
]

{ #category : 'building' }
MiButterflyBlTree >> entitiesOn: aSide of: aNode [
	"The clients of the entity of aNode for the left side, its providers for the right side, as the queries of the model answer them"

	^ aSide = #left
		  ifTrue: [ mapModel leftEntitiesFor: aNode entity ]
		  ifFalse: [ mapModel rightEntitiesFor: aNode entity ]
]

{ #category : 'changing' }
MiButterflyBlTree >> expand: aNode on: aSide [
	"Add the nodes of the next level for aNode on aSide (its clients or its providers), sorted by name. Nothing if it already has some there"

	(self expansionsOf: aNode on: aSide) ifNotEmpty: [ ^ self ].
	(self sortedByName: ((self entitiesOn: aSide of: aNode) collect: [ :each | self nodeFor: each side: aSide ])) do: [ :each |
		aNode addExpansion: each ]
]

{ #category : 'querying' }
MiButterflyBlTree >> expansionsOf: aNode on: aSide [

	^ aNode expansions select: [ :each | each side = aSide ]
]

{ #category : 'building' }
MiButterflyBlTree >> innerNodeFor: anEntity visited: someEntities [
	"A node for anEntity and its children, recursively. An entity already met above is not built again (a cycle in the children query would never end)"

	| children |
	someEntities add: anEntity.
	children := (mapModel childrenFor: anEntity) reject: [ :each | someEntities includes: each ].
	^ MiButterflyBlNode new
		  entity: anEntity;
		  name: (String streamContents: [ :stream | anEntity displayStringOn: stream ]);
		  children: (self sortedByName: (children collect: [ :each | self innerNodeFor: each visited: someEntities copy ]));
		  yourself
]

{ #category : 'querying' }
MiButterflyBlTree >> leftLevels [

	^ self levelsOn: #left
]

{ #category : 'querying' }
MiButterflyBlTree >> levelsOn: aSide [
	"The levels of aSide, from the central node outwards: each is the collection of its nodes, the nodes of the same anchor together"

	| levels level |
	levels := OrderedCollection new.
	central ifNil: [ ^ levels ].
	level := self expansionsOf: central on: aSide.
	[ level isEmpty ] whileFalse: [
			levels add: level.
			level := level flatCollect: [ :each | each expansions ] ].
	^ levels
]

{ #category : 'accessing' }
MiButterflyBlTree >> mapModel [

	^ mapModel
]

{ #category : 'accessing' }
MiButterflyBlTree >> mapModel: aButterflyMapModel [

	mapModel := aButterflyMapModel
]

{ #category : 'building' }
MiButterflyBlTree >> nodeFor: anEntity side: aSide [
	"A new node for anEntity, with the nodes inside its box (its children, by the children query of the model), collapsed"

	^ (self innerNodeFor: anEntity visited: IdentitySet new)
		  side: aSide;
		  yourself
]

{ #category : 'changing' }
MiButterflyBlTree >> remove: aNode [
	"Remove aNode from the butterfly, with the nodes added after it. The central node stays"

	aNode isCentral ifTrue: [ ^ self ].
	aNode anchor removeExpansion: aNode
]

{ #category : 'changing' }
MiButterflyBlTree >> removeDependenciesOf: aNode [
	"Remove the nodes added for aNode, and so all the levels after them"

	aNode expansions copy do: [ :each | aNode removeExpansion: each ]
]

{ #category : 'changing' }
MiButterflyBlTree >> removeLevel [
	"Remove the outermost level, on the sides that have that many levels. The first level stays: the central node keeps its clients and providers"

	| depth |
	depth := self depth.
	depth <= 1 ifTrue: [ ^ self ].
	#( #left #right ) do: [ :aSide |
			| levels |
			levels := self levelsOn: aSide.
			levels size = depth ifTrue: [ levels last do: [ :each | self remove: each ] ] ]
]

{ #category : 'querying' }
MiButterflyBlTree >> rightLevels [

	^ self levelsOn: #right
]

{ #category : 'querying' }
MiButterflyBlTree >> roots [
	"The nodes of the butterfly, each drawn as a top box: the central node, then the left levels, then the right levels"

	central ifNil: [ ^ #(  ) ].
	^ (OrderedCollection with: central)
		  addAll: (self leftLevels flatCollect: [ :each | each ]);
		  addAll: (self rightLevels flatCollect: [ :each | each ]);
		  yourself
]

{ #category : 'querying' }
MiButterflyBlTree >> sidesOf: aNode [
	"The sides where the expansions of aNode go: both for the central node, its own side otherwise"

	^ aNode isCentral
		  ifTrue: [ #( #left #right ) ]
		  ifFalse: [ { aNode side } ]
]

{ #category : 'building' }
MiButterflyBlTree >> sortedByName: someNodes [

	^ someNodes asOrderedCollection sort: [ :a :b | a name < b name ]
]

{ #category : 'querying' }
MiButterflyBlTree >> visibleDependencies [
	"One dependency per node of the butterfly but the central one, between it and its anchor, from left to right: a client depends on its anchor, an anchor on its provider"

	^ self roots
		  reject: [ :each | each isCentral ]
		  thenCollect: [ :each |
			  each isLeft
				  ifTrue: [ MiBlDependency new source: each; target: each anchor; yourself ]
				  ifFalse: [ MiBlDependency new source: each anchor; target: each; yourself ] ]
]
