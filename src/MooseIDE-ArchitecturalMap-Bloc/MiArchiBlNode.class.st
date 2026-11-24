"
I am the abstract superclass of the nodes of the architectural map drawn with Bloc. A node stands for a model object, and I hold what all nodes share: their place in the tree, their label, and whether their children are shown.

## Collaborators & Context
- Subclasses: `MiArchiBlEntityNode` (a Moose entity) and `MiArchiBlTagNode` (a `FamixTag`, with its color).
- `MiArchiBlTreeBuilder`: creates the nodes (`#nodeForEntity:`, `#nodeForTag:`) and sets their name and children.
- `MiArchiBlDependency`: links two nodes. `MiArchiBlTreeBuilder>>#visibleDependencies` moves dependencies up to the nodes shown, using `#visibleNode`.
- `MiArchiBlVisualization`: draws a box for each node (`#elementForNode:`). It shows the label, uses `#color` as background (the theme's when nil), gives a dashed border to a node with children, and draws the children's boxes inside only when the node is expanded.

## Assumptions & Invariants
- I am abstract (`#isAbstract`): subclasses define `#color` and `#isTag`.
- `entity` is the model object of the node: a Moose entity or a tag.
- `parent` and `children` agree: `#children:` sets me as the parent of each child. The root has no parent. I do not sort the children: the tree builder gives them sorted by name.
- A node is collapsed at first (`isExpanded` is false). A collapsed node hides its descendants, and their dependencies are drawn on it.
- No thread safety: the nodes are built by the tree builder, then read by the visualization in the Bloc UI process.

## Main API
- Creation is through a subclass: `MiArchiBlEntityNode new entity: anEntity; name: aString; children: someNodes; yourself`
- `#entity`, `#name`, `#parent`, `#children`, `#hasChildren`
- `#color`, `#isTag`: subclass responsibilities.
- `#isExpanded`, `#isExpanded:`: whether the children are shown.
- `#visibleNode`: the node drawn for me. That is myself if all my ancestors are expanded, otherwise my highest collapsed ancestor.
- `#withAllParents`: me and my ancestors, the root last.

"
Class {
	#name : 'MiArchiBlNode',
	#superclass : 'Object',
	#instVars : [
		'entity',
		'name',
		'parent',
		'children',
		'isExpanded'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc-data',
	#package : 'MooseIDE-ArchitecturalMap-Bloc',
	#tag : 'data'
}

{ #category : 'testing' }
MiArchiBlNode class >> isAbstract [

	^ self == MiArchiBlNode
]

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
	"The background color of my box, nil for the default one"

	^ self subclassResponsibility
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

{ #category : 'accessing' }
MiArchiBlNode >> isTag [

	^ self subclassResponsibility
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
