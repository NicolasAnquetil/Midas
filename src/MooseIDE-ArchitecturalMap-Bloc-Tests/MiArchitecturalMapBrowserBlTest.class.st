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

	self assert: browser specModel availableLayouts equals: MiArchitecturalMapLayoutBl availableLayouts.
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

	self skip: 'No selection in the Bloc map yet'
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
