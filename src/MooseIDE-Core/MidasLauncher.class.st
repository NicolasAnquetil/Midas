Class {
	#name : #MidasLauncher,
	#superclass : #SpPresenter,
	#instVars : [
		'iconThem',
		'toolBar'
	],
	#category : #'MooseIDE-Core-Overview'
}

{ #category : #initialization }
MidasLauncher >> commands [
	^{
	'import' -> 'Load models' .
	'queries' -> 'Query model' .
	'inspector' -> 'Inspect entities' .
	'tagging' -> 'Create tags and tag entities' .
	'architecture' -> 'Architectural Map' .
	'distribution' -> 'Distribution Map' .
	'logger' -> 'Logged results'
	}

]

{ #category : #initialization }
MidasLauncher >> defaultIconTheme [
	^ThemeIcons new
		name: 'bwIcons' , (self iconSize asString) ;
		loadIconsFromUrl ;
		yourself.
]

{ #category : #initialization }
MidasLauncher >> iconNamed: name [
	^iconThem iconNamed: name
]

{ #category : #initialization }
MidasLauncher >> iconSize [
	^32
]

{ #category : #initialization }
MidasLauncher >> initialize [
	iconThem := self defaultIconTheme.
	super initialize.
]

{ #category : #initialization }
MidasLauncher >> initializeLayout [
	| tmpLayout |
	tmpLayout := SpBoxLayout newVertical.
	toolBar do: [ :btn |
		tmpLayout add: btn height: self iconSize 
	].
	self layout: tmpLayout 


]

{ #category : #initialization }
MidasLauncher >> initializePresenters [ 
	toolBar := self commands collect: [ :cmd |
		self newButton
			"label: cmd key;"
			icon: (self iconNamed: cmd key);
			help: cmd value ;
			action:  [ self inform: cmd key ] ;
			yourself
	].
	self initializeLayout

]

{ #category : #initialization }
MidasLauncher >> initializeWindow: aWindowPresenter [
	aWindowPresenter
		initialExtent: (self iconSize + 5) @ (toolBar size * (self iconSize + 5))
]
