"
I am a node of the Bloc architectural map that stands for a Moose entity (a package, a class...).

## Collaborators & Context
- `MiBlNode`: my superclass, holds the tree structure and the expanded state.
- `MiArchiBlTreeBuilder>>#nodeForEntity:` creates me, labels me with the entity's `fullDisplayString`, and gives me the nodes of the entity's children (`MiArchitecturalMapModel>>#childrenFor:`).
- `MiBlDependency`: links entity nodes (`MiArchiBlTreeBuilder>>#dependencies`). Only entity nodes are sources and targets of dependencies between entities.

## Assumptions & Invariants
- `entity` is a Moose entity with a `mooseID`: the tree builder keeps one node per entity.
- I have no color of my own: `#color` answers nil, and the visualization uses the background of its theme.

## Main API
- `MiArchiBlEntityNode new entity: anEntity; name: aString; children: someNodes; yourself`
- `#color` (nil), `#isTag` (false), and those of `MiBlNode`.

"
Class {
	#name : 'MiArchiBlEntityNode',
	#superclass : 'MiBlNode',
	#category : 'MooseIDE-Bloc-ArchitecturalMap-data',
	#package : 'MooseIDE-Bloc-ArchitecturalMap',
	#tag : 'data'
}
