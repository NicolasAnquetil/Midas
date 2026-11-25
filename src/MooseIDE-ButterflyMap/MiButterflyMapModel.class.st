"
I am the model of the butterfly map browsers, the Roassal one (`MiButterflyMapBrowser`) and the Bloc one (`MiButterflyMapBrowserBl`): the central entity, and the settings that say what is around it, as queries: its children (inside its box), its clients (on the left) and its providers (on the right).

## Collaborators & Context
- `browser`: told to draw the map again (`#runVisualization`) when the central entity or the settings change.
- `MiButterflyMapSettingsConfiguration`: the settings (`#currentConfiguration`, `#updateFromConfiguration:`). The default queries come from the application (`#defaultClientsQuery`, `#defaultProvidersQuery`).
- `MiButterflyMapBuilder` (Roassal) and `MiButterflyBlTree` (Bloc) ask me the children, clients and providers of an entity.

## Assumptions & Invariants
- `browser` must be set before the central entity: setting it draws the map.
- `selectedEntities` is only set by the Bloc map (the selection in the map); `#miSelectedItem` answers it, the central entity if it is empty.

## Main API
- `#currentEntity:`, `#currentEntity`, `#entities` (the central entity, in a collection).
- `#childrenFor:`, `#leftEntitiesFor:`, `#rightEntitiesFor:`: what is around an entity.
- `#selectedEntities:`, `#miSelectedItem`.

"
Class {
	#name : 'MiButterflyMapModel',
	#superclass : 'MiAbstractModel',
	#instVars : [
		'currentEntity',
		'childrenQuery',
		'clientsQuery',
		'providersQuery',
		'selectedEntities'
	],
	#category : 'MooseIDE-ButterflyMap-Model',
	#package : 'MooseIDE-ButterflyMap',
	#tag : 'Model'
}

{ #category : 'computing' }
MiButterflyMapModel >> childrenFor: anEntity [

	^ childrenQuery runOn: anEntity asMooseGroup
]

{ #category : 'settings management' }
MiButterflyMapModel >> currentConfiguration [

	^ MiButterflyMapSettingsConfiguration new
		  childrenQuery: childrenQuery;
		  clientsQuery: clientsQuery;
		  providersQuery: providersQuery;
		  yourself
]

{ #category : 'accessing' }
MiButterflyMapModel >> currentEntity [

	^ currentEntity
]

{ #category : 'accessing' }
MiButterflyMapModel >> currentEntity: anObject [

	currentEntity := anObject.
	browser runVisualization
]

{ #category : 'settings management' }
MiButterflyMapModel >> defaultConfiguration [

	^ MiButterflyMapSettingsConfiguration new
		  childrenQuery: self defaultChildrenQuery;
		  clientsQuery: self currentApplication defaultClientsQuery;
		  providersQuery: self currentApplication defaultProvidersQuery;
		  yourself
]

{ #category : 'accessing' }
MiButterflyMapModel >> entities [
	"should probably return all entities displayed and not only the central one"
	^self currentEntity
		ifNil: [ #() ]
		ifNotNil: [ :entity | { entity } ]
]

{ #category : 'testing' }
MiButterflyMapModel >> hasSettings [

	^ true
]

{ #category : 'initialization' }
MiButterflyMapModel >> initializeSettings [

	childrenQuery := self defaultChildrenQuery.
	clientsQuery := self currentApplication defaultClientsQuery.
	providersQuery := self currentApplication defaultProvidersQuery
]

{ #category : 'computing' }
MiButterflyMapModel >> leftEntitiesFor: anEntity [

	^ clientsQuery runOn: anEntity asMooseGroup
]

{ #category : 'accessing' }
MiButterflyMapModel >> miSelectedItem [
	"The entities selected in the map, the central entity if none is selected"

	^ self selectedEntities ifEmpty: [ self entities ]
]

{ #category : 'computing' }
MiButterflyMapModel >> rightEntitiesFor: anEntity [

	^ providersQuery runOn: anEntity asMooseGroup
]

{ #category : 'accessing' }
MiButterflyMapModel >> selectedEntities [
	"The entities selected in the map, empty if none"

	^ selectedEntities ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
MiButterflyMapModel >> selectedEntities: aCollection [
	"Told by the map when its selection changes"

	selectedEntities := aCollection
]

{ #category : 'settings management' }
MiButterflyMapModel >> settingsPresenterExtent [

	^ 300 @ 250
]

{ #category : 'settings management' }
MiButterflyMapModel >> updateFromConfiguration: aConfiguration [

	childrenQuery := aConfiguration childrenQuery.
	clientsQuery := aConfiguration clientsQuery.
	providersQuery := aConfiguration providersQuery.

	browser runVisualization
]
