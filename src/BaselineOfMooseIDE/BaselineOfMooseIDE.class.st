Class {
	#name : 'BaselineOfMooseIDE',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfMooseIDE',
	#package : 'BaselineOfMooseIDE'
}

{ #category : 'baselines' }
BaselineOfMooseIDE >> baseline: spec [

	<baseline>
	spec for: #common do: [
			self defineDependencies: spec.
			self definePackages: spec.
			self defineGroups: spec.

			spec for: #NoFamix do: [
					self defineMooseDependencies: spec.
					self definePackagesWhenNoFamix: spec ].

			spec postLoadDoIt: #registerCustomTools ]
]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> blocAndToplo: spec [

	spec
		baseline: 'Bloc'
		with: [ spec repository: 'github://pharo-graphics/Bloc:v3.0.0/src' ].
	"Toplo v0.11.0 is the version built on Bloc v3.0.0"
	spec
		baseline: 'Toplo'
		with: [ spec repository: 'github://pharo-graphics/Toplo:v0.11.0/src' ]
]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> classBlueprint: spec [

	spec
		baseline: 'ClassBlueprint'
		with: [
		spec repository: 'github://moosetechnology/ClassBlueprint/src' ]
]

{ #category : 'accessing' }
BaselineOfMooseIDE >> customProjectAttributes [

	'BaselineOfFamix' asPackageIfAbsent: [ ^ #( #NoFamix ) ].
	^ #( #WithFamix )

]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> defineDependencies: spec [

	self labelContractor: spec.
	self roassalExporters: spec.
	self hierarchicalVisualizations: spec.
	self pharoAIHierachicalClustering: spec.
	self interactiveNotebook: spec.
	self classBlueprint: spec.
	self blocAndToplo: spec.

	spec for: #WithFamix do: [ self famixQueries: spec ]
]

{ #category : 'groups' }
BaselineOfMooseIDE >> defineGroups: spec [
	"RoassalFrontEnd and BlocFrontEnd (not Roassal and Bloc: Bloc is the name of a dependency) each load one front-end (MiRoassalFrontEnd, MiBlocFrontEnd) and the packages that do not need the other one.
	The drawing code of each front-end, browsers included, is in its own packages (MooseIDE-Roassal-<tool>, MooseIDE-Bloc-<tool>, which require MooseIDE-Roassal or MooseIDE-Bloc), the models are shared (MooseIDE-<tool>).
	All the tools are split this way except the co-usage map, whose model opens a settings dialog made of Roassal sliders: its browser is still in MooseIDE-Roassal. BlocFrontEnd still loads Roassal (through MooseIDE-Visualization, required by MooseIDE-Tagging, MooseIDE-Famix and MooseIDE-CoUsageMap).
	Most test packages need MooseIDE-Tests, hence the Roassal browsers: they are in RoassalFrontEnd only. The tests of the front-end packages are in a Tests tag of these packages (the MooseIDE-Bloc-<tool> tests are subclasses of the tests of the Roassal maps, which need MooseIDE-Tests, so for now loading a Bloc map loads its Roassal version too)."

	spec
		group: 'CriticBrowser-Metamodel'
		with:
			#( 'Famix-CriticBrowser-Entities' 'Famix-CriticBrowser-ManualEntities'
			   'Famix-CriticBrowser-Generator' 'Famix-CriticBrowser-Tests' ) ;
		group: 'bulkedit'
		with: #( 'MooseIDE-BulkEditor' );
		group: 'RoassalFrontEnd'
		with: #(
			'MooseIDE-Core'
			'MooseIDE-Visualization'
			'MooseIDE-DeadCode'
			'MooseIDE-DSM'
			'MooseIDE-DistributionMap'
			'MooseIDE-HeatMap'
			'MooseIDE-AttributedText'
			'MooseIDE-Famix'
			'MooseIDE-Meta'
			'MooseIDE-Tagging'
			'MooseIDE-ArchitecturalMap'
			'MooseIDE-Roassal-ArchitecturalMap'
			'MooseIDE-CoUsageMap'
			'MooseIDE-Export'
			'MooseIDE-Duplication'
			'MooseIDE-ButterflyMap'
			'MooseIDE-QueriesDashboard'
			'MooseIDE-LayerVisualization'
			'MooseIDE-ClassBlueprint'
			'MooseIDE-Spotter'
			'MooseIDE-Core-Reporter'
			'MooseIDE-Spotter-Tests'
			'MooseIDE-BulkEditor'
			'MooseIDE-Github-Importer'
			'MooseIDE-Github-Importer-Tests'
			'Famix-CriticBrowser-Generator'
			'Famix-CriticBrowser-ManualEntities'
			'Famix-CriticBrowser-Entities'
			'Famix-CriticBrowser-Tests'
			'MooseIDE-CriticBrowser'
			'MooseIDE-NewTools'
			'MooseIDE-Roassal-ButterflyMap'
			'MooseIDE-Roassal'
			'MooseIDE-Roassal-ClassBlueprint'
			'MooseIDE-Roassal-DistributionMap'
			'MooseIDE-Roassal-DSM'
			'MooseIDE-Roassal-HeatMap'
			'MooseIDE-Roassal-LayerVisualization'
			'MooseIDE-Roassal-QueriesDashboard'
			'MooseIDE-Roassal-UML'
			'MooseIDE-Roassal-MetaBrowser'
			'MooseIDE-Roassal-SystemComplexity'
			'MooseIDE-Tests'
			'MooseIDE-CriticBrowser-Tests'
			'MooseIDE-DeadCode-Tests'
			'MooseIDE-Tagging-Tests'
			'MooseIDE-CoUsageMap-Tests'
			'MooseIDE-ButterflyMap-Tests'
			'MooseIDE-NewTools-Tests'
			'MooseIDE-QueriesBrowser'
			'MooseIDE-WelcomeBrowser'
			'MooseIDE-QueriesBrowser-Tests' );
		group: 'BlocFrontEnd'
		with: #(
			'MooseIDE-Core'
			'MooseIDE-Visualization'
			'MooseIDE-Visualization-Bloc'
			'MooseIDE-DeadCode'
			'MooseIDE-DSM'
			'MooseIDE-DistributionMap'
			'MooseIDE-HeatMap'
			'MooseIDE-AttributedText'
			'MooseIDE-Famix'
			'MooseIDE-Meta'
			'MooseIDE-Tagging'
			'MooseIDE-ArchitecturalMap'
			'MooseIDE-Bloc-ArchitecturalMap'
			'MooseIDE-CoUsageMap'
			'MooseIDE-Export'
			'MooseIDE-Duplication'
			'MooseIDE-ButterflyMap'
			'MooseIDE-Bloc-ButterflyMap'
			'MooseIDE-QueriesDashboard'
			'MooseIDE-LayerVisualization'
			'MooseIDE-ClassBlueprint'
			'MooseIDE-Spotter'
			'MooseIDE-Core-Reporter'
			'MooseIDE-Spotter-Tests'
			'MooseIDE-BulkEditor'
			'MooseIDE-Github-Importer'
			'MooseIDE-Github-Importer-Tests'
			'Famix-CriticBrowser-Generator'
			'Famix-CriticBrowser-ManualEntities'
			'Famix-CriticBrowser-Entities'
			'Famix-CriticBrowser-Tests'
			'MooseIDE-CriticBrowser'
			'MooseIDE-NewTools'
			'MooseIDE-Bloc'
			'MooseIDE-QueriesBrowser'
			'MooseIDE-WelcomeBrowser' )
]

{ #category : 'packages' }
BaselineOfMooseIDE >> defineMooseCriticsPackages: spec [

	spec
		package: 'MooseIDE-CriticBrowser' with: [ spec requires: #( 'MooseIDE-Core' 'Famix-CriticBrowser-Entities' ) ];
		package: 'MooseIDE-CriticBrowser-Tests' with: [ spec requires: #( 'MooseIDE-Tests' 'MooseIDE-CriticBrowser' ) ];
		
		package: 'Famix-CriticBrowser-ManualEntities' with: [ spec requires: #( 'FamixQueries' ) ];
		package: 'Famix-CriticBrowser-Entities' with: [ spec requires: #('Famix-CriticBrowser-ManualEntities') ];
		package: 'Famix-CriticBrowser-Generator';
		
		package: 'Famix-CriticBrowser-Tests' with: [ spec requires: 'Famix-CriticBrowser-Entities' ]
]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> defineMooseDependencies: spec [

	self famix: spec.
	self famixTagging: spec.
	self famixReplication: spec.
	self famixQueries: spec
]

{ #category : 'packages' }
BaselineOfMooseIDE >> definePackages: spec [

	spec
		package: 'MooseIDE-Core' with: [ spec requires: #( 'LabelContractor' 'RoassalExporters' ) ];
		package: 'MooseIDE-WelcomeBrowser'
		with: [ spec requires: #( 'MooseIDE-Core' 'MooseIDE-Meta' 'MooseIDE-CoUsageMap' 'MooseIDE-NewTools' 'MooseIDE-QueriesBrowser' ) ];
		package: 'MooseIDE-Visualization' with: [ spec requires: #( 'MooseIDE-Core' 'HierarchicalVisualizations' ) ];
		package: 'MooseIDE-Meta' with: [ spec requires: #( 'MooseIDE-Core' 'MooseIDE-Famix' ) ];
		package: 'MooseIDE-ArchitecturalMap' with: [ spec requires: #( 'MooseIDE-Core' 'MooseIDE-Tagging' ) ];
		package: 'MooseIDE-Roassal-ArchitecturalMap'
		with: [ spec requires: #( 'MooseIDE-ArchitecturalMap' 'MooseIDE-Roassal' 'MooseIDE-Tests' ) ];
		package: 'MooseIDE-Visualization-Bloc' with: [ spec requires: #( 'Bloc' 'Toplo' ) ];
		package: 'MooseIDE-Bloc-ArchitecturalMap'
		with: [ spec requires: #( 'MooseIDE-ArchitecturalMap' 'MooseIDE-Visualization-Bloc' 'MooseIDE-Bloc' 'MooseIDE-Roassal-ArchitecturalMap' ) ];
		package: 'MooseIDE-DeadCode' with: [ spec requires: #( 'MooseIDE-Core' ) ];
		package: 'MooseIDE-DeadCode-Tests' with: [ spec requires: #( 'MooseIDE-DeadCode' 'MooseIDE-Tests' ) ];
		package: 'MooseIDE-DSM' with: [ spec requires: #( 'MooseIDE-Core' 'AIHierarchicalClustering' ) ];
		package: 'MooseIDE-DistributionMap' with: [ spec requires: #( 'MooseIDE-Core' 'MooseIDE-Tagging' 'AIHierarchicalClustering' ) ];
		package: 'MooseIDE-HeatMap' with: [ spec requires: #( 'MooseIDE-Core' ) ];
		package: 'MooseIDE-Tests' with: [
				spec requires:
						#( 'MooseIDE-Visualization' 'MooseIDE-Roassal' ) ];
		package: 'MooseIDE-AttributedText';
		package: 'MooseIDE-Famix' with: [ spec requires: #( 'MooseIDE-Visualization' 'MooseIDE-AttributedText' ) ];
		package: 'MooseIDE-QueriesBrowser' with: [ spec requires: #( 'MooseIDE-Core' 'FamixQueries' ) ];
		package: 'MooseIDE-QueriesBrowser-Tests' with: [ spec requires: #( 'MooseIDE-QueriesBrowser' 'MooseIDE-Tests' ) ];
		package: 'MooseIDE-Tagging' with: [ spec requires: #( 'MooseIDE-Core' 'MooseIDE-Visualization' ) ];
		package: 'MooseIDE-Tagging-Tests' with: [ spec requires: #( 'MooseIDE-Tagging' 'MooseIDE-Tests' ) ];
		package: 'MooseIDE-CoUsageMap' with: [ spec requires: #( 'MooseIDE-Core' 'MooseIDE-Visualization' ) ];
		package: 'MooseIDE-CoUsageMap-Tests' with: [ spec requires: #( 'MooseIDE-CoUsageMap' 'MooseIDE-Tests' 'MooseIDE-Roassal' ) ];
		package: 'MooseIDE-NewTools' with: [ spec requires: #( 'MooseIDE-Meta' 'MooseIDE-Core' 'FamixQueries' ) ];
		package: 'MooseIDE-NewTools-Tests' with: [ spec requires: #( 'MooseIDE-NewTools' 'MooseIDE-Tests' ) ];
		package: 'MooseIDE-Export' with: [ spec requires: #( 'MooseIDE-Core' 'InteractiveNotebook' ) ];
		package: 'MooseIDE-Duplication' with: [ spec requires: #( 'MooseIDE-Core' ) ];
		package: 'MooseIDE-ButterflyMap' with: [ spec requires: #( 'MooseIDE-Core' ) ];
		package: 'MooseIDE-Roassal-ButterflyMap'
		with: [ spec requires: #( 'MooseIDE-ButterflyMap' 'MooseIDE-Roassal' 'MooseIDE-NewTools' 'MooseIDE-Tests' ) ];
		package: 'MooseIDE-ButterflyMap-Tests' with: [ spec requires: #( 'MooseIDE-ButterflyMap' ) ];
		package: 'MooseIDE-Bloc-ButterflyMap'
		with: [ spec requires: #( 'MooseIDE-ButterflyMap' 'MooseIDE-Visualization-Bloc' 'MooseIDE-Bloc' 'MooseIDE-Roassal-ButterflyMap' ) ];
		package: 'MooseIDE-Roassal' with: [ spec requires: #( 'MooseIDE-Visualization' 'MooseIDE-CoUsageMap' ) ];
		package: 'MooseIDE-Roassal-ClassBlueprint' with: [ spec requires: #( 'MooseIDE-ClassBlueprint' 'MooseIDE-Roassal' 'MooseIDE-Tests' ) ];
		package: 'MooseIDE-Roassal-DistributionMap' with: [ spec requires: #( 'MooseIDE-DistributionMap' 'MooseIDE-Roassal' 'MooseIDE-NewTools' 'MooseIDE-Tests' ) ];
		package: 'MooseIDE-Roassal-DSM' with: [ spec requires: #( 'MooseIDE-DSM' 'MooseIDE-Roassal' 'MooseIDE-Tests' ) ];
		package: 'MooseIDE-Roassal-HeatMap' with: [ spec requires: #( 'MooseIDE-HeatMap' 'MooseIDE-Roassal' 'MooseIDE-Tests' ) ];
		package: 'MooseIDE-Roassal-LayerVisualization' with: [ spec requires: #( 'MooseIDE-LayerVisualization' 'MooseIDE-Roassal' ) ];
		package: 'MooseIDE-Roassal-QueriesDashboard' with: [ spec requires: #( 'MooseIDE-QueriesDashboard' 'MooseIDE-Roassal' ) ];
		package: 'MooseIDE-Roassal-UML' with: [ spec requires: #( 'MooseIDE-Famix' 'MooseIDE-Roassal' 'MooseIDE-Tests' ) ];
		package: 'MooseIDE-Roassal-MetaBrowser' with: [ spec requires: #( 'MooseIDE-Meta' 'MooseIDE-Roassal-UML' ) ];
		package: 'MooseIDE-Roassal-SystemComplexity' with: [ spec requires: #( 'MooseIDE-Roassal' 'MooseIDE-Tests' ) ];
		package: 'MooseIDE-Bloc' with: [ spec requires: #( 'MooseIDE-Core' 'MooseIDE-NewTools' ) ];
		package: 'MooseIDE-QueriesDashboard' with: [ spec requires: #( 'MooseIDE-Core' ) ];
		package: 'MooseIDE-LayerVisualization' with: [ spec requires: #( 'MooseIDE-Core' 'MooseIDE-QueriesDashboard' ) ];
		package: 'MooseIDE-ClassBlueprint' with: [ spec requires: #( 'MooseIDE-Core' 'ClassBlueprint' ) ];
		package: 'MooseIDE-Spotter';
		package: 'MooseIDE-Core-Reporter' with: [ spec requires: #( 'MooseIDE-Core' ) ];
		package: 'MooseIDE-Spotter-Tests' with: [ spec requires: #( 'MooseIDE-Spotter' ) ];
		package: 'MooseIDE-BulkEditor';
		package: 'MooseIDE-Github-Importer' with: [ spec requires: #( 'MooseIDE-Meta' ) ];
		package: 'MooseIDE-Github-Importer-Tests' with: [ spec requires: #( 'MooseIDE-Github-Importer' ) ].

	self defineMooseCriticsPackages: spec
]

{ #category : 'packages' }
BaselineOfMooseIDE >> definePackagesWhenNoFamix: spec [

	spec
		package: 'MooseIDE-Core' with: [ spec requires: #( 'Famix' 'FamixTagging' ) ];
		package: 'MooseIDE-Tagging' with: [ spec requires: #( 'FamixTagging' ) ];
		package: 'MooseIDE-CoUsageMap' with: [ spec requires: #( 'FamixTagging' ) ];
		package: 'MooseIDE-Duplication' with: [ spec requires: #( 'FamixReplication' ) ];
		
		package: 'Famix-CriticBrowser-Entities' with: [ spec requires: #( 'Famix') ];
		package: 'Famix-CriticBrowser-Generator' with: [ spec requires: 'Famix' ]
]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> famix: spec [

	spec
		baseline: 'Famix'
		with: [ 
		spec repository: 'github://moosetechnology/Famix:development/src' ]
]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> famixQueries: spec [

	spec
		baseline: 'FamixQueries'
		with: [ spec repository: 'github://moosetechnology/FamixQueries:development' ]
]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> famixReplication: spec [

	spec
		baseline: 'FamixReplication'
		with: [ 
		spec repository: 'github://moosetechnology/FamixReplication' ]
]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> famixTagging: spec [

	spec
		baseline: 'FamixTagging'
		with: [
		spec repository: 'github://moosetechnology/FamixTagging:development/src' ]
]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> hierarchicalVisualizations: spec [

	spec baseline: 'HierarchicalVisualizations' with: [
		spec repository:
			'github://moosetechnology/HierarchicalVisualizations:main/src' ]
]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> interactiveNotebook: spec [

	spec
		baseline: 'InteractiveNotebook'
		with: [ 
		spec repository: 'github://moosetechnology/InteractiveNotebook/src' ]
]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> labelContractor: spec [

	spec
		baseline: 'LabelContractor'
		with: [ 
		spec repository: 'github://moosetechnology/LabelContractor/src' ]
]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> microdown: spec [

	spec for: #( #'pharo11.x' #'pharo10.x' ) do: [
		spec
			baseline: 'Microdown'
			with: [
			spec repository: 'github://pillar-markup/Microdown:master/src' ] ].

	spec for: #( #'pharo12.x' ) do: [
		spec
			baseline: 'Microdown'
			with: [
			spec repository: 'github://pillar-markup/Microdown:Pharo12/src' ] ]
]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> pharoAIHierachicalClustering: spec [

	spec
		baseline: 'AIHierarchicalClustering'
		with: [ 
		spec repository: 'github://pharo-ai/hierarchical-clustering/src' ]
]

{ #category : 'actions' }
BaselineOfMooseIDE >> registerCustomTools [

	self registerShortcuts. "MiPlayground could be absent if we load only a group"
	(Smalltalk classNamed: #MiPlaygroundBrowser) ifNotNil: [ :miPlayground | miPlayground register ].

	Smalltalk at: #MooseIDEWelcomeBrowser ifPresent: [ :mooseWelcome | mooseWelcome register ]
]

{ #category : 'actions' }
BaselineOfMooseIDE >> registerShortcuts [

	(Smalltalk classNamed: #MiShortcutsCategory) ifNotNil: [
		:miShortcutsCategory |
		miShortcutsCategory new installAsGlobalCategory ]
]

{ #category : 'dependencies' }
BaselineOfMooseIDE >> roassalExporters: spec [

	spec
		baseline: 'RoassalExporters'
		with: [ 
		spec repository: 'github://pharo-graphics/RoassalExporters:v1.02/src' ]
]
