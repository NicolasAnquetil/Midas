"
I test `MiButterflyBlTree`, the butterfly of the Bloc butterfly map: the central node, the levels on each side, the nodes inside a box, the dependencies, and the changes the menus make (add or remove a level, the dependencies of a node, a node).

## Collaborators & Context
- `MiButterflyBlAbstractTest`: the fixture (Center, two clients, a client of both clients, a provider) and `#tree`.

## Assumptions & Invariants
- Each test builds its own tree: nothing is shared between tests.

## Main API
- The tests only.

"
Class {
	#name : 'MiButterflyBlTreeTest',
	#superclass : 'MiButterflyBlAbstractTest',
	#category : 'MooseIDE-ButterflyMap-Bloc-Tests',
	#package : 'MooseIDE-ButterflyMap-Bloc-Tests'
}

{ #category : 'tests' }
MiButterflyBlTreeTest >> testAddDependenciesOfANode [
	"Only Client1 gets its clients; it can not get them again"

	| tree node |
	tree := self tree.
	node := self nodeOf: client1 in: tree.
	self assert: (tree canAddDependenciesOf: node).
	tree addDependenciesOf: node.
	self assert: (self entitiesOf: node expansions) equals: { clientOfClients }.
	self assert: (self entitiesOf: tree leftLevels second) equals: { clientOfClients }.
	self deny: (tree canAddDependenciesOf: node)
]

{ #category : 'tests' }
MiButterflyBlTreeTest >> testAddLevel [
	"The clients of the clients: ClientOfClients, once for each client. Provider has no provider: the right side does not grow"

	| tree |
	tree := self tree.
	tree addLevel.
	self assert: tree leftLevels size equals: 2.
	self assert: (self entitiesOf: tree leftLevels second) equals: { clientOfClients. clientOfClients }.
	self assert: tree rightLevels size equals: 1.
	self assert: tree depth equals: 2
]

{ #category : 'tests' }
MiButterflyBlTreeTest >> testCentralNode [

	| tree |
	tree := self tree.
	self assert: tree central entity identicalTo: center.
	self assert: tree central isCentral.
	self assert: tree central level equals: 0
]

{ #category : 'tests' }
MiButterflyBlTreeTest >> testCentralNodeHasItsDependencies [

	self deny: (self tree in: [ :tree | tree canAddDependenciesOf: tree central ])
]

{ #category : 'tests' }
MiButterflyBlTreeTest >> testFirstLevel [
	"Built with one level on each side: the clients of Center on the left, sorted by name, its provider on the right"

	| tree |
	tree := self tree.
	self assert: tree leftLevels size equals: 1.
	self assert: (self entitiesOf: tree leftLevels first) equals: { client1. client2 }.
	self assert: (self entitiesOf: tree rightLevels first) equals: { provider }.
	self assert: (tree leftLevels first allSatisfy: [ :each | each isLeft and: [ each level = 1 and: [ each anchor == tree central ] ] ])
]

{ #category : 'tests' }
MiButterflyBlTreeTest >> testNoCentralEntity [

	| tree mapModel |
	mapModel := self mapModel.
	mapModel instVarNamed: #currentEntity put: nil.
	tree := MiButterflyBlTree new
		        mapModel: mapModel;
		        build;
		        yourself.
	self assert: tree roots isEmpty.
	self assert: tree visibleDependencies isEmpty.
	self assert: tree depth equals: 0
]

{ #category : 'tests' }
MiButterflyBlTreeTest >> testNodesInsideABox [
	"The methods of Center are nodes inside its box: sorted, collapsed, not in the butterfly"

	| central |
	central := self tree central.
	self assert: (self entitiesOf: central children) equals: (center methods asArray sort: [ :a :b | a name < b name ]).
	self deny: central isExpanded.
	self deny: (central children anySatisfy: [ :each | each isInButterfly ])
]

{ #category : 'tests' }
MiButterflyBlTreeTest >> testRemoveCentralNodeDoesNothing [

	| tree |
	tree := self tree.
	tree remove: tree central.
	self assert: tree central entity identicalTo: center.
	self assert: tree roots size equals: 4
]

{ #category : 'tests' }
MiButterflyBlTreeTest >> testRemoveDependenciesOfANode [

	| tree |
	tree := self tree.
	tree addLevel.
	tree removeDependenciesOf: (self nodeOf: client1 in: tree).
	self assert: (self entitiesOf: tree leftLevels second) equals: { clientOfClients }.
	self assert: (self nodeOf: client1 in: tree) expansions isEmpty
]

{ #category : 'tests' }
MiButterflyBlTreeTest >> testRemoveLevel [

	| tree |
	tree := self tree.
	tree addLevel.
	tree removeLevel.
	self assert: tree depth equals: 1.
	self assert: (self entitiesOf: tree leftLevels first) equals: { client1. client2 }
]

{ #category : 'tests' }
MiButterflyBlTreeTest >> testRemoveLevelKeepsTheFirstLevel [

	| tree |
	tree := self tree.
	tree removeLevel.
	self assert: (self entitiesOf: tree leftLevels first) equals: { client1. client2 }.
	self assert: (self entitiesOf: tree rightLevels first) equals: { provider }
]

{ #category : 'tests' }
MiButterflyBlTreeTest >> testRemoveNode [
	"Client1 goes, with the node added after it"

	| tree |
	tree := self tree.
	tree addLevel.
	tree remove: (self nodeOf: client1 in: tree).
	self assert: (self entitiesOf: tree leftLevels first) equals: { client2 }.
	self assert: (self entitiesOf: tree leftLevels second) equals: { clientOfClients }
]

{ #category : 'tests' }
MiButterflyBlTreeTest >> testRoots [

	| tree |
	tree := self tree.
	self assert: (self entitiesOf: tree roots) equals: { center. client1. client2. provider }
]

{ #category : 'tests' }
MiButterflyBlTreeTest >> testVisibleDependencies [
	"From left to right: each client depends on Center, Center on its provider"

	| pairs |
	pairs := self tree visibleDependencies collect: [ :each | each source entity -> each target entity ].
	self assertCollection: pairs hasSameElements: { client1 -> center. client2 -> center. center -> provider }
]
