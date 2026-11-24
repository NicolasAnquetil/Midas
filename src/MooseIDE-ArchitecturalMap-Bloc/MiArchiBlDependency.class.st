"
I am a dependency of the Bloc architectural map: from a `source` node to a `target` node (`MiArchiBlNode`), with the Famix associations behind it.

## Collaborators & Context
- `MiArchiBlTreeBuilder`: creates me in two forms. `#dependencies` gives one dependency per association between two entities of the map (`#association:`). `#visibleDependencies` gives one dependency per pair of visible nodes, with all the associations between their descendants (`#associations:`).
- `MiArchiBlVisualization>>#updateLines`: draws a line for each visible dependency, between the boxes of my source and target.
- The associations are Famix associations, as answered by `MiArchitecturalMapModel>>#getDependenciesFor:`.

## Assumptions & Invariants
- `source` and `target` are nodes of the same tree. A visible dependency never goes from a node to itself.
- `#associations` is never nil (empty by default). `#association` assumes there is at least one.
- I am a plain value: built once, then only read.

## Main API
- `MiArchiBlDependency new source: aNode; target: aNode; association: anAssociation; yourself` (or `associations: aCollection`)
- `#source`, `#target`, `#associations`, `#association` (the first one).

"
Class {
	#name : 'MiArchiBlDependency',
	#superclass : 'Object',
	#instVars : [
		'source',
		'target',
		'associations'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc-data',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'data'
}

{ #category : 'accessing' }
MiArchiBlDependency >> association [
	"The first association behind me"

	^ self associations first
]

{ #category : 'accessing' }
MiArchiBlDependency >> association: aFamixAssociation [

	associations := { aFamixAssociation }
]

{ #category : 'accessing' }
MiArchiBlDependency >> associations [

	^ associations ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
MiArchiBlDependency >> associations: aCollection [

	associations := aCollection
]

{ #category : 'accessing' }
MiArchiBlDependency >> printOn: aStream [

	aStream
		print: source;
		nextPutAll: ' -> ';
		print: target
]

{ #category : 'accessing' }
MiArchiBlDependency >> source [

	^ source
]

{ #category : 'accessing' }
MiArchiBlDependency >> source: aNode [

	source := aNode
]

{ #category : 'accessing' }
MiArchiBlDependency >> target [

	^ target
]

{ #category : 'accessing' }
MiArchiBlDependency >> target: aNode [

	target := aNode
]
