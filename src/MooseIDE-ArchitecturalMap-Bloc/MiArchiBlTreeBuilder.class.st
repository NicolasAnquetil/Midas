"
I build, from a `MiArchitecturalMapModel`, the tree of `MiBlNode` and the `MiBlDependency` between them that `MiArchitecturalMapBrowserBl` shows.

## Collaborators & Context
- `MiArchitecturalMapModel` (`mapModel`): gives the root entities (`#rootNodes`), the tags (`#tags`), the children of an entity (`#childrenFor:`), its dependencies (`#getDependenciesFor:`) and whether received entities are hidden (`#hideReceivedEntities`).
- `MiArchiBlEntityNode` (for a Moose entity) and `MiArchiBlTagNode` (for a `FamixTag`): the nodes of the tree, subclasses of `MiBlNode`.
- `MiBlDependency`: a dependency from a source node to a target node, with its associations.
- `MiArchitecturalMapBrowserBl>>#runVisualization` creates and builds me; the browser then draws my `roots` and `#visibleDependencies` with Bloc.

## Assumptions & Invariants
- `mapModel` must be set before `#build`; `#build` resets everything, so it can be sent again to rebuild.
- `roots`: a node per tag of the model first, then (unless received entities are hidden) a node per root entity. The children of a node are sorted by name.
- An entity is shown once: `nodesByMooseID` maps each entity's mooseID to its single node. An entity met again (cycle, or in two places) is not built twice. A tag keeps only the tagged entities that are not already elsewhere in the map, labelled `owner.name` to tell them apart.
- `dependencies` only links entities that are both in the map (sources outside the map are dropped).
- Not thread-safe: build me in one process, then only read me (the browser hands me over to the Bloc UI process).

## Main API
- `MiArchiBlTreeBuilder new mapModel: aMapModel; build; yourself`
- `#roots`: the root nodes of the tree.
- `#dependencies`: the dependencies between entity nodes.
- `#visibleDependencies`: the dependencies lifted to the nodes currently shown (a collapsed node stands for its descendants), one per pair of visible nodes with all their associations, none from a node to itself. Computed on each call, so it follows expand/collapse.

"
Class {
	#name : 'MiArchiBlTreeBuilder',
	#superclass : 'Object',
	#instVars : [
		'mapModel',
		'roots',
		'nodesByMooseID',
		'dependencies'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc-browser',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'browser'
}

{ #category : 'building' }
MiArchiBlTreeBuilder >> build [
	"Build the nodes from the map model, then the dependencies between them"

	nodesByMooseID := Dictionary new.
	dependencies := OrderedCollection new.
	roots := OrderedCollection new.

	mapModel rootNodes ifNil: [ ^ self ].
	roots addAll: (mapModel tags collect: [ :each | self nodeForTag: each ]).
	mapModel hideReceivedEntities ifFalse: [ roots addAll: self rootEntityNodes ].

	self computeDependencies
]

{ #category : 'building' }
MiArchiBlTreeBuilder >> computeDependencies [
	"For each entity of the map, its dependencies (MiArchitecturalMapModel>>getDependenciesFor:) whose source is in the map: source node -> target node, with the association"

	nodesByMooseID valuesDo: [ :targetNode |
			(mapModel getDependenciesFor: targetNode entity) do: [ :association |
					association source ifNotNil: [ :source |
							nodesByMooseID at: source mooseID ifPresent: [ :sourceNode |
									dependencies add: (MiBlDependency new
											 source: sourceNode;
											 target: targetNode;
											 association: association;
											 yourself) ] ] ] ]
]

{ #category : 'accessing' }
MiArchiBlTreeBuilder >> dependencies [
	"The dependencies between the nodes of the map, at the level of their entities (see #visibleDependencies)"

	^ dependencies
]

{ #category : 'accessing' }
MiArchiBlTreeBuilder >> mapModel [

	^ mapModel
]

{ #category : 'accessing' }
MiArchiBlTreeBuilder >> mapModel: aMapModel [

	mapModel := aMapModel
]

{ #category : 'building' }
MiArchiBlTreeBuilder >> nodeForEntity: anEntity [
	"A new node for anEntity and its children. If anEntity already has a node: that node if it has no parent yet, nil otherwise (an entity is shown once)"

	| node |
	nodesByMooseID at: anEntity mooseID ifPresent: [ :existing | ^ existing parent ifNil: [ existing ] ifNotNil: [ nil ] ].
	node := MiArchiBlEntityNode new
		        entity: anEntity;
		        name: anEntity fullDisplayString;
		        yourself.
	"Registered before its children are built, so that an entity met again below itself is not built twice"
	nodesByMooseID at: anEntity mooseID put: node.
	node children: (self sortedByName: ((mapModel childrenFor: anEntity)
				  collect: [ :child | self nodeForEntity: child ]
				  thenReject: [ :child | child isNil or: [ child == node ] ])).
	^ node
]

{ #category : 'building' }
MiArchiBlTreeBuilder >> nodeForTag: aTag [
	"A node for aTag, its children are its tagged entities not already in the map, labelled with the name of their parent to tell them apart"

	| children |
	children := (aTag taggedEntities collect: [ :each | self nodeForEntity: each ]) reject: [ :child |
		            child isNil or: [ child parent isNotNil ] ].
	children do: [ :child |
			child name: (String streamContents: [ :stream |
						 child entity belongsTo ifNotNil: [ :owner |
								 stream
									 nextPutAll: owner name;
									 nextPut: $. ].
						 stream nextPutAll: child entity name ]) ].
	^ MiArchiBlTagNode new
		  entity: aTag;
		  name: (String streamContents: [ :stream | aTag displayStringOn: stream ]);
		  color: aTag color;
		  children: (self sortedByName: children);
		  yourself
]

{ #category : 'building' }
MiArchiBlTreeBuilder >> rootEntityNodes [

	^ self sortedByName: (mapModel rootNodes
			   collect: [ :each |
					   each isTag
						   ifTrue: [ self nodeForTag: each ]
						   ifFalse: [ self nodeForEntity: each ] ]
			   thenReject: [ :node | node isNil ])
]

{ #category : 'accessing' }
MiArchiBlTreeBuilder >> roots [

	^ roots
]

{ #category : 'building' }
MiArchiBlTreeBuilder >> sortedByName: aCollection [

	^ aCollection asOrderedCollection sort: [ :a :b | a name < b name ]
]

{ #category : 'building' }
MiArchiBlTreeBuilder >> visibleDependencies [
	"The dependencies lifted to the nodes shown (a collapsed node stands for its descendants): one per pair of visible nodes, source -> target, with all the associations between them. None from a node to itself"

	| byPair |
	byPair := OrderedDictionary new.
	dependencies do: [ :each |
			| from to |
			from := each source visibleNode.
			to := each target visibleNode.
			from == to ifFalse: [ (byPair at: from -> to ifAbsentPut: [ OrderedCollection new ]) add: each association ] ].
	^ byPair associations collect: [ :pair |
			  MiBlDependency new
				  source: pair key key;
				  target: pair key value;
				  associations: pair value;
				  yourself ]
]
