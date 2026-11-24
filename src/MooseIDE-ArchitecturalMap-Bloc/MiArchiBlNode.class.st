"
I am a node of the architectural map drawn with Bloc. I stand for one Moose entity, or for a tag (`FamixTag`), and I know my place in the tree, my label, my color and whether my children are shown.

## Collaborators & Context
- `MiArchiBlTreeBuilder`: creates me (`#nodeForEntity:`, `#nodeForTag:`) and sets my name, color and children.
- `MiArchiBlDependency`: links two nodes. `MiArchiBlTreeBuilder>>#visibleDependencies` moves dependencies up to the nodes shown, using my `#visibleNode`.
- `MiArchiBlVisualization`: draws a box for me (`#elementForNode:`). It shows my label, uses my color as background, gives me a dashed border when I have children, and draws my children's boxes inside mine only when I am expanded.

## Assumptions & Invariants
- `entity` is a Moose entity or a tag. `#isTag` asks the entity.
- `color` is the tag's color for a tag node, nil for an entity node (the visualization then uses the theme's background).
- `parent` and `children` agree: `#children:` sets me as the parent of each child. The root has no parent. I do not sort my children: the tree builder gives them sorted by name.
- I am collapsed at first (`isExpanded` is false). A collapsed node hides its descendants, and their dependencies are drawn on it.
- No thread safety: I am built by the tree builder, then read by the visualization in the Bloc UI process.

## Main API
- `MiArchiBlNode new entity: anEntity; name: aString; color: aColorOrNil; children: someNodes; yourself`
- `#entity`, `#name`, `#color`, `#parent`, `#children`, `#hasChildren`, `#isTag`
- `#isExpanded`, `#isExpanded:`: whether my children are shown.
- `#visibleNode`: the node drawn for me. That is myself if all my ancestors are expanded, otherwise my highest collapsed ancestor.
- `#withAllParents`: me and my ancestors, the root last.

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
