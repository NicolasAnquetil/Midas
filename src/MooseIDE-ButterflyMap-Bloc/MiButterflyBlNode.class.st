"
I am a node of the butterfly map drawn with Bloc (`MiButterflyBlVisualization`). On top of what any `MiBlNode` has (entity, name, the nodes inside my box), I know where I am in the butterfly: my `side`, the `anchor` I was added for, and my `expansions`, the nodes added for me at the next level.

## Collaborators & Context
- `MiButterflyBlTree` creates me and changes my expansions (add or remove a level, add or remove the dependencies of a node, remove a node).
- `MiButterflyBlVisualization` draws a box for each node of the butterfly, in the column of its side and level.

## Assumptions & Invariants
- `side` is `#center` for the central node, `#left` for a client, `#right` for a provider, nil for a node inside a box (`#isInButterfly` is false then, and so are anchor and expansions: empty).
- `anchor` and `expansions` agree: `#addExpansion:` sets me as the anchor of the node added. A left node only has left expansions and a right node right ones; the central node has both.
- A left node is a client of its anchor, a right node a provider of its anchor: the dependency goes from left to right.
- The same entity can have several nodes in a butterfly (a client of a client that is also a provider...): a node is not an entity.

## Main API
- `MiButterflyBlNode new entity: anEntity; name: aString; side: #left; yourself` (made by `MiButterflyBlTree`)
- `#side`, `#isCentral`, `#isLeft`, `#isRight`, `#isInButterfly`, `#level`
- `#anchor`, `#expansions`, `#addExpansion:`, `#removeExpansion:`

"
Class {
	#name : 'MiButterflyBlNode',
	#superclass : 'MiBlNode',
	#instVars : [
		'side',
		'anchor',
		'expansions'
	],
	#category : 'MooseIDE-ButterflyMap-Bloc-data',
	#package : 'MooseIDE-ButterflyMap-Bloc',
	#tag : 'data'
}

{ #category : 'adding' }
MiButterflyBlNode >> addExpansion: aNode [

	expansions add: aNode.
	aNode anchor: self
]

{ #category : 'accessing' }
MiButterflyBlNode >> anchor [
	"The node of the previous level that I was added for: I am one of its clients (on the left) or providers (on the right). nil for the central node and the nodes inside a box"

	^ anchor
]

{ #category : 'accessing' }
MiButterflyBlNode >> anchor: aNode [

	anchor := aNode
]

{ #category : 'accessing' }
MiButterflyBlNode >> expansions [
	"The nodes of the next level added for me: my clients if I am on the left, my providers if I am on the right, both for the central node"

	^ expansions
]

{ #category : 'initialization' }
MiButterflyBlNode >> initialize [

	super initialize.
	expansions := OrderedCollection new
]

{ #category : 'testing' }
MiButterflyBlNode >> isCentral [

	^ side = #center
]

{ #category : 'testing' }
MiButterflyBlNode >> isInButterfly [
	"Whether I am one of the nodes of the butterfly (central, client or provider), not a node inside a box"

	^ side isNotNil
]

{ #category : 'testing' }
MiButterflyBlNode >> isLeft [

	^ side = #left
]

{ #category : 'testing' }
MiButterflyBlNode >> isRight [

	^ side = #right
]

{ #category : 'accessing' }
MiButterflyBlNode >> level [
	"0 for the central node, 1 for its clients and providers, and so on"

	^ anchor ifNil: [ 0 ] ifNotNil: [ anchor level + 1 ]
]

{ #category : 'removing' }
MiButterflyBlNode >> removeExpansion: aNode [

	expansions remove: aNode ifAbsent: [  ]
]

{ #category : 'accessing' }
MiButterflyBlNode >> side [
	"#left (a client, on the left of the map), #right (a provider), #center (the central node), or nil for a node inside a box"

	^ side
]

{ #category : 'accessing' }
MiButterflyBlNode >> side: aSymbol [

	side := aSymbol
]
