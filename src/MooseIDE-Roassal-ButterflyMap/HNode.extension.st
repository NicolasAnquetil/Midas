Extension { #name : 'HNode' }

{ #category : '*MooseIDE-Roassal-ButterflyMap' }
HNode >> remove [

	self removeAllLinks.
	parent ifNotNil: [ parent remove: self ]
	
]

{ #category : '*MooseIDE-Roassal-ButterflyMap' }
HNode >> remove: anHNode [

	children remove: anHNode
	
]

{ #category : '*MooseIDE-Roassal-ButterflyMap' }
HNode >> removeAllLinks [

	self allDependencies do: [ :link | 
		link to removeLink: link.
		link from removeLink: link ]
]
