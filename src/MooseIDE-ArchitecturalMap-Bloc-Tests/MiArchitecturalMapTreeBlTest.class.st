"
I test the tree of the Bloc architectural map (MiArchitecturalMapTreeBl), against what the Roassal builder (MiArchitecturalMapBuilder) shows for the same model: two packages, class1 (in package1) inheriting from class2 and class3 (in package2).
"
Class {
	#name : 'MiArchitecturalMapTreeBlTest',
	#superclass : 'MiAbstractApplicationTest',
	#instVars : [
		'model',
		'package1',
		'package2',
		'class1',
		'class2',
		'class3'
	],
	#category : 'MooseIDE-ArchitecturalMap-Bloc-Tests',
	#package : 'MooseIDE-ArchitecturalMap-Bloc-Tests'
}

{ #category : 'running' }
MiArchitecturalMapTreeBlTest >> mapModelOf: aBrowserClass [
	"A map model of the two packages, with its browser (the model asks it its layouts)"

	| mapModel |
	mapModel := aBrowserClass newModel.
	aBrowserClass on: mapModel.
	mapModel entities: {
			package1.
			package2 } asMooseGroup.
	^ mapModel
]

{ #category : 'running' }
MiArchitecturalMapTreeBlTest >> pairsOf: aCollectionOfDependencies [

	^ (aCollectionOfDependencies collect: [ :each | each source entity -> each target entity ]) asSet
]

{ #category : 'running' }
MiArchitecturalMapTreeBlTest >> setUp [

	super setUp.
	model := FamixStModel new.
	package1 := FamixStPackage new
		            name: 'package1';
		            mooseModel: model;
		            yourself.
	package2 := FamixStPackage new
		            name: 'package2';
		            mooseModel: model;
		            yourself.
	class1 := FamixStClass new
		          name: 'Class1';
		          parentPackage: package1;
		          mooseModel: model;
		          yourself.
	class2 := FamixStClass new
		          name: 'Class2';
		          parentPackage: package2;
		          mooseModel: model;
		          yourself.
	class3 := FamixStClass new
		          name: 'Class3';
		          parentPackage: package2;
		          mooseModel: model;
		          yourself.
	FamixStInheritance new
		subclass: class1;
		superclass: class2;
		mooseModel: model.
	FamixStInheritance new
		subclass: class1;
		superclass: class3;
		mooseModel: model
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

{ #category : 'running' }
MiArchitecturalMapTreeBlTest >> tree [

	^ MiArchitecturalMapTreeBl new
		  mapModel: (self mapModelOf: MiArchitecturalMapBrowserBl);
		  build;
		  yourself
]
