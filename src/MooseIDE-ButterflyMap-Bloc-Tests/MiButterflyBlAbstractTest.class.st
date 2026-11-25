"
I am the common fixture of the tests of the Bloc butterfly map: a Famix model where Client1 and Client2 inherit from Center, Center inherits from Provider, and ClientOfClients inherits from both clients. Center has two methods, bar and foo.

## Collaborators & Context
- `MiAbstractApplicationTest`: installs a `MiTestApplication` for the duration of each test.
- `MiButterflyMapModel` (`#mapModel`), with a `Mock` browser; `MiButterflyBlTree` (`#tree`).
- Subclasses: `MiButterflyBlTreeTest` (the butterfly) and `MiButterflyBlVisualizationTest` (its drawing).

## Assumptions & Invariants
- I am abstract (`#isAbstract`): I hold no tests.
- Each test gets a fresh model from `#setUp`. `#tree` builds a new butterfly on each send: Center, with Client1 and Client2 on the left and Provider on the right.
- The providers are given by `allProviders` (`#mapModel`): the default providers query of the application answers the clients.
- ClientOfClients is a client of both clients: after a level is added, it has two nodes.

## Main API
- `#mapModel`: a butterfly model centered on Center. `#tree`: its butterfly.
- `#entitiesOf:` nodes: their entities. `#nodeOf:in:` an entity and a tree: its first node.

"
Class {
	#name : 'MiButterflyBlAbstractTest',
	#superclass : 'MiAbstractApplicationTest',
	#instVars : [
		'model',
		'center',
		'client1',
		'client2',
		'clientOfClients',
		'provider'
	],
	#category : 'MooseIDE-ButterflyMap-Bloc-Tests',
	#package : 'MooseIDE-ButterflyMap-Bloc-Tests'
}

{ #category : 'testing' }
MiButterflyBlAbstractTest class >> isAbstract [

	^ self == MiButterflyBlAbstractTest
]

{ #category : 'running' }
MiButterflyBlAbstractTest >> classNamed: aString in: aPackage [

	^ FamixStClass new
		  name: aString;
		  parentPackage: aPackage;
		  mooseModel: model;
		  yourself
]

{ #category : 'running' }
MiButterflyBlAbstractTest >> entitiesOf: someNodes [

	^ someNodes collect: [ :each | each entity ] as: Array
]

{ #category : 'running' }
MiButterflyBlAbstractTest >> inherit: aSubclass from: aSuperclass [

	FamixStInheritance new
		subclass: aSubclass;
		superclass: aSuperclass;
		mooseModel: model
]

{ #category : 'running' }
MiButterflyBlAbstractTest >> mapModel [
	"A butterfly model centered on Center, with a stub browser (setting the central entity asks the browser to draw the map). Providers are given by #allProviders: the default query of the application answers the clients"

	| browser mapModel |
	browser := Mock new.
	browser stub application willReturn: self application.
	mapModel := MiButterflyMapModel new
		            browser: browser;
		            yourself.
	mapModel updateFromConfiguration: (mapModel currentConfiguration
			 providersQuery: ((FQCollectScriptQuery script: [ :entity | entity allProviders ])
					  name: 'All providers';
					  yourself);
			 yourself).
	mapModel currentEntity: center.
	^ mapModel
]

{ #category : 'running' }
MiButterflyBlAbstractTest >> nodeOf: anEntity in: aTree [
	"The first node of anEntity in the butterfly of aTree"

	^ aTree roots detect: [ :each | each entity == anEntity ]
]

{ #category : 'running' }
MiButterflyBlAbstractTest >> setUp [

	| package |
	super setUp.
	model := FamixStModel new.
	package := FamixStPackage new
		           name: 'package';
		           mooseModel: model;
		           yourself.
	center := self classNamed: 'Center' in: package.
	client1 := self classNamed: 'Client1' in: package.
	client2 := self classNamed: 'Client2' in: package.
	clientOfClients := self classNamed: 'ClientOfClients' in: package.
	provider := self classNamed: 'Provider' in: package.
	#( 'bar' 'foo' ) do: [ :each |
			FamixStMethod new
				name: each;
				parentType: center;
				mooseModel: model ].
	self inherit: client1 from: center.
	self inherit: client2 from: center.
	self inherit: center from: provider.
	self inherit: clientOfClients from: client1.
	self inherit: clientOfClients from: client2
]

{ #category : 'running' }
MiButterflyBlAbstractTest >> tree [

	^ MiButterflyBlTree new
		  mapModel: self mapModel;
		  build;
		  yourself
]
