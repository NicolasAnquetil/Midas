Class {
	#name : 'MiSystemComplexityBrowserTest',
	#superclass : 'MiAbstractBrowserTest',
	#category : 'MooseIDE-Roassal-SystemComplexity-Tests',
	#package : 'MooseIDE-Roassal-SystemComplexity',
	#tag : 'Tests'
}

{ #category : 'running' }
MiSystemComplexityBrowserTest >> browserClass [

	^ MiSystemComplexityBrowser
]

{ #category : 'running' }
MiSystemComplexityBrowserTest >> defaultEntityToSelect [

	^ MooseGroup with: super defaultEntityToSelect
]

{ #category : 'tests' }
MiSystemComplexityBrowserTest >> testCanTagEntities [
	self deny: browser canTagEntities 
]

{ #category : 'tests' }
MiSystemComplexityBrowserTest >> testSettingsAction [

	self assert: browser hasSettings
]
