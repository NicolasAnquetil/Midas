"
I am a dependency of an architectural map shown with Bloc: from a `source` node to a `target` node (`MiArchiBlNode`), with the Famix associations behind it.
One association between entities (`MiArchiBlTreeBuilder>>#dependencies`), or all those between two visible nodes (`MiArchiBlTreeBuilder>>#visibleDependencies`).
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
