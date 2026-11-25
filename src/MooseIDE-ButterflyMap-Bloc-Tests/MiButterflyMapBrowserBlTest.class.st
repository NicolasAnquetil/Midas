"
The tests of the butterfly map browser (`MiButterflyMapBrowserTest`), on its Bloc front-end (`MiButterflyMapBrowserBl`), plus the choice of the front-end in the application, the drawing of the followed entity, the selection, and Be central node.

## Collaborators & Context
- `MiButterflyMapBrowserTest`: the tests of any butterfly map browser; I only change the browser class (`#browserClass`).
- The space of the browser: changes are drawn in its UI process, so the tests wait for it to settle (`BlSpace>>#deferAndSettle:`) before looking at the view.

## Assumptions & Invariants
- The choice of the front-end in the application is restored after each test that changes it.

## Main API
- The tests only.

"
Class {
	#name : 'MiButterflyMapBrowserBlTest',
	#superclass : 'MiButterflyMapBrowserTest',
	#category : 'MooseIDE-ButterflyMap-Bloc-Tests',
	#package : 'MooseIDE-ButterflyMap-Bloc-Tests'
}

{ #category : 'running' }
MiButterflyMapBrowserBlTest >> browserClass [

	^ MiButterflyMapBrowserBl
]

{ #category : 'tests' }
MiButterflyMapBrowserBlTest >> testBeCentralNode [
	"The browser draws the map of the entity of the node instead"

	| model central client view |
	model := FamixStModel new.
	central := FamixStClass new name: 'Central'; mooseModel: model; yourself.
	client := FamixStClass new name: 'Client'; mooseModel: model; yourself.
	FamixStInheritance new subclass: client; superclass: central; mooseModel: model.
	browser followEntity: central.
	browser space deferAndSettle: [  ].
	browser centralEntity: client.
	browser space deferAndSettle: [  ].
	view := browser view.
	self assert: ((view boxes collect: [ :each | view nodeOf: each ]) detect: [ :each | each isCentral ]) entity identicalTo: client
]

{ #category : 'tests' }
MiButterflyMapBrowserBlTest >> testFollowEntityDrawsTheMap [
	"The central entity gets a box, in the UI process of the space"

	| entity |
	entity := FamixStClass new name: 'Central'; mooseModel: FamixStModel new; yourself.
	browser followEntity: entity.
	browser space deferAndSettle: [  ].
	self assert: (browser view boxes collect: [ :each | (browser view nodeOf: each) entity ] as: Array) equals: { entity }
]

{ #category : 'tests' }
MiButterflyMapBrowserBlTest >> testFrontEndClassChosenInApplication [

	| app previous |
	app := MiButterflyMapBrowser currentApplication.
	previous := app butterflyMapBrowserClass.
	[
		app butterflyMapBrowserClass: MiButterflyMapBrowserBl.
		self assert: MiButterflyMapBrowser frontEndClass identicalTo: MiButterflyMapBrowserBl ] ensure: [
		app butterflyMapBrowserClass: previous ]
]

{ #category : 'tests' }
MiButterflyMapBrowserBlTest >> testFrontEndClassDefault [

	| app previous |
	app := MiButterflyMapBrowser currentApplication.
	previous := app butterflyMapBrowserClass.
	[
		app butterflyMapBrowserClass: nil.
		self assert: MiButterflyMapBrowser frontEndClass identicalTo: MiButterflyMapBrowser ] ensure: [
		app butterflyMapBrowserClass: previous ]
]

{ #category : 'tests' }
MiButterflyMapBrowserBlTest >> testMiSelectedItemWithSelection [
	"The entities selected in the map: one box of Client (with the default queries of the application, Client is also on the right)"

	| model central client |
	model := FamixStModel new.
	central := FamixStClass new name: 'Central'; mooseModel: model; yourself.
	client := FamixStClass new name: 'Client'; mooseModel: model; yourself.
	FamixStInheritance new subclass: client; superclass: central; mooseModel: model.
	browser followEntity: central.
	browser space deferAndSettle: [
			| view |
			view := browser view.
			view selectNodes: { ((view boxes collect: [ :each | view nodeOf: each ]) detect: [ :each | each entity == client ]) } ].
	self assert: browser miSelectedItem asArray equals: { client }
]

{ #category : 'tests' }
MiButterflyMapBrowserBlTest >> testMiSelectedItemWithoutSelection [
	"The central entity"

	| entity |
	entity := FamixStClass new name: 'Central'; mooseModel: FamixStModel new; yourself.
	browser followEntity: entity.
	browser space deferAndSettle: [  ].
	self assert: browser miSelectedItem asArray equals: { entity }
]
