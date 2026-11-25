Extension { #name : 'HNode' }

{ #category : '*MooseIDE-ButterflyMap-Roassal' }
HNode >> remove [

	self removeAllLinks.
	parent ifNotNil: [ parent remove: self ]
	
]

{ #category : '*MooseIDE-ButterflyMap-Roassal' }
HNode >> remove: anHNode [

	children remove: anHNode
	
]

{ #category : '*MooseIDE-ButterflyMap-Roassal' }
HNode >> removeAllLinks [

	self allDependencies do: [ :link | 
		link to removeLink: link.
		link from removeLink: link ]
]
