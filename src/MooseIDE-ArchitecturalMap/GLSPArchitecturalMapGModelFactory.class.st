"
I turn a MiStandaloneArchitecturalMapModel into a GModel: a node per root entity (positioned and sized by the Roassal layout of MiArchitecturalMapBuilder) and one edge per ordered pair of roots having a dependency between their descendants.
"
Class {
	#name : 'GLSPArchitecturalMapGModelFactory',
	#superclass : 'GLSPGModelFactory',
	#category : 'MooseIDE-ArchitecturalMap-GLSP',
	#package : 'MooseIDE-ArchitecturalMap',
	#tag : 'GLSP'
}

{ #category : 'building' }
GLSPArchitecturalMapGModelFactory >> circleRadiusFor: aCollectionOfShapes [
	"A radius large enough for two neighbours on the circle not to overlap:
	the chord between them (2 r sin(pi / n)) is at least the widest shape plus the gap.
	0 lets RSCircleLayout compute its own radius (fine for a single shape)"

	| widest |
	aCollectionOfShapes size < 2 ifTrue: [ ^ 0 ].
	widest := aCollectionOfShapes inject: 0 into: [ :max :each | max max: each width ].
	^ widest + self gapSize / (2 * (Float pi / aCollectionOfShapes size) sin)
]

{ #category : 'creation' }
GLSPArchitecturalMapGModelFactory >> createGModel: aModelState [

	| mapModel shapes origin root nodeIds |
	mapModel := aModelState sourceModel.
	shapes := self rootShapesFor: mapModel.
	root := GLSPGModelRoot new
		        id: 'archmap';
		        type: 'graph';
		        yourself.
	shapes ifEmpty: [ ^ root ].
	origin := (shapes collect: [ :each | each encompassingRectangle origin ])
		          inject: shapes first encompassingRectangle origin
		          into: [ :min :each | min min: each ].
	nodeIds := Dictionary new.
	shapes do: [ :shape |
			| entity |
			entity := shape model rawModel.
			nodeIds at: entity put: (self idFor: entity).
			root add: (self nodeFor: shape origin: origin) ].
	root addAll: (self edgesFor: mapModel nodeIds: nodeIds).
	^ root
]

{ #category : 'building' }
GLSPArchitecturalMapGModelFactory >> edgesFor: aMapModel nodeIds: aDictionary [
	"One edge per ordered pair of roots, from the root of the dependent entity to the root of the entity it depends on"

	| rootOf pairs edges |
	rootOf := Dictionary new.
	aDictionary keysDo: [ :root |
		(self withAllDescendantsOf: root in: aMapModel) do: [ :each | rootOf at: each ifAbsentPut: [ root ] ] ].
	pairs := OrderedCollection new.
	rootOf keysAndValuesDo: [ :entity :targetRoot |
			entity isQueryable ifTrue: [
					(aMapModel getDependenciesFor: entity) do: [ :dependency |
							dependency source ifNotNil: [ :source |
									rootOf at: source ifPresent: [ :sourceRoot |
											| pair |
											pair := sourceRoot -> targetRoot.
											(sourceRoot ~~ targetRoot and: [ (pairs includes: pair) not ]) ifTrue: [ pairs add: pair ] ] ] ] ] ].
	edges := OrderedCollection new.
	pairs doWithIndex: [ :pair :index |
			edges add: (GLSPGEdge new
					 id: 'e' , index printString;
					 type: 'archmap-dependency';
					 sourceId: (aDictionary at: pair key);
					 targetId: (aDictionary at: pair value);
					 yourself) ].
	^ edges
]

{ #category : 'building' }
GLSPArchitecturalMapGModelFactory >> gapSize [

	^ 40
]

{ #category : 'building' }
GLSPArchitecturalMapGModelFactory >> idFor: anEntity [

	^ 'n' , anEntity mooseID printString
]

{ #category : 'building' }
GLSPArchitecturalMapGModelFactory >> margin [

	^ 20 @ 20
]

{ #category : 'building' }
GLSPArchitecturalMapGModelFactory >> maxWidth [

	^ 1000
]

{ #category : 'building' }
GLSPArchitecturalMapGModelFactory >> nodeFor: aShape origin: aPoint [

	| entity rectangle id node |
	entity := aShape model rawModel.
	rectangle := aShape encompassingRectangle.
	id := self idFor: entity.
	node := GLSPGNode new
		        id: id;
		        type: 'archmap-node';
		        position: rectangle origin - aPoint + self margin;
		        size: rectangle extent;
		        yourself.
	node add: (GLSPGLabel new
			 id: id , '_label';
			 text: aShape model name;
			 yourself).
	^ node
]

{ #category : 'building' }
GLSPArchitecturalMapGModelFactory >> rootShapesFor: aMapModel [
	"The shapes of the (collapsed) root nodes, laid out by Roassal.
	The default flow and circle layouts of the map are very tight: spread them a bit"

	| canvas shapes |
	canvas := MiArchitecturalMapBuilder new
		          mapModel: aMapModel;
		          build.
	shapes := canvas nodes select: [ :each | each model isNotNil and: [ each model rawModel isNotNil ] ].
	aMapModel layout = RSFlowLayout ifTrue: [
			RSFlowLayout new
				gapSize: self gapSize;
				maxWidth: self maxWidth;
				on: shapes ].
	aMapModel layout = RSCircleLayout ifTrue: [
			RSCircleLayout new
				initialRadius: (self circleRadiusFor: shapes);
				on: shapes ].
	^ shapes
]

{ #category : 'building' }
GLSPArchitecturalMapGModelFactory >> withAllDescendantsOf: anEntity in: aMapModel [

	| result todo |
	result := IdentitySet new.
	todo := OrderedCollection with: anEntity.
	[ todo isEmpty ] whileFalse: [
			| each |
			each := todo removeFirst.
			(result includes: each) ifFalse: [
					result add: each.
					todo addAll: (aMapModel childrenFor: each) ] ].
	^ result
]
