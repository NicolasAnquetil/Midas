"
I am a dependency of an architectural map shown with Bloc: from a source node to a target node (MiArchitecturalMapNodeBl), with the Famix associations behind it. One association between entities (MiArchitecturalMapTreeBl>>dependencies), or all those between two visible nodes (MiArchitecturalMapTreeBl>>visibleDependencies).
"
Class {
	#name : 'MiArchitecturalMapDependencyBl',
	#superclass : 'Object',
	#instVars : [
		'source',
		'target',
		'associations'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc',
	#package : 'MooseIDE-ArchitecturalMap-Bloc'
}

{ #category : 'accessing' }
MiArchitecturalMapDependencyBl >> association [
	"The first association behind me"

	^ self associations first
]

{ #category : 'accessing' }
MiArchitecturalMapDependencyBl >> association: aFamixAssociation [

	associations := { aFamixAssociation }
]

{ #category : 'accessing' }
MiArchitecturalMapDependencyBl >> associations [

	^ associations ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
MiArchitecturalMapDependencyBl >> associations: aCollection [

	associations := aCollection
]

{ #category : 'accessing' }
MiArchitecturalMapDependencyBl >> printOn: aStream [

	aStream
		print: source;
		nextPutAll: ' -> ';
		print: target
]

{ #category : 'accessing' }
MiArchitecturalMapDependencyBl >> source [

	^ source
]

{ #category : 'accessing' }
MiArchitecturalMapDependencyBl >> source: aNode [

	source := aNode
]

{ #category : 'accessing' }
MiArchitecturalMapDependencyBl >> target [

	^ target
]

{ #category : 'accessing' }
MiArchitecturalMapDependencyBl >> target: aNode [

	target := aNode
]
