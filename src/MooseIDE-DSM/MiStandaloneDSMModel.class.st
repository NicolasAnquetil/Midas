"
Experimental: a DSM model usable without a browser (e.g. from a GLSP server), while still working inside MiDSMBrowser.

It computes the dependencies between entities, orders them as rows (Y) and columns (X), and answers the weight, color and cycles of each cell, like MiDSMBrowserModel; it only tells its browser to redraw when it has one.

Usage:
	MiStandaloneDSMModel on: (MooseModel root allModels first allModelPackages)
	MiStandaloneDSMModel new withX: someEntities withY: otherEntities
"
Class {
	#name : 'MiStandaloneDSMModel',
	#superclass : 'MiDSMBrowserModel',
	#category : 'MooseIDE-DSM-GLSP',
	#package : 'MooseIDE-DSM',
	#tag : 'GLSP'
}

{ #category : 'instance creation' }
MiStandaloneDSMModel class >> on: aCollection [
	"A square DSM of the dependencies between the entities of aCollection"

	^ self new
		  followEntity: aCollection;
		  yourself
]

{ #category : 'actions' }
MiStandaloneDSMModel >> buildDSM [
	"Have the browser draw the DSM again, if there is one"

	browser ifNotNil: [ :aBrowser | aBrowser buildDSM ]
]

{ #category : 'actions' }
MiStandaloneDSMModel >> followEntity: aCollection [
	"A square matrix of the dependencies between the entities of aCollection (see also #withX:withY:)"

	self computeMatrixWithX: aCollection withY: aCollection.
	orderedNodesX := self orderNodes: aCollection.
	orderedNodesY := orderedNodesX.
	self buildDSM
]

{ #category : 'accessing' }
MiStandaloneDSMModel >> selectedEntities: aCollection [

	selectedEntities := aCollection.
	browser ifNotNil: [ :aBrowser | aBrowser updateToolbar ]
]

{ #category : 'settings management' }
MiStandaloneDSMModel >> updateFromConfiguration: aConfiguration [

	shouldShowSelfDependencies := aConfiguration shouldShowSelfDependencies.
	self buildDSM
]

{ #category : 'actions' }
MiStandaloneDSMModel >> withX: entitiesX withY: entitiesY [
	"A matrix of the dependencies from entitiesX (columns) to entitiesY (rows), probably not square"

	self computeMatrixWithX: entitiesX withY: entitiesY.
	orderedNodesX := self orderNodes: entitiesX.
	orderedNodesY := self orderNodes: entitiesY.
	self buildDSM
]
