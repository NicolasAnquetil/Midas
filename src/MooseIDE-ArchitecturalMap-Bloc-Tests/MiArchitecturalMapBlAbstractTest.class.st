"
I am the common fixture of the tests of the Bloc architectural map: a Famix model with two packages, and Class1 (in package1) inheriting from Class2 and Class3 (both in package2).

## Collaborators & Context
- `MiAbstractApplicationTest`: installs a `MiTestApplication` for the duration of each test.
- `MiArchitecturalMapModel` and its browser (`#mapModelOf:`), `MiArchiBlTreeBuilder` (`#tree`).
- Subclasses: `MiArchitecturalMapTreeBlTest` (the tree) and `MiArchiBlVisualizationTest` (its drawing).

## Assumptions & Invariants
- I am abstract (`#isAbstract`): I hold no tests.
- Each test gets a fresh model from `#setUp`. `#tree` builds a new tree on each send, all nodes collapsed.

## Main API
- `#mapModelOf:` a browser class: a map model of the two packages, opened on that browser.
- `#tree`: a `MiArchiBlTreeBuilder` built from the Bloc browser's map model.

"
Class {
	#name : 'MiArchitecturalMapBlAbstractTest',
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

{ #category : 'testing' }
MiArchitecturalMapBlAbstractTest class >> isAbstract [

	^ self == MiArchitecturalMapBlAbstractTest
]

{ #category : 'running' }
MiArchitecturalMapBlAbstractTest >> mapModelOf: aBrowserClass [
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
MiArchitecturalMapBlAbstractTest >> setUp [

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

{ #category : 'running' }
MiArchitecturalMapBlAbstractTest >> tree [

	^ MiArchiBlTreeBuilder new
		  mapModel: (self mapModelOf: MiArchitecturalMapBrowserBl);
		  build;
		  yourself
]
