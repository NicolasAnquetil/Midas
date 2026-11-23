"
I am a node of an architectural map shown with Bloc (MiArchitecturalMapBrowserBl): an entity of the map, or a tag grouping its tagged entities.

I know my parent and my children (sorted by name), my label (name) and my color (the color of a tag, nil for an entity). I am collapsed by default (isExpanded): a collapsed node hides its children, and the dependencies of its descendants are shown on it (see #visibleNode).

I do not depend on Roassal: MiArchitecturalMapTreeBl builds me from the MiArchitecturalMapModel.
"
Class {
	#name : 'MiArchitecturalMapNodeBl',
	#superclass : 'Object',
	#instVars : [
		'entity',
		'name',
		'color',
		'parent',
		'children',
		'isExpanded'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc',
	#package : 'MooseIDE-ArchitecturalMap-Bloc'
}

{ #category : 'accessing' }
MiArchitecturalMapNodeBl >> children [

	^ children
]

{ #category : 'accessing' }
MiArchitecturalMapNodeBl >> children: aCollection [

	children := aCollection asOrderedCollection.
	children do: [ :each | each parent: self ]
]

{ #category : 'accessing' }
MiArchitecturalMapNodeBl >> color [
	"The color of a tag, nil for an entity"

	^ color
]

{ #category : 'accessing' }
MiArchitecturalMapNodeBl >> color: aColor [

	color := aColor
]

{ #category : 'accessing' }
MiArchitecturalMapNodeBl >> entity [

	^ entity
]

{ #category : 'accessing' }
MiArchitecturalMapNodeBl >> entity: anEntity [

	entity := anEntity
]

{ #category : 'testing' }
MiArchitecturalMapNodeBl >> hasChildren [

	^ children isNotEmpty
]

{ #category : 'initialization' }
MiArchitecturalMapNodeBl >> initialize [

	super initialize.
	children := OrderedCollection new.
	isExpanded := false
]

{ #category : 'accessing' }
MiArchitecturalMapNodeBl >> isExpanded [

	^ isExpanded
]

{ #category : 'accessing' }
MiArchitecturalMapNodeBl >> isExpanded: aBoolean [

	isExpanded := aBoolean
]

{ #category : 'testing' }
MiArchitecturalMapNodeBl >> isTag [

	^ entity isTag
]

{ #category : 'accessing' }
MiArchitecturalMapNodeBl >> name [

	^ name
]

{ #category : 'accessing' }
MiArchitecturalMapNodeBl >> name: aString [

	name := aString
]

{ #category : 'accessing' }
MiArchitecturalMapNodeBl >> parent [

	^ parent
]

{ #category : 'accessing' }
MiArchitecturalMapNodeBl >> parent: aNode [

	parent := aNode
]

{ #category : 'printing' }
MiArchitecturalMapNodeBl >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: name asString;
		nextPut: $)
]

{ #category : 'querying' }
MiArchitecturalMapNodeBl >> visibleNode [
	"The node shown for me: myself if all my ancestors are expanded, my highest collapsed ancestor otherwise"

	^ self withAllParents reversed detect: [ :each | each == self or: [ each isExpanded not ] ]
]

{ #category : 'querying' }
MiArchitecturalMapNodeBl >> withAllParents [
	"Me and my ancestors, the root last"

	| result node |
	result := OrderedCollection new.
	node := self.
	[ node isNil ] whileFalse: [
			result add: node.
			node := node parent ].
	^ result
]
