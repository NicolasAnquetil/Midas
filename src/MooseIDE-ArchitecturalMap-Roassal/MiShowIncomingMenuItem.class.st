Class {
	#name : 'MiShowIncomingMenuItem',
	#superclass : 'MiArchitecturalNodeMenuItem',
	#category : 'MooseIDE-ArchitecturalMap-Roassal-Menu',
	#package : 'MooseIDE-ArchitecturalMap-Roassal',
	#tag : 'Menu'
}

{ #category : 'accessing' }
MiShowIncomingMenuItem >> canBeExecuted [

	^ shape isShape and: [ 
		  shape isNode and: [ 
			  shape model rawModel isTag or: [ 
				  shape model parent rawModel isTag ] ] ]
]

{ #category : 'accessing' }
MiShowIncomingMenuItem >> execute [

	visualization addIncomingsFor: shape model
]

{ #category : 'accessing' }
MiShowIncomingMenuItem >> label [
	^ 'Show incoming'
]
