"
I am the abstract superclass of the nodes of a map drawn with Bloc (`MiBlVisualization`). A node stands for a model object, and I hold what all nodes share: their place in the tree, their label, and whether their children are shown.

## Collaborators & Context
- Subclasses, one per kind of map: `MiArchiBlEntityNode` (a Moose entity) and `MiArchiBlTagNode` (a `FamixTag`, with its color) for the architectural map; `MiButterflyBlNode` for the butterfly map.
- The tree builder of each map creates the nodes and sets their name and children (e.g. `MiArchiBlTreeBuilder`).
- `MiBlDependency`: links two nodes. A tree builder lifts the dependencies to the nodes shown with `#visibleNode`.
- `MiBlVisualization`: draws a box for each node (`#boxForNode:`). It shows the label, uses `#color` as background (the theme's when nil), gives a dashed border to a node with children, and draws the children's boxes inside only when the node is expanded.

## Assumptions & Invariants
- I am abstract (`#isAbstract`): use a subclass. `#color` is nil (the theme's) and `#isTag` false unless a subclass says otherwise.
- `entity` is the model object of the node: a Moose entity or a tag.
- `parent` and `children` agree: `#children:` sets me as the parent of each child. The root has no parent. I do not sort the children.
- A node is collapsed at first (`isExpanded` is false). A collapsed node hides its descendants, and their dependencies are drawn on it.
- No thread safety: the nodes are built by a tree builder, then read by the visualization in the Bloc UI process.

## Main API
- Creation is through a subclass: `MiArchiBlEntityNode new entity: anEntity; name: aString; children: someNodes; yourself`
- `#entity`, `#name`, `#parent`, `#children`, `#hasChildren`
- `#color`, `#isTag`: for the drawing.
- `#isExpanded`, `#isExpanded:`: whether the children are shown.
- `#visibleNode`: the node drawn for me. That is myself if all my ancestors are expanded, otherwise my highest collapsed ancestor.
- `#withAllParents`: me and my ancestors, the root last.

"
Class {
	#name : 'MiBlNode',
	#superclass : 'Object',
	#instVars : [
		'entity',
		'name',
		'parent',
		'children',
		'isExpanded'
	],
	#category : 'MooseIDE-Visualization-Bloc-data',
	#package : 'MooseIDE-Visualization-Bloc',
	#tag : 'data'
}

{ #category : 'testing' }
MiBlNode class >> isAbstract [

	^ self == MiBlNode
]

{ #category : 'accessing' }
MiBlNode >> children [

	^ children
]

{ #category : 'accessing' }
MiBlNode >> children: aCollection [

	children := aCollection asOrderedCollection.
	children do: [ :each | each parent: self ]
]

{ #category : 'accessing' }
MiBlNode >> color [
	"The background color of my box, nil for the default one of the theme"

	^ nil
]

{ #category : 'accessing' }
MiBlNode >> entity [

	^ entity
]

{ #category : 'accessing' }
MiBlNode >> entity: anEntity [

	entity := anEntity
]

{ #category : 'testing' }
MiBlNode >> hasChildren [

	^ children isNotEmpty
]

{ #category : 'initialization' }
MiBlNode >> initialize [

	super initialize.
	children := OrderedCollection new.
	isExpanded := false
]

{ #category : 'accessing' }
MiBlNode >> isExpanded [

	^ isExpanded
]

{ #category : 'accessing' }
MiBlNode >> isExpanded: aBoolean [

	isExpanded := aBoolean
]

{ #category : 'accessing' }
MiBlNode >> name [

	^ name
]

{ #category : 'accessing' }
MiBlNode >> name: aString [

	name := aString
]

{ #category : 'accessing' }
MiBlNode >> parent [

	^ parent
]

{ #category : 'accessing' }
MiBlNode >> parent: aNode [

	parent := aNode
]

{ #category : 'printing' }
MiBlNode >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: name asString;
		nextPut: $)
]

{ #category : 'querying' }
MiBlNode >> visibleNode [
	"The node shown for me: myself if all my ancestors are expanded, my highest collapsed ancestor otherwise"

	^ self withAllParents reversed detect: [ :each | each == self or: [ each isExpanded not ] ]
]

{ #category : 'querying' }
MiBlNode >> withAllParents [
	"Me and my ancestors, the root last"

	| result node |
	result := OrderedCollection new.
	node := self.
	[ node isNil ] whileFalse: [
			result add: node.
			node := node parent ].
	^ result
]
