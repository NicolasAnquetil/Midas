"
I build, from a MiArchitecturalMapModel, the tree of MiArchitecturalMapNodeBl shown by MiArchitecturalMapBrowserBl, as MiArchitecturalMapBuilder builds its HNodes for Roassal:
- the roots: a node per tag of the model, then (unless the model hides the received entities) a node per root entity of the model, sorted by name;
- the children of an entity: the model's #childrenFor:, sorted by name; the children of a tag: its tagged entities not already in the map, labelled with their parent's name;
- the dependencies: for each entity of the map, the model's #getDependenciesFor: whose source is in the map too.

#visibleDependencies gives them lifted to the nodes shown (a collapsed node stands for its descendants).
"
Class {
	#name : 'MiArchitecturalMapTreeBl',
	#superclass : 'Object',
	#instVars : [
		'mapModel',
		'roots',
		'nodesByMooseID',
		'dependencies'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc',
	#package : 'MooseIDE-ArchitecturalMap-Bloc'
}

{ #category : 'building' }
MiArchitecturalMapTreeBl >> build [
	"Build the nodes from the map model, then the dependencies between them (as MiArchitecturalMapBuilder>>build)"

	nodesByMooseID := Dictionary new.
	dependencies := OrderedCollection new.
	roots := OrderedCollection new.
	mapModel rootNodes ifNil: [ ^ self ].
	roots addAll: (mapModel tags collect: [ :each | self nodeForTag: each ]).
	mapModel hideReceivedEntities ifFalse: [ roots addAll: self rootEntityNodes ].
	self computeDependencies
]

{ #category : 'building' }
MiArchitecturalMapTreeBl >> computeDependencies [
	"For each entity of the map, its dependencies (MiArchitecturalMapModel>>getDependenciesFor:) whose source is in the map: source node -> target node, with the association"

	nodesByMooseID valuesDo: [ :targetNode |
			(mapModel getDependenciesFor: targetNode entity) do: [ :association |
					association source ifNotNil: [ :source |
							nodesByMooseID at: source mooseID ifPresent: [ :sourceNode |
									dependencies add: (MiArchitecturalMapDependencyBl new
											 source: sourceNode;
											 target: targetNode;
											 association: association;
											 yourself) ] ] ] ]
]

{ #category : 'accessing' }
MiArchitecturalMapTreeBl >> dependencies [
	"The dependencies between the nodes of the map, at the level of their entities (see #visibleDependencies)"

	^ dependencies
]

{ #category : 'accessing' }
MiArchitecturalMapTreeBl >> mapModel [

	^ mapModel
]

{ #category : 'accessing' }
MiArchitecturalMapTreeBl >> mapModel: aMapModel [

	mapModel := aMapModel
]

{ #category : 'building' }
MiArchitecturalMapTreeBl >> nodeForEntity: anEntity [
	"A new node for anEntity and its children. If anEntity already has a node: that node if it has no parent yet, nil otherwise (an entity is shown once)"

	| node |
	nodesByMooseID at: anEntity mooseID ifPresent: [ :existing | ^ existing parent ifNil: [ existing ] ifNotNil: [ nil ] ].
	node := MiArchitecturalMapNodeBl new
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
MiArchitecturalMapTreeBl >> nodeForTag: aTag [
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
	^ MiArchitecturalMapNodeBl new
		  entity: aTag;
		  name: (String streamContents: [ :stream | aTag displayStringOn: stream ]);
		  color: aTag color;
		  children: (self sortedByName: children);
		  yourself
]

{ #category : 'building' }
MiArchitecturalMapTreeBl >> rootEntityNodes [

	^ self sortedByName: (mapModel rootNodes
			   collect: [ :each |
					   each isTag
						   ifTrue: [ self nodeForTag: each ]
						   ifFalse: [ self nodeForEntity: each ] ]
			   thenReject: [ :node | node isNil ])
]

{ #category : 'accessing' }
MiArchitecturalMapTreeBl >> roots [

	^ roots
]

{ #category : 'building' }
MiArchitecturalMapTreeBl >> sortedByName: aCollection [

	^ aCollection asOrderedCollection sort: [ :a :b | a name < b name ]
]

{ #category : 'building' }
MiArchitecturalMapTreeBl >> visibleDependencies [
	"The dependencies lifted to the nodes shown (a collapsed node stands for its descendants): one per pair of visible nodes, source -> target, with all the associations between them. None from a node to itself"

	| byPair |
	byPair := OrderedDictionary new.
	dependencies do: [ :each |
			| from to |
			from := each source visibleNode.
			to := each target visibleNode.
			from == to ifFalse: [ (byPair at: from -> to ifAbsentPut: [ OrderedCollection new ]) add: each association ] ].
	^ byPair associations collect: [ :pair |
			  MiArchitecturalMapDependencyBl new
				  source: pair key key;
				  target: pair key value;
				  associations: pair value;
				  yourself ]
]
