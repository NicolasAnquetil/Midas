"
I am a dependency of a map drawn with Bloc (`MiBlVisualization`): from a `source` node to a `target` node (`MiBlNode`), with the associations behind it.

## Collaborators & Context
- The tree builder of a map creates me. `MiArchiBlTreeBuilder` does it in two forms: `#dependencies` gives one dependency per association between two entities of the map (`#association:`); `#visibleDependencies` gives one dependency per pair of visible nodes, with all the associations between their descendants (`#associations:`).
- `MiBlVisualization>>#updateLines`: draws a line for each visible dependency, between the boxes of my source and target.
- The associations are usually Famix associations (e.g. as answered by `MiArchitecturalMapModel>>#getDependenciesFor:`); a map can also have dependencies with none (`#associations` empty).

## Assumptions & Invariants
- `source` and `target` are nodes of the same tree. A visible dependency never goes from a node to itself.
- `#associations` is never nil (empty by default). `#association` assumes there is at least one.
- I am a plain value: built once, then only read.

## Main API
- `MiBlDependency new source: aNode; target: aNode; association: anAssociation; yourself` (or `associations: aCollection`)
- `#source`, `#target`, `#associations`, `#association` (the first one).

"
Class {
	#name : 'MiBlDependency',
	#superclass : 'Object',
	#instVars : [
		'source',
		'target',
		'associations'
	],
	#category : 'MooseIDE-Visualization-Bloc-data',
	#package : 'MooseIDE-Visualization-Bloc',
	#tag : 'data'
}

{ #category : 'accessing' }
MiBlDependency >> association [
	"The first association behind me"

	^ self associations first
]

{ #category : 'accessing' }
MiBlDependency >> association: aFamixAssociation [

	associations := { aFamixAssociation }
]

{ #category : 'accessing' }
MiBlDependency >> associations [

	^ associations ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
MiBlDependency >> associations: aCollection [

	associations := aCollection
]

{ #category : 'printing' }
MiBlDependency >> printOn: aStream [

	aStream
		print: source;
		nextPutAll: ' -> ';
		print: target
]

{ #category : 'accessing' }
MiBlDependency >> source [

	^ source
]

{ #category : 'accessing' }
MiBlDependency >> source: aNode [

	source := aNode
]

{ #category : 'accessing' }
MiBlDependency >> target [

	^ target
]

{ #category : 'accessing' }
MiBlDependency >> target: aNode [

	target := aNode
]
