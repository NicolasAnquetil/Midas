"
I test MiStandaloneDSMModel: a DSM model computed without a MiDSMBrowser.
"
Class {
	#name : 'MiStandaloneDSMModelTest',
	#superclass : 'TestCase',
	#instVars : [
		'famixModel',
		'class1',
		'class2',
		'class3',
		'dsm'
	],
	#category : 'MooseIDE-Tests-Browsers',
	#package : 'MooseIDE-Tests',
	#tag : 'Browsers'
}

{ #category : 'running' }
MiStandaloneDSMModelTest >> setUp [
	"Class1 depends on Class2 (mth1 invokes mth2); Class3 depends on nothing"

	| mth1 mth2 |
	super setUp.
	famixModel := FamixJavaModel new.
	class1 := famixModel newClassNamed: 'Class1'.
	class2 := famixModel newClassNamed: 'Class2'.
	class3 := famixModel newClassNamed: 'Class3'.
	mth1 := (famixModel newMethodNamed: 'mth1') parentType: class1.
	mth2 := (famixModel newMethodNamed: 'mth2') parentType: class2.
	famixModel newInvocation
		sender: mth1;
		candidates: { mth2 }.
	dsm := MiStandaloneDSMModel new
]

{ #category : 'tests' }
MiStandaloneDSMModelTest >> testDependenciesAreComputed [

	dsm followEntity: {
			class1.
			class2.
			class3 }.
	self assert: (dsm isDependency: (self tupleFrom: class1 to: class2)).
	self deny: (dsm isDependency: (self tupleFrom: class2 to: class1)).
	self assert: (dsm getTupleDependencyWeight: (self tupleFrom: class1 to: class2)) equals: 1.
	self assert: (dsm getTupleDependencyWeight: (self tupleFrom: class3 to: class1)) equals: 0
]

{ #category : 'tests' }
MiStandaloneDSMModelTest >> testFollowEntityWithoutBrowser [

	dsm followEntity: {
			class1.
			class2.
			class3 }.
	self assert: dsm orderedNodesX size equals: 3.
	self assert: dsm orderedNodesY equals: dsm orderedNodesX.
	self assertCollection: (dsm orderedNodesX collect: [ :node | node model ]) hasSameElements: {
			class1.
			class2.
			class3 }
]

{ #category : 'tests' }
MiStandaloneDSMModelTest >> testOnEntities [
	dsm := MiStandaloneDSMModel on: { class1. class2 }.
	self assert: dsm orderedNodesX size equals: 2.
	self assert: (dsm isDependency: (self tupleFrom: class1 to: class2))
]

{ #category : 'tests' }
MiStandaloneDSMModelTest >> testSelectingEntitiesWithoutBrowser [

	dsm followEntity: {
			class1.
			class2 }.
	dsm selectedEntities: { class1 }.
	self assert: dsm miSelectedItem asArray equals: { class1 }
]

{ #category : 'tests' }
MiStandaloneDSMModelTest >> testSettingsWithoutBrowser [

	dsm followEntity: {
			class1.
			class2 }.
	dsm updateFromConfiguration: (MiDSMSettingsConfiguration new
			 shouldShowSelfDependencies: false;
			 yourself).
	self deny: dsm currentConfiguration shouldShowSelfDependencies
]

{ #category : 'tests' }
MiStandaloneDSMModelTest >> testWithXWithYWithoutBrowser [

	dsm withX: { class1 } withY: {
			class2.
			class3 }.
	self assert: (dsm orderedNodesX collect: [ :node | node model ]) asArray equals: { class1 }.
	self assertCollection: (dsm orderedNodesY collect: [ :node | node model ]) hasSameElements: {
			class2.
			class3 }
]

{ #category : 'running' }
MiStandaloneDSMModelTest >> tupleFrom: anEntity to: anotherEntity [

	^ (dsm graph findNode: anEntity) -> (dsm graph findNode: anotherEntity)
]
