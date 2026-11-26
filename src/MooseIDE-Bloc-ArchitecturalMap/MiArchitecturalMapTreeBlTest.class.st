"
I test the tree of the Bloc architectural map (`MiArchiBlTreeBuilder`): its roots, the children of the nodes, the dependencies between entities, and the dependencies lifted to the visible nodes. I also check that the visible dependencies are the lines of the Roassal map (`MiArchitecturalMapBuilder`) for the same model.

## Collaborators & Context
- `MiArchitecturalMapBlAbstractTest`: the fixture (package1 holding Class1, package2 holding Class2 and Class3, Class1 inheriting from both) and `#tree`.
- `MiBlNode` (`#visibleNode`, `#isExpanded:`), `MiBlDependency`.
- `MiArchitecturalMapBrowser` and `MiArchitecturalMapBuilder`: the Roassal map, as the reference.

## Assumptions & Invariants
- `#tree` builds a new tree on each send, all nodes collapsed: expand the nodes of the tree kept in a variable.

## Main API
- `#pairsOf:` dependencies: their (source entity -> target entity) pairs, as a set.

"
Class {
	#name : 'MiArchitecturalMapTreeBlTest',
	#superclass : 'MiArchitecturalMapBlAbstractTest',
	#category : 'MooseIDE-Bloc-ArchitecturalMap-tests',
	#package : 'MooseIDE-Bloc-ArchitecturalMap',
	#tag : 'tests'
}

{ #category : 'running' }
MiArchitecturalMapTreeBlTest >> pairsOf: aCollectionOfDependencies [

	^ (aCollectionOfDependencies collect: [ :each | each source entity -> each target entity ]) asSet
]

{ #category : 'tests' }
MiArchitecturalMapTreeBlTest >> testChildren [

	| roots |
	roots := self tree roots.
	self assert: (roots first children collect: #entity) asArray equals: { class1 }.
	self assert: (roots second children collect: #entity) asArray equals: {
			class2.
			class3 }.
	self assert: (roots second children allSatisfy: [ :each | each parent == roots second ])
]

{ #category : 'tests' }
MiArchitecturalMapTreeBlTest >> testDependencies [
	"Between entities: the inheritances, from the subclass to the superclass"

	self assert: (self pairsOf: self tree dependencies) equals: {
			(class1 -> class2).
			(class1 -> class3) } asSet
]

{ #category : 'tests' }
MiArchitecturalMapTreeBlTest >> testNoTagNodeWithoutTags [

	self deny: (self tree roots anySatisfy: [ :each | each isTag ])
]

{ #category : 'tests' }
MiArchitecturalMapTreeBlTest >> testNodeKinds [
	"The packages and classes of the fixture are entity nodes"

	| roots |
	roots := self tree roots.
	self assert: (roots allSatisfy: [ :each | each class == MiArchiBlEntityNode ]).
	self assert: (roots second children allSatisfy: [ :each | each class == MiArchiBlEntityNode and: [ each isTag not ] ])
]

{ #category : 'tests' }
MiArchitecturalMapTreeBlTest >> testRoots [

	self assert: (self tree roots collect: #entity) asArray equals: {
			package1.
			package2 }
]

{ #category : 'tests' }
MiArchitecturalMapTreeBlTest >> testSameLinesAsRoassal [
	"The visible dependencies are the lines of the Roassal map, with the same associations"

	| roassalLines bloc roassal |
	roassalLines := (MiArchitecturalMapBuilder new
		                 mapModel: (self mapModelOf: MiArchitecturalMapBrowser);
		                 build;
		                 yourself) canvas lines.
	roassal := (roassalLines collect: [ :each |
			            {
				            each from model rawModel.
				            each to model rawModel.
				            each model asSet } ]) asSet.
	bloc := (self tree visibleDependencies collect: [ :each |
			         {
				         each source entity.
				         each target entity.
				         each associations asSet } ]) asSet.
	self assert: bloc equals: roassal
]

{ #category : 'tests' }
MiArchitecturalMapTreeBlTest >> testTagNode [
	"A shown tag is a root, before the entities, with its name and color"

	| tag tagNode |
	tag := self tagNamed: 'core' color: Color red on: class2.
	tagNode := (self treeWithTags: { tag }) roots first.
	self assert: tagNode class identicalTo: MiArchiBlTagNode.
	self assert: tagNode isTag.
	self assert: tagNode entity identicalTo: tag.
	self assert: tagNode name equals: 'core'.
	self assert: tagNode color equals: Color red.
	self assert: tagNode parent isNil
]

{ #category : 'tests' }
MiArchitecturalMapTreeBlTest >> testTaggedEntityIsUnderItsTag [
	"A tagged entity is shown once: under its tag, labelled with its owner, and no longer under its package"

	| tree tagNode package2Node |
	tree := self treeWithTags: { (self tagNamed: 'core' color: Color red on: class2) }.
	tagNode := tree roots first.
	package2Node := tree roots detect: [ :each | each entity == package2 ].
	self assert: (tagNode children collect: #entity) asArray equals: { class2 }.
	self assert: tagNode children first class identicalTo: MiArchiBlEntityNode.
	self assert: tagNode children first name equals: 'package2.Class2'.
	self assert: tagNode children first parent identicalTo: tagNode.
	self assert: (package2Node children collect: #entity) asArray equals: { class3 }
]

{ #category : 'tests' }
MiArchitecturalMapTreeBlTest >> testVisibleDependenciesCollapsed [
	"Collapsed packages stand for their classes: one dependency with both inheritances"

	| visible |
	visible := self tree visibleDependencies.
	self assert: (self pairsOf: visible) equals: { (package1 -> package2) } asSet.
	self assert: visible first associations size equals: 2
]

{ #category : 'tests' }
MiArchitecturalMapTreeBlTest >> testVisibleDependenciesExpanded [

	| tree |
	tree := self tree.
	tree roots do: [ :each | each isExpanded: true ].
	self assert: (self pairsOf: tree visibleDependencies) equals: {
			(class1 -> class2).
			(class1 -> class3) } asSet
]

{ #category : 'tests' }
MiArchitecturalMapTreeBlTest >> testVisibleDependenciesToTag [
	"Collapsed, the tag stands for its tagged entity: class1 -> class2 becomes package1 -> tag"

	| tag tree |
	tag := self tagNamed: 'core' color: Color red on: class2.
	tree := self treeWithTags: { tag }.
	self assert: (self pairsOf: tree visibleDependencies) equals: {
			(package1 -> tag).
			(package1 -> package2) } asSet
]

{ #category : 'tests' }
MiArchitecturalMapTreeBlTest >> testVisibleNode [

	| tree classNode |
	tree := self tree.
	classNode := tree roots first children first.
	self assert: classNode visibleNode identicalTo: tree roots first.
	tree roots first isExpanded: true.
	self assert: classNode visibleNode identicalTo: classNode
]
