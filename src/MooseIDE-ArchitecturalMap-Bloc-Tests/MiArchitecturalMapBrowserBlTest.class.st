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

	self assert: browser specModel availableLayouts equals: MiArchiBlLayout availableLayouts.
	self assert: (browser specModel availableLayouts allSatisfy: [ :each | each layoutName isString ])
]

{ #category : 'tests' }
MiArchitecturalMapBrowserBlTest >> testFrontEndClassChosenInApplication [

	| app previous |
	app := MiArchitecturalMapBrowser currentApplication.
	previous := app architecturalMapBrowserClass.
	[
		app architecturalMapBrowserClass: MiArchitecturalMapBrowserBl.
		self assert: MiArchitecturalMapBrowser frontEndClass identicalTo: MiArchitecturalMapBrowserBl ] ensure: [
		app architecturalMapBrowserClass: previous ]
]

{ #category : 'tests' }
MiArchitecturalMapBrowserBlTest >> testFrontEndClassDefault [

	MiArchitecturalMapBrowser currentApplication architecturalMapBrowserClass: nil.
	self assert: MiArchitecturalMapBrowser frontEndClass identicalTo: MiArchitecturalMapBrowser
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
