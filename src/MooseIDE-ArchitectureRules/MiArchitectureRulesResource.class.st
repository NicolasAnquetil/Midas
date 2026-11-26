"
I build the architecture rules of MooseIDE once per test run: importing the MooseIDE packages into a Famix model takes some 20 seconds.

## Collaborators & Context
- `MiArchitectureRules`: what I build (`#rules`), on the code of the image when the tests start.
- `MiArchitectureRulesTest`: my user (`#resources`).

## Assumptions & Invariants
- Rebuilt on each test run (TestResource): the model is never older than the run.

## Main API
- `MiArchitectureRulesResource current rules`

"
Class {
	#name : 'MiArchitectureRulesResource',
	#superclass : 'TestResource',
	#instVars : [
		'rules'
	],
	#category : 'MooseIDE-ArchitectureRules-Tests',
	#package : 'MooseIDE-ArchitectureRules',
	#tag : 'Tests'
}

{ #category : 'accessing' }
MiArchitectureRulesResource >> rules [

	^ rules
]

{ #category : 'running' }
MiArchitectureRulesResource >> setUp [

	super setUp.
	rules := MiArchitectureRules new
		         buildModel;
		         yourself
]

{ #category : 'running' }
MiArchitectureRulesResource >> tearDown [

	rules := nil.
	super tearDown
]
