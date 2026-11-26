"
I am a node of the Bloc architectural map that stands for a tag (`FamixTag`): I group the entities tagged with it, and have the tag's color.

## Collaborators & Context
- `MiBlNode`: my superclass, holds the tree structure and the expanded state.
- `MiArchiBlTreeBuilder>>#nodeForTag:` creates me, with the tag's name and color, and as children the nodes of the tagged entities.
- `MiArchiBlVisualization>>#backgroundFor:`: my box is filled with my color.

## Assumptions & Invariants
- `entity` is a `FamixTag`.
- My children are `MiArchiBlEntityNode`s of the tagged entities that are not already elsewhere in the map, labelled `owner.name` (see `MiArchiBlTreeBuilder>>#nodeForTag:`).
- I am not the source or target of dependencies between entities, but visible dependencies are lifted to me when I am collapsed.

## Main API
- `MiArchiBlTagNode new entity: aTag; name: aString; color: aColor; children: someNodes; yourself`
- `#color`, `#color:`, `#isTag` (true), and those of `MiBlNode`.

"
Class {
	#name : 'MiArchiBlTagNode',
	#superclass : 'MiBlNode',
	#instVars : [
		'color'
	],
	#category : 'MooseIDE-Bloc-ArchitecturalMap-data',
	#package : 'MooseIDE-Bloc-ArchitecturalMap',
	#tag : 'data'
}

{ #category : 'accessing' }
MiArchiBlTagNode >> color [
	"The color of my tag"

	^ color
]

{ #category : 'accessing' }
MiArchiBlTagNode >> color: aColor [

	color := aColor
]

{ #category : 'testing' }
MiArchiBlTagNode >> isTag [

	^ true
]
