"
Stands for a GLSPServer in GLSPDSMBrowserTest: keeps the actions sent to the client; once closed, fails as a closed connection does.
"
Class {
	#name : 'GLSPDSMTestServer',
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
GLSPDSMTestServer >> close [

	closed := true
]

{ #category : 'accessing' }
GLSPDSMTestServer >> sendAction: anAction toClient: aClientId [

	closed == true ifTrue: [ ConnectionClosed signal: 'connection closed while sending data' ].
	self sentActions add: anAction
]

{ #category : 'accessing' }
GLSPDSMTestServer >> sentActions [

	^ sentActions ifNil: [ sentActions := OrderedCollection new ]
]
