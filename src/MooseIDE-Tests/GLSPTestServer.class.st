"
Stands for a GLSPServer in the tests of the GLSP browsers of MooseIDE (GLSPDSMBrowserTest, GLSPArchitecturalMapBrowserTest): keeps the actions sent to the client; once closed, fails as a closed connection does.
"
Class {
	#name : 'GLSPTestServer',
	#superclass : 'Object',
	#instVars : [
		'sentActions',
		'closed'
	],
	#category : 'MooseIDE-Tests-Browsers',
	#package : 'MooseIDE-Tests',
	#tag : 'Browsers'
}

{ #category : 'accessing' }
GLSPTestServer >> close [

	closed := true
]

{ #category : 'accessing' }
GLSPTestServer >> sendAction: anAction toClient: aClientId [

	closed == true ifTrue: [ ConnectionClosed signal: 'connection closed while sending data' ].
	self sentActions add: anAction
]

{ #category : 'accessing' }
GLSPTestServer >> sentActions [

	^ sentActions ifNil: [ sentActions := OrderedCollection new ]
]
