"
I am a node of an architectural map shown with Bloc (MiArchitecturalMapBrowserBl).

I know my `entity`, `parent`, `children` (sorted by name), my label (`name`), and my `color` (the color of a tag, nil for an entity). I am collapsed by default (`isExpanded`): a collapsed node hides its children, and the dependencies of its descendants are shown on it (see #visibleNode).

"
Class {
	#name : 'MiArchiBlNode',
	#superclass : 'Object',
	#instVars : [
		'entity',
		'name',
		'color',
		'parent',
		'children',
		'isExpanded'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc-data',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'data'
}

{ #category : 'accessing' }
MiArchiBlNode >> children [

	^ children
]

{ #category : 'accessing' }
MiArchiBlNode >> children: aCollection [

	children := aCollection asOrderedCollection.
	children do: [ :each | each parent: self ]
]

{ #category : 'accessing' }
MiArchiBlNode >> color [
	"The color of a tag, nil for an entity"

	^ color
]

{ #category : 'accessing' }
MiArchiBlNode >> color: aColor [

	color := aColor
]

{ #category : 'accessing' }
MiArchiBlNode >> entity [

	^ entity
]

{ #category : 'accessing' }
MiArchiBlNode >> entity: anEntity [

	entity := anEntity
]

{ #category : 'testing' }
MiArchiBlNode >> hasChildren [

	^ children isNotEmpty
]

{ #category : 'initialization' }
MiArchiBlNode >> initialize [

	super initialize.
	children := OrderedCollection new.
	isExpanded := false
]

{ #category : 'accessing' }
MiArchiBlNode >> isExpanded [

	^ isExpanded
]

{ #category : 'accessing' }
MiArchiBlNode >> isExpanded: aBoolean [

	isExpanded := aBoolean
]

{ #category : 'testing' }
MiArchiBlNode >> isTag [

	^ entity isTag
]

{ #category : 'accessing' }
MiArchiBlNode >> name [

	^ name
]

{ #category : 'accessing' }
MiArchiBlNode >> name: aString [

	name := aString
]

{ #category : 'accessing' }
MiArchiBlNode >> parent [

	^ parent
]

{ #category : 'accessing' }
MiArchiBlNode >> parent: aNode [

	parent := aNode
]

{ #category : 'printing' }
MiArchiBlNode >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: name asString;
		nextPut: $)
]

{ #category : 'querying' }
MiArchiBlNode >> visibleNode [
	"The node shown for me: myself if all my ancestors are expanded, my highest collapsed ancestor otherwise"

	^ self withAllParents reversed detect: [ :each | each == self or: [ each isExpanded not ] ]
]

{ #category : 'querying' }
MiArchiBlNode >> withAllParents [
	"Me and my ancestors, the root last"

	| result node |
	result := OrderedCollection new.
	node := self.
	[ node isNil ] whileFalse: [
			result add: node.
			node := node parent ].
	^ result
]
