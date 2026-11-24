"
I test the tree of the Bloc architectural map (MiArchitecturalMapTreeBl), against what the Roassal builder (MiArchitecturalMapBuilder) shows for the same model: two packages, class1 (in package1) inheriting from class2 and class3 (in package2).
"
Class {
	#name : 'MiArchitecturalMapTreeBlTest',
	#superclass : 'MiArchitecturalMapBlAbstractTest',
	#category : 'MooseIDE-ArchitecturalMap-Bloc-Tests',
	#package : 'MooseIDE-ArchitecturalMap-Bloc-Tests'
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
MiArchitecturalMapTreeBlTest >> testVisibleNode [

	| tree classNode |
	tree := self tree.
	classNode := tree roots first children first.
	self assert: classNode visibleNode identicalTo: tree roots first.
	tree roots first isExpanded: true.
	self assert: classNode visibleNode identicalTo: classNode
]
