Class {
	#name : 'FeatureEnvyDetector',
	#superclass : 'Object',
	#instVars : [
		'philums'
	],
	#category : 'MooseIDE-CriticBrowser',
	#package : 'MooseIDE-CriticBrowser'
}

{ #category : 'running' }
FeatureEnvyDetector >> featureEnvy: aMethod [

	| allProviders providersByPhilum longer |
	
	allProviders := self getProviders: aMethod.

	self philums: allProviders keys for: aMethod parentType.

	providersByPhilum := Dictionary new.
	allProviders associationsDo: [ :assoc || philo |
		philo := philums at: assoc key.
		(providersByPhilum at: philo ifAbsentPut: OrderedCollection new)
			add: assoc value.
	].

	longer := providersByPhilum at: aMethod parentType ifAbsent: [#()].
	^providersByPhilum keys anySatisfy: [ :philo | (providersByPhilum at: philo) size > longer size ].

]

{ #category : 'running' }
FeatureEnvyDetector >> getProviders: aMethod [

	| providers |
	providers := (((aMethod queryOutgoing: FamixTInvocation) , (aMethod queryOutgoing: FamixTAccess))
		asOrderedCollection
		groupedBy: [ :asso | self providerClass: asso ]).

	providers removeKey: nil ifAbsent: [  ].
	^providers
]

{ #category : 'running' }
FeatureEnvyDetector >> hasSub: aClass in: collection [

	^collection
		detect: [ :assoc | assoc value includes: aClass ]
		ifNone: [ nil ]
]

{ #category : 'running' }
FeatureEnvyDetector >> orderedHierarchies: classes for: firstClass [
	
	^(classes asArray collect: [ :c | c -> c superclassHierarchy ])
		sort: [ :a :b | 
			(a key = firstClass) 
				ifTrue: [ true ]
				ifFalse: [
					(b key = firstClass)
						ifTrue: [ false ]
						ifFalse: [ a value size > b value size ]
				]
		]
]

{ #category : 'running' }
FeatureEnvyDetector >> philums: classes for: firstClass [

	| hierarchies classesDone |
	hierarchies := self orderedHierarchies: classes for: firstClass.
	
	classesDone := OrderedCollection new.
	philums := Dictionary new: hierarchies  size.

	hierarchies do: [ :assoc |
		(self hasSub: assoc key in: classesDone)
			ifNil: [ philums at: assoc key put: assoc key ]
			ifNotNil: [ :foundAssoc | philums at: assoc key put: foundAssoc key ].
		classesDone add: assoc
	]
	
]

{ #category : 'running' }
FeatureEnvyDetector >> providerClass: asso [

	| parents |
	parents := (asso target isCollection 
		ifTrue: [ asso target anyOne ]
		ifFalse: [ asso target ])

		containersOfType: FamixJavaClass.

	^parents ifEmpty: [ nil ] ifNotEmpty: [ parents anyOne ]
]

{ #category : 'running' }
FeatureEnvyDetector >> runOn: methods [

	^methods select: [ :mth |
		mth isConstructor not and: [self featureEnvy: mth] ]
]
