"
I check the organisation of MooseIDE in front-ends (Roassal, Bloc): the DCL rules of `MiArchitectureRules` on a Famix model of the code, and the placement rules that DCL cannot express, on the image itself.

## Collaborators & Context
- `MiArchitectureRules` (through `MiArchitectureRulesResource`): one test per rule, failing on a violating package that is not a known exception, with the violations (source -> target) in the message.
- `MiFrontEnd`, `MiAbstractBrowser class>>#specificFrontEndClass`: the placement tests.

## Assumptions & Invariants
- A known exception that no longer violates its rule fails `#testKnownExceptionsStillViolate`: remove it from `MiArchitectureRules>>#knownExceptions` when the debt is paid.
- Placement rules: a browser of a front-end lives in the package of that front-end or in one of its MooseIDE-<front-end>-<tool> packages; the test classes of these packages are in their Tests tag; each MooseIDE-<front-end>-<tool> package has a model package MooseIDE-<tool>, but for the tools whose model is elsewhere (`#toolsWithModelElsewhere`).

## Main API
- Run the tests; `#rules`.

"
Class {
	#name : 'MiArchitectureRulesTest',
	#superclass : 'TestCase',
	#category : 'MooseIDE-ArchitectureRules-Tests',
	#package : 'MooseIDE-ArchitectureRules',
	#tag : 'Tests'
}

{ #category : 'accessing' }
MiArchitectureRulesTest class >> resources [

	^ { MiArchitectureRulesResource }
]

{ #category : 'helpers' }
MiArchitectureRulesTest >> assertRuleHolds: aRuleSelector [
	"No violating package but the known exceptions"

	| unexpected |
	unexpected := self rules unexpectedViolationsOf: aRuleSelector.
	self assert: unexpected isEmpty description: [
			String streamContents: [ :stream |
					stream
						nextPutAll: aRuleSelector;
						nextPutAll: ' violated by:'.
					unexpected do: [ :each |
							stream
								cr;
								nextPutAll: each key;
								nextPutAll: ': '.
							(each value asArray first: (each value size min: 5))
								do: [ :violation | stream nextPutAll: violation ]
								separatedBy: [ stream nextPutAll: '; ' ] ] ] ]
]

{ #category : 'helpers' }
MiArchitectureRulesTest >> frontEndPackages [
	"The packages of the front-ends in the image"

	^ PackageOrganizer default packages select: [ :each |
		  #( 'MooseIDE-Roassal' 'MooseIDE-Bloc' ) anySatisfy: [ :prefix | each name beginsWith: prefix ] ]
]

{ #category : 'helpers' }
MiArchitectureRulesTest >> rules [

	^ MiArchitectureRulesResource current rules
]

{ #category : 'tests - dependencies' }
MiArchitectureRulesTest >> testBlocMapsReuseTheRoassalTests [

	self assertRuleHolds: #ruleBlocMapsReuseTheRoassalTests
]

{ #category : 'tests - placement' }
MiArchitectureRulesTest >> testBrowsersLiveInTheirFrontEnd [
	"A browser of a front-end is in the package of the front-end or in one of its MooseIDE-<front-end>-<tool> packages"

	MiAbstractBrowser allBrowsers do: [ :browser |
			browser specificFrontEndClass ifNotNil: [ :frontEnd |
					| home |
					home := frontEnd package name.
					self
						assert: (browser package name = home or: [ browser package name beginsWith: home , '-' ])
						description: ('{1} is in {2}, not in a {3} package' format: {
									 browser name.
									 browser package name.
									 home }) ] ]
]

{ #category : 'tests - dependencies' }
MiArchitectureRulesTest >> testEveryRuleIsTested [
	"Each rule #ruleX has its test #testX"

	self rules ruleSelectors do: [ :each |
			self
				assert: (self class includesSelector: ('test' , (each allButFirst: 4)) asSymbol)
				description: ('{1} has no test' format: { each }) ]
]

{ #category : 'tests - dependencies' }
MiArchitectureRulesTest >> testFrontEndBasesIgnoreTheirTools [

	self assertRuleHolds: #ruleFrontEndBasesIgnoreTheirTools
]

{ #category : 'tests - placement' }
MiArchitectureRulesTest >> testFrontEndTestsAreInTheTestsTag [

	self frontEndPackages do: [ :package |
		package definedClasses select: [ :each | each isTestCase ] thenDo: [ :test | self assert: test packageTag name equals: 'Tests' ] ]
]

{ #category : 'tests - dependencies' }
MiArchitectureRulesTest >> testFrontEndsIgnoreEachOther [

	self assertRuleHolds: #ruleFrontEndsIgnoreEachOther
]

{ #category : 'tests - dependencies' }
MiArchitectureRulesTest >> testKnownExceptionsStillViolate [
	"A paid debt must leave the list of known exceptions"

	self rules ruleSelectors do: [ :rule |
			| violating |
			violating := self rules violatingPackagesOf: rule.
			(self rules knownExceptionsOf: rule) keysDo: [ :package |
					self
						assert: (violating includesKey: package)
						description: ('{1} no longer violates {2}: remove it from MiArchitectureRules>>#knownExceptions' format: {
									 package.
									 rule }) ] ]
]

{ #category : 'tests - dependencies' }
MiArchitectureRulesTest >> testModelsIgnoreTheFrontEnds [

	self assertRuleHolds: #ruleModelsIgnoreTheFrontEnds
]

{ #category : 'tests - dependencies' }
MiArchitectureRulesTest >> testModulesAreNotEmpty [
	"An empty module would make its rules pass for nothing (a renamed package, a changed regex)"

	#( #roassalLibrary #blocLibrary #roassalBase #roassalTools #roassalFrontEndProduction #blocBase #blocTools #blocFrontEndProduction
	   #models #tests #productionCode ) do: [ :each | self denyEmpty: (self rules perform: each) memberEntities ]
]

{ #category : 'tests - dependencies' }
MiArchitectureRulesTest >> testOnlyTheBlocFrontEndUsesBloc [

	self assertRuleHolds: #ruleOnlyTheBlocFrontEndUsesBloc
]

{ #category : 'tests - dependencies' }
MiArchitectureRulesTest >> testOnlyTheRoassalFrontEndUsesRoassal [

	self assertRuleHolds: #ruleOnlyTheRoassalFrontEndUsesRoassal
]

{ #category : 'tests - dependencies' }
MiArchitectureRulesTest >> testProductionCodeIgnoresTests [

	self assertRuleHolds: #ruleProductionCodeIgnoresTests
]

{ #category : 'tests - dependencies' }
MiArchitectureRulesTest >> testToolPackagesAreIndependent [

	self assertRuleHolds: #ruleToolPackagesAreIndependent
]

{ #category : 'tests - placement' }
MiArchitectureRulesTest >> testToolPackagesHaveAModel [
	"Each MooseIDE-<front-end>-<tool> package has a MooseIDE-<tool> package for its model, but the tools whose model is elsewhere"

	self frontEndPackages do: [ :package |
			| parts tool |
			parts := package name substrings: '-'.
			parts size > 2 ifTrue: [
					tool := '-' join: (parts allButFirst: 2).
					(self toolsWithModelElsewhere includesKey: tool) ifFalse: [
							self
								assert: (PackageOrganizer default hasPackage: 'MooseIDE-' , tool)
								description: ('{1} has no model package MooseIDE-{2}' format: {
											 package name.
											 tool }) ] ] ]
]

{ #category : 'helpers' }
MiArchitectureRulesTest >> toolsWithModelElsewhere [
	"Tools whose model is not in a MooseIDE-<tool> package"

	^ Dictionary new
		  at: 'UML' put: 'MooseIDE-Famix';
		  at: 'MetaBrowser' put: 'MooseIDE-Meta';
		  at: 'SystemComplexity' put: 'none: the model draws on Roassal hierarchical nodes';
		  yourself
]
