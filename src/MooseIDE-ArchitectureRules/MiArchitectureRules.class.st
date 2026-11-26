"
I am the architecture rules of MooseIDE about its front-ends (Roassal, Bloc): DCL constraints (ArchitecturalConstraints, github.com/moosetechnology/DependencyConstraint) checked on a Famix model of the MooseIDE packages.

## Collaborators & Context
- `FamixStPharoImporterTask`: imports the MooseIDE-* packages of the image into my model (`#buildModel`). The library classes they use (Roassal, Bloc...) come in as stubs, with their package: that is enough to put them in modules.
- `DCLModuleExplicit`: my modules, made from package names (`#modulePackages:except:`), with the classes, their methods and the extension methods of these packages. DCL has no module on package names.
- DCL constraints (`cannot`, `onlyCan`, `must`, with `reference:` and `inherit:`; `invoke:` is not reliable in Smalltalk, without types).
- `MiArchitectureRulesTest`: checks each rule through `MiArchitectureRulesResource`, which builds me once per test run.

## Assumptions & Invariants
- The organisation checked, also described in BaselineOfMooseIDE>>#defineGroups:
  - models (MooseIDE-<tool>) know no graphics library and no front-end;
  - the drawing code of a front-end is in MooseIDE-Roassal-<tool> / MooseIDE-Bloc-<tool>, which require the base of the front-end (MooseIDE-Roassal and MooseIDE-Visualization, MooseIDE-Bloc and MooseIDE-Visualization-Bloc), never the other way round;
  - the front-ends do not know each other, the tool packages of a front-end do not know each other;
  - production code does not depend on tests.
- A rule is a selector of my 'rules' protocol answering a collection of DCL constraints. Its known exceptions (`#knownExceptionsOf:`) are the packages allowed to violate it for now, each with the reason: the debt to pay. Test classes are in the modules of their packages, except for the rules about tests.
- I am rebuilt on each test run: no cache outside the resource.

## Main API
- `MiArchitectureRules new buildModel; yourself`
- `#ruleSelectors`, `#violationsOf: aRuleSelector` (the FamixCBViolations), `#violatingPackagesOf:`, `#unexpectedViolationsOf:` (outside the known exceptions), `#knownExceptionsOf:`.
- Modules: `#roassalLibrary`, `#blocLibrary`, `#roassalFrontEnd`, `#blocFrontEnd`, `#models`, `#tests`, `#productionCode`...

"
Class {
	#name : 'MiArchitectureRules',
	#superclass : 'Object',
	#instVars : [
		'model',
		'modules'
	],
	#category : 'MooseIDE-ArchitectureRules-Rules',
	#package : 'MooseIDE-ArchitectureRules',
	#tag : 'Rules'
}

{ #category : 'exceptions' }
MiArchitectureRules >> allowedToolDependencies [
	"Tool packages that may know other tools of their front-end"

	^ Dictionary new
		  at: 'MooseIDE-Roassal-MetaBrowser' put: #( 'MooseIDE-Roassal-UML' );
		  yourself
]

{ #category : 'model' }
MiArchitectureRules >> analysedPackageNames [
	"The packages of MooseIDE, but mine"

	^ (PackageOrganizer default packageNames select: [ :each |
		   (each beginsWith: 'MooseIDE-') and: [ each ~= self class package name ] ]) asArray
]

{ #category : 'modules' }
MiArchitectureRules >> blocBase [
	"The Bloc front-end and the generic Bloc visualization"

	^ self
		  module: 'Bloc front-end base'
		  packages: 'MooseIDE-(Bloc|Visualization-Bloc)'
		  except: nil
		  kind: #all
]

{ #category : 'modules' }
MiArchitectureRules >> blocFrontEnd [

	^ self module: 'Bloc front-end' union: {
			  self blocBase.
			  self blocTools }
]

{ #category : 'modules' }
MiArchitectureRules >> blocFrontEndProduction [

	^ self
		  module: 'Bloc front-end production'
		  packages: 'MooseIDE-(Bloc(-.+)?|Visualization-Bloc)'
		  except: nil
		  kind: #production
]

{ #category : 'modules' }
MiArchitectureRules >> blocLibrary [

	^ self
		  module: 'Bloc library'
		  packages: '(Bloc|Toplo|Album).*'
		  except: nil
		  kind: #all
]

{ #category : 'modules' }
MiArchitectureRules >> blocTools [

	^ self
		  module: 'Bloc tools'
		  packages: 'MooseIDE-Bloc-.+'
		  except: nil
		  kind: #all
]

{ #category : 'model' }
MiArchitectureRules >> buildModel [
	"Import the MooseIDE packages; the library classes they use come as stubs, with their package"

	| importer |
	model := FamixStModel named: 'MooseIDE architecture'.
	importer := FamixStPharoImporterTask new.
	importer importingContext mergeClassAndMetaclass.
	importer
		model: model;
		addFromPackagesNamed: self analysedPackageNames;
		withoutProgress;
		run.
	modules := Dictionary new
]

{ #category : 'checking' }
MiArchitectureRules >> describe: aFamixAssociation [

	^ '{1} -> {2}' format: {
			  aFamixAssociation source mooseName.
			  (aFamixAssociation target isCollection
				   ifTrue: [ ', ' join: (aFamixAssociation target collect: #mooseName) ]
				   ifFalse: [ aFamixAssociation target mooseName ]) }
]

{ #category : 'private' }
MiArchitectureRules >> entitiesOfPackagesMatching: aRegexString except: anotherRegexStringOrNil kind: aSymbol [
	"The classes, their methods and the extension methods of the packages whose name matches aRegexString and not anotherRegexStringOrNil.
	 aSymbol: #all, #tests (the test classes, and the classes of the test packages) or #production (the others, with the extension methods)"

	| regex except packages classes entities |
	regex := aRegexString asRegex.
	except := anotherRegexStringOrNil ifNotNil: [ :string | string asRegex ].
	packages := IdentitySet withAll:
		            (model allPackages select: [ :each |
			             (regex matches: each name) and: [ except isNil or: [ (except matches: each name) not ] ] ]).
	classes := model allClasses select: [ :each |
		           (packages includes: each parentPackage) and: [ aSymbol = #all or: [ (self isTestClass: each) = (aSymbol = #tests) ] ] ].
	entities := IdentitySet new.
	classes do: [ :each |
			entities add: each.
			entities addAll: each methods ].
	aSymbol = #tests ifFalse: [ packages do: [ :each | entities addAll: each extensionMethods ] ].
	^ entities
]

{ #category : 'modules' }
MiArchitectureRules >> frontEnds [

	^ self module: 'front-ends' union: {
			  self roassalFrontEnd.
			  self blocFrontEnd }
]

{ #category : 'private' }
MiArchitectureRules >> isTestClass: aFamixClass [
	"A test, or a class of a test package (its fixtures)"

	^ aFamixClass isTestCase or: [
			  aFamixClass parentPackage isNotNil and: [
					  | name |
					  name := aFamixClass parentPackage name.
					  (name endsWith: '-Tests') or: [ name = 'MooseIDE-Tests' ] ] ]
]

{ #category : 'exceptions' }
MiArchitectureRules >> knownExceptions [
	"rule selector -> (package name -> reason)"

	^ Dictionary new
		  at: #ruleOnlyTheRoassalFrontEndUsesRoassal put: (Dictionary new
				   at: 'MooseIDE-Core' put: 'extension methods drawing tags on HDefaultStyleWithTags and HSimpleVisualizationBuilder';
				   at: 'MooseIDE-AttributedText' put: 'RSAttributedText and its emphasis attributes are Roassal shapes';
				   at: 'MooseIDE-Famix' put: 'MiSourceTextRoassalRenderer draws the source text with Roassal';
				   at: 'MooseIDE-CoUsageMap' put: 'not split yet: its model opens a settings dialog made of Roassal sliders';
				   at: 'MooseIDE-CoUsageMap-Tests' put: 'tests of the co-usage map, not split yet';
				   at: 'MooseIDE-Tests' put: 'HMiPropagateMenuItemTest tests a menu item of MooseIDE-Visualization with Hierarchical nodes';
				   yourself);
		  at: #ruleModelsIgnoreTheFrontEnds put: (Dictionary new
			   at: 'MooseIDE-Famix' put: 'MiSourceTextRoassalRenderer is a MiAbstractVisualization';
			   at: 'MooseIDE-CoUsageMap' put: 'not split yet: MiCoUsageMapVisualization is a MiAbstractVisualization';
			   yourself);
		  yourself
]

{ #category : 'exceptions' }
MiArchitectureRules >> knownExceptionsOf: aRuleSelector [
	"The packages allowed to violate a rule for now, with the reason: the debt to pay"

	^ self knownExceptions at: aRuleSelector ifAbsent: [ Dictionary new ]
]

{ #category : 'model' }
MiArchitectureRules >> model [

	^ model
]

{ #category : 'modules' }
MiArchitectureRules >> models [
	"The packages of the tools and of the application, without their tests: everything but the front-ends"

	^ self
		  module: 'models'
		  packages: 'MooseIDE-.+'
		  except: 'MooseIDE-(Roassal|Bloc|Visualization)(-.+)?|.+-Tests|MooseIDE-Tests'
		  kind: #production
]

{ #category : 'private' }
MiArchitectureRules >> module: aString packages: aRegexString except: anotherRegexStringOrNil kind: aSymbol [

	^ modules at: aString ifAbsentPut: [
			  DCLModuleExplicit new
				  name: aString;
				  model: model;
				  memberEntities: (self entitiesOfPackagesMatching: aRegexString except: anotherRegexStringOrNil kind: aSymbol);
				  yourself ]
]

{ #category : 'private' }
MiArchitectureRules >> module: aString union: aCollectionOfModules [

	^ modules at: aString ifAbsentPut: [
			  DCLModuleExplicit new
				  name: aString;
				  model: model;
				  memberEntities: (aCollectionOfModules inject: IdentitySet new into: [ :all :each |
								   all
									   addAll: each memberEntities;
									   yourself ]);
				  yourself ]
]

{ #category : 'private' }
MiArchitectureRules >> modulePackage: aPackageName kind: aSymbol [
	"The module of one package (package names have no regex special character)"

	^ self
		  module: ('{1} {2}' format: {
					   aPackageName.
					   aSymbol })
		  packages: aPackageName
		  except: nil
		  kind: aSymbol
]

{ #category : 'checking' }
MiArchitectureRules >> packageNameOf: aFamixEntity [

	^ (aFamixEntity isMethod
		   ifTrue: [ aFamixEntity parentPackage ifNil: [ aFamixEntity parentType parentPackage ] ]
		   ifFalse: [ aFamixEntity parentPackage ]) ifNil: [ '?' ] ifNotNil: [ :package | package name ]
]

{ #category : 'modules' }
MiArchitectureRules >> productionCode [

	^ self
		  module: 'production code'
		  packages: 'MooseIDE-.+'
		  except: nil
		  kind: #production
]

{ #category : 'modules' }
MiArchitectureRules >> roassalBase [
	"The Roassal front-end and the helpers of the Roassal visualizations"

	^ self
		  module: 'Roassal front-end base'
		  packages: 'MooseIDE-(Roassal|Visualization)'
		  except: nil
		  kind: #all
]

{ #category : 'modules' }
MiArchitectureRules >> roassalFrontEnd [

	^ self module: 'Roassal front-end' union: {
			  self roassalBase.
			  self roassalTools }
]

{ #category : 'modules' }
MiArchitectureRules >> roassalFrontEndProduction [

	^ self
		  module: 'Roassal front-end production'
		  packages: 'MooseIDE-(Roassal|Visualization)(-.+)?'
		  except: 'MooseIDE-Visualization-Bloc'
		  kind: #production
]

{ #category : 'modules' }
MiArchitectureRules >> roassalLibrary [
	"Roassal and the hierarchical visualizations built on it (stubs in my model)"

	^ self
		  module: 'Roassal library'
		  packages: '(Roassal|Hierarchical).*'
		  except: nil
		  kind: #all
]

{ #category : 'modules' }
MiArchitectureRules >> roassalTools [

	^ self
		  module: 'Roassal tools'
		  packages: 'MooseIDE-Roassal-.+'
		  except: nil
		  kind: #all
]

{ #category : 'rules' }
MiArchitectureRules >> ruleBlocMapsReuseTheRoassalTests [
	"The tests of a MooseIDE-Bloc-<tool> package subclass those of MooseIDE-Roassal-<tool>, so that both versions of a map pass the same tests"

	^ (self toolPackageNamesOf: 'Bloc') collect: [ :tool |
			  | roassal |
			  roassal := tool copyReplaceAll: 'MooseIDE-Bloc-' with: 'MooseIDE-Roassal-'.
			  ((self modulePackage: tool kind: #tests) must inherit: (self modulePackage: roassal kind: #tests)) description:
				  ('The tests of {1} subclass those of {2}' format: {
						   tool.
						   roassal }) ]
]

{ #category : 'rules' }
MiArchitectureRules >> ruleFrontEndBasesIgnoreTheirTools [
	"The tool packages require the base of their front-end, not the other way round: a front-end knows its browsers through MiAbstractBrowser class>>#specificFrontEndClass"

	^ {
		  ((self roassalBase cannot reference: self roassalTools) description:
			   'MooseIDE-Roassal and MooseIDE-Visualization do not refer to the MooseIDE-Roassal-<tool> packages').
		  ((self roassalBase cannot inherit: self roassalTools) description:
			   'MooseIDE-Roassal and MooseIDE-Visualization do not subclass the MooseIDE-Roassal-<tool> packages').
		  ((self blocBase cannot reference: self blocTools) description:
			   'MooseIDE-Bloc and MooseIDE-Visualization-Bloc do not refer to the MooseIDE-Bloc-<tool> packages').
		  ((self blocBase cannot inherit: self blocTools) description:
			   'MooseIDE-Bloc and MooseIDE-Visualization-Bloc do not subclass the MooseIDE-Bloc-<tool> packages') }
]

{ #category : 'rules' }
MiArchitectureRules >> ruleFrontEndsIgnoreEachOther [
	"Their production code: the tests of a Bloc map reuse those of its Roassal version (#ruleBlocMapsReuseTheRoassalTests)"

	^ {
		  ((self roassalFrontEndProduction cannot reference: self blocFrontEnd) description:
			   'The Roassal front-end does not refer to the Bloc one').
		  ((self roassalFrontEndProduction cannot inherit: self blocFrontEnd) description:
			   'The Roassal front-end does not subclass the Bloc one').
		  ((self blocFrontEndProduction cannot reference: self roassalFrontEnd) description:
			   'The Bloc front-end does not refer to the Roassal one').
		  ((self blocFrontEndProduction cannot inherit: self roassalFrontEnd) description:
			   'The Bloc front-end does not subclass the Roassal one') }
]

{ #category : 'rules' }
MiArchitectureRules >> ruleModelsIgnoreTheFrontEnds [

	^ {
		  ((self models cannot reference: self frontEnds) description: 'A model does not refer to a front-end').
		  ((self models cannot inherit: self frontEnds) description: 'A model does not subclass a front-end class') }
]

{ #category : 'rules' }
MiArchitectureRules >> ruleOnlyTheBlocFrontEndUsesBloc [

	^ {
		  ((self blocFrontEnd onlyCan reference: self blocLibrary) description: 'Only the Bloc front-end refers to Bloc classes').
		  ((self blocFrontEnd onlyCan inherit: self blocLibrary) description: 'Only the Bloc front-end subclasses Bloc classes') }
]

{ #category : 'rules' }
MiArchitectureRules >> ruleOnlyTheRoassalFrontEndUsesRoassal [

	^ {
		  ((self roassalFrontEnd onlyCan reference: self roassalLibrary) description:
			   'Only the Roassal front-end refers to Roassal classes').
		  ((self roassalFrontEnd onlyCan inherit: self roassalLibrary) description:
			   'Only the Roassal front-end subclasses Roassal classes') }
]

{ #category : 'rules' }
MiArchitectureRules >> ruleProductionCodeIgnoresTests [
	"Now that the tests of the front-ends are in a Tests tag of their packages, nothing else keeps them apart"

	^ {
		  ((self productionCode cannot reference: self tests) description: 'Production code does not refer to tests').
		  ((self productionCode cannot inherit: self tests) description: 'Production code does not subclass tests') }
]

{ #category : 'checking' }
MiArchitectureRules >> ruleSelectors [

	^ (self class selectorsInProtocol: 'rules') asArray sort
]

{ #category : 'rules' }
MiArchitectureRules >> ruleToolPackagesAreIndependent [
	"A MooseIDE-<front-end>-<tool> package does not know the other tools of its front-end, but those of #allowedToolDependencies"

	^ #( 'Roassal' 'Bloc' ) flatCollect: [ :frontEnd |
			  | tools |
			  tools := self toolPackageNamesOf: frontEnd.
			  tools flatCollect: [ :tool |
					  | others |
					  others := self
						            module: ('tools other than {1}' format: { tool })
						            union:
							            ((tools copyWithout: tool) \ (self allowedToolDependencies at: tool ifAbsent: [ #(  ) ]) collect: [ :each |
								             self modulePackage: each kind: #all ]).
					  {
						  (((self modulePackage: tool kind: #production) cannot reference: others) description:
							   ('{1} does not refer to the other tools of its front-end' format: { tool })).
						  (((self modulePackage: tool kind: #production) cannot inherit: others) description:
							   ('{1} does not subclass the other tools of its front-end' format: { tool })) } ] ]
]

{ #category : 'modules' }
MiArchitectureRules >> tests [

	^ self
		  module: 'tests'
		  packages: 'MooseIDE-.+'
		  except: nil
		  kind: #tests
]

{ #category : 'private' }
MiArchitectureRules >> toolPackageNamesOf: aFrontEndName [
	"The MooseIDE-<aFrontEndName>-<tool> packages in the model"

	| prefix |
	prefix := 'MooseIDE-{1}-' format: { aFrontEndName }.
	^ (model allPackages
		   collect: [ :each | each name ]
		   thenSelect: [ :each | (each beginsWith: prefix) and: [ (each endsWith: '-Tests') not ] ]) asArray sort
]

{ #category : 'checking' }
MiArchitectureRules >> unexpectedViolationsOf: aRuleSelector [
	"Package name -> violations, for the violating packages that are not known exceptions"

	| known |
	known := self knownExceptionsOf: aRuleSelector.
	^ (self violatingPackagesOf: aRuleSelector) associations reject: [ :each | known includesKey: each key ]
]

{ #category : 'checking' }
MiArchitectureRules >> violatingPackagesOf: aRuleSelector [
	"Package name -> violations of the rule from that package"

	| result |
	result := Dictionary new.
	(self perform: aRuleSelector) do: [ :constraint |
			| violations |
			violations := constraint check asArray.
			(constraint isKindOf: DCLMustConstraint)
				ifTrue: [
						violations ifNotEmpty: [
							(result at: (constraint moduleA name substrings: ' ') first ifAbsentPut: [ OrderedCollection new ]) add:
								constraint description ] ]
				ifFalse: [
						violations do: [ :violation |
								(result at: (self packageNameOf: violation violatingEntity source) ifAbsentPut: [ OrderedCollection new ]) add:
									(self describe: violation violatingEntity) ] ] ].
	^ result
]

{ #category : 'checking' }
MiArchitectureRules >> violationsOf: aRuleSelector [
	"The violations of the DCL constraints of a rule"

	^ (self perform: aRuleSelector) flatCollect: [ :each | each check asArray ]
]
