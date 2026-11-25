"
The tests of the architectural map browser, on its Bloc front-end (MiArchitecturalMapBrowserBl).
"
Class {
	#name : 'MiArchitecturalMapBrowserBlTest',
	#superclass : 'MiArchitecturalMapBrowserTest',
	#category : 'MooseIDE-ArchitecturalMap-Bloc-Tests',
	#package : 'MooseIDE-ArchitecturalMap-Bloc-Tests'
}

{ #category : 'running' }
MiArchitecturalMapBrowserBlTest >> browserClass [

	^ MiArchitecturalMapBrowserBl
]

{ #category : 'tests' }
MiArchitecturalMapBrowserBlTest >> testAvailableLayoutsAreTheBlocOnes [

	self assert: browser specModel availableLayouts equals: MiBlLayout availableLayouts.
	self assert: (browser specModel availableLayouts allSatisfy: [ :each | each layoutName isString ])
]

{ #category : 'tests' }
MiArchitecturalMapBrowserBlTest >> testFrontEndClassDefault [
	"The default front-end opens the Roassal map"

	self withFrontEnd: MiFrontEnd new do: [ self assert: MiArchitecturalMapBrowser frontEndClass identicalTo: MiArchitecturalMapBrowser ]
]

{ #category : 'tests' }
MiArchitecturalMapBrowserBlTest >> testFrontEndClassInBlocFrontEnd [
	"The Bloc front-end opens me instead of the Roassal map, and opens me as myself"

	self withFrontEnd: MiBlocFrontEnd new do: [
			self assert: MiArchitecturalMapBrowser frontEndClass identicalTo: self browserClass.
			self assert: self browserClass frontEndClass identicalTo: self browserClass ]
]

{ #category : 'tests' }
MiArchitecturalMapBrowserBlTest >> testMiSelectedItemWithSelection [
	"returns selected entities: entity1 and entity3 selected in the map (through its visualization, in the UI process of its space)"

	browser followEntity: {
			entity1.
			entity2.
			entity3 }.
	browser space deferAndSettle: [
			| view |
			view := browser view.
			view selectNodes: ((view boxes collect: [ :each | view nodeOf: each ]) select: [ :each |
						 {
							 entity1.
							 entity3 } includes: each entity ]) ].

	self assertCollection: browser miSelectedItem hasSameElements: {
			entity1.
			entity3 }
]

{ #category : 'tests' }
MiArchitecturalMapBrowserBlTest >> testMiSelectedItemWithoutSelection [
	"returns all entities"

	browser followEntity: {
			entity1.
			entity2.
			entity3 }.

	self assertCollection: browser miSelectedItem hasSameElements: {
			entity1.
			entity2.
			entity3 }
]

{ #category : 'tests' }
MiArchitecturalMapBrowserBlTest >> testShowLoadingMessage [

	self skip: 'No loading message in the Bloc map yet'
]

{ #category : 'running' }
MiArchitecturalMapBrowserBlTest >> withFrontEnd: aFrontEnd do: aBlock [
	"Run aBlock with aFrontEnd as the front-end of the application, then put back the previous one"

	| app previous |
	app := MiArchitecturalMapBrowser currentApplication.
	previous := app frontEnd.
	[
		app frontEnd: aFrontEnd.
		aBlock value ] ensure: [ app frontEnd: previous ]
]
