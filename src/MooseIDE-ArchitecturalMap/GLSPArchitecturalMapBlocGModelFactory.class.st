"
I build the same GModel as my superclass, but the root nodes are placed by a Bloc BlGridLayout instead of a Roassal layout.

Roassal still builds the shapes (their size and label); I give each one a plain BlElement of the same extent in a headless grid parent, let Bloc lay them out, and move each shape to the bounds Bloc computed.
"
Class {
	#name : 'GLSPArchitecturalMapBlocGModelFactory',
	#superclass : 'GLSPArchitecturalMapGModelFactory',
	#category : 'MooseIDE-ArchitecturalMap-GLSP',
	#package : 'MooseIDE-ArchitecturalMap',
	#tag : 'GLSP'
}

{ #category : 'building' }
GLSPArchitecturalMapBlocGModelFactory >> columnCountFor: aNumberOfNodes [
	"As many columns as rows (or one more)"

	^ aNumberOfNodes sqrt ceiling max: 1
]

{ #category : 'building' }
GLSPArchitecturalMapBlocGModelFactory >> gridFor: aNumberOfNodes [
	"A headless element, fitting its content, with a roughly square grid of aNumberOfNodes cells"

	^ BlElement new
		  layout: (BlGridLayout horizontal
				   columnCount: (self columnCountFor: aNumberOfNodes);
				   cellSpacing: self gapSize;
				   yourself);
		  constraintsDo: [ :c |
				  c horizontal fitContent.
				  c vertical fitContent ];
		  yourself
]

{ #category : 'building' }
GLSPArchitecturalMapBlocGModelFactory >> rootShapesFor: aMapModel [
	"The Roassal shapes of the root nodes, moved to the cells of a Bloc grid"

	| shapes elements |
	shapes := super rootShapesFor: aMapModel.
	shapes ifEmpty: [ ^ shapes ].
	elements := shapes collect: [ :each |
			            BlElement new
				            extent: each encompassingRectangle extent;
				            yourself ].
	(self gridFor: shapes size)
		addChildren: elements;
		forceLayout.
	shapes with: elements do: [ :shape :element | shape translateTo: element bounds inParent bounds center ].
	^ shapes
]
