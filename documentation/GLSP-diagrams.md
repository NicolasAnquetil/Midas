# The MooseIDE GLSP diagrams

Two MooseIDE visualizations are served by the Pharo GLSP server of [Pharo-GLSP](https://github.com/NicolasAnquetil/Pharo-GLSP) and shown by
its [`browser-client/`](https://github.com/NicolasAnquetil/Pharo-GLSP/tree/main/browser-client) in a web browser:

- the **architectural map** (`archmap-diagram`): the root packages of a model, with the dependencies between them;
- the **DSM** (`dsm-diagram`): the dependency structure matrix of these packages; hovering a cell outlines its
  column and its row with a thick border, and for a cell of a cycle shows its whole strongly connected component
  (SCC) in red.

Both are read-only, and both use the MooseIDE models unchanged (`MiArchitecturalMapModel`, `MiDSMBrowserModel`):
on the GLSP side, a *GLSP browser* takes the place of the Spec browser of MooseIDE.

## Where the code is

| What | Where |
|---|---|
| GLSP server (protocol, sessions, actions, GModel) | [Pharo-GLSP](https://github.com/NicolasAnquetil/Pharo-GLSP), `src/` (`GLSP-Server`, ...) |
| Browser client and WebSocket ⇄ TCP bridge | [Pharo-GLSP](https://github.com/NicolasAnquetil/Pharo-GLSP), `browser-client/` |
| The two diagrams | this repository (MooseIDE), for now in the `development` branch of [NicolasAnquetil/Midas](https://github.com/NicolasAnquetil/Midas) |
| — common classes | package `MooseIDE-Visualization`, tag `GLSP` |
| — architectural map | package `MooseIDE-ArchitecturalMap`, tag `GLSP` |
| — DSM | package `MooseIDE-DSM`, tag `GLSP` |
| — tests | package `MooseIDE-Tests`, tag `Browsers`: `GLSPMooseDiagramModuleTest`, `GLSPArchitecturalMapBrowserTest`, `GLSPDSMBrowserTest`, `GLSPDSMVisualizationTest` (with `GLSPTestServer`, a fake server keeping what is sent to the client) |

The MooseIDE baseline declares Pharo-GLSP as the project `GLSP`, loaded by the group `glsp`.

## The classes

The organisation mirrors the one of MooseIDE, where a Spec browser (`MiDSMBrowser`) shows a model
(`MiDSMBrowserModel`) drawn by a Roassal visualization (`MiDSMVisualization`):

| Role | MooseIDE (Spec, Roassal) | GLSP: common | GLSP: architectural map | GLSP: DSM |
|---|---|---|---|---|
| model | MiArchitecturalMap-Model, MiDSMBrowserModel | (unchanged) | | |
| browser: the model's `browser`, receives its callbacks and the client's | MiArchitecturalMap-Browser, MiDSMBrowser | GLSPMooseBrowser | GLSPArchitecturalMap-Browser | GLSPDSMBrowser |
| visualization: draws the model (the GLSP *GModel factory*) | MiArchitecturalMap-Visualization, MiDSMVisualization | (GLSPGModelFactory) | GLSPArchitecturalMap-Visualization | GLSPDSMVisualization |
| diagram module: defines a diagram type for the GLSP server | — | GLSPMooseDiagramModule | GLSPArchitecturalMap-DiagramModule | GLSPDSMDiagramModule |
| storage: required by GLSP, reads nothing, refuses to save | — | GLSPMooseSourceModel-Storage | | |
| custom action sent by the client, and its handler | — | | | GLSPDSMHoverCellAction, GLSPDSMHoverCellAction-Handler |

What each part does:

- **`GLSPMooseDiagramModule`** holds the model, shared by all the clients. For each client session it creates a
  browser (`browserClass`) and sets it as the browser of the model. Its subclasses only say `diagramType`,
  `gmodelFactory` (the visualization) and `browserClass`; the DSM adds its hover handler (`createActionHandlers`),
  the architectural map can also open in a Bloc editor of the image (`openOn:`).
- **`GLSPMooseBrowser`** is one per client session (plus one *without client*, see below). It is
  - the **browser of the model**: the model calls it back (`buildDSM` for the DSM, `runVisualization` for the map,
    `updateToolbar`, `application`); after a change of the model it sends the model again to its client
    (`sendModelToClient`);
  - the **source model of its session**: the visualization draws the model from it (`dsmModel`, `mapModel`);
  - the receiver of the **client's callbacks**: `GLSPDSMBrowser>>hoverCellWithId:`, which keeps the hovered cell
    of its client (its column and row are outlined) and shows its SCC (`showSCC:`, as `MiDSMBrowser`).
- **A browser without client**: MooseIDE models need a browser. `GLSPMooseBrowser class>>modelOn:` builds the model
  with a browser that has no session (its callbacks do nothing), and when a client has gone, its browser gives the
  model a new browser without client (`detachFromModel`).
- The model has **one** browser: with several clients, the last one connected receives the changes made to the
  model in Pharo; each client still has its own highlight, which goes through its own session.

## Running

In Pharo, one GLSP server for both diagrams:

```smalltalk
entities := MooseModel root allModels first allModelPackages.
launcher := GLSPMooseDiagramModule
	serveAll: { GLSPArchitecturalMapDiagramModule on: entities. GLSPDSMDiagramModule on: entities }
	onPort: 5007.
"... later"
launcher stop.
```

One diagram alone: `GLSPDSMDiagramModule serve: entities onPort: 5007`, or `serveModel: aModel onPort: 5007` with a
model built by `GLSPDSMBrowser modelOn: entities` (to keep a hand on it).

In `browser-client/` of Pharo-GLSP: `npm install` once, then `node server.js` (bridge on port 8080 to the GLSP server on 5007), and open
http://localhost:8080/ (architectural map) or http://localhost:8080/?diagram=dsm (DSM).
`node test-bridge.js` or `node test-bridge.js dsm` checks the bridge and the Pharo server without a browser.

## Opening a diagram

The browser page opens a WebSocket on the bridge, which opens one TCP connection to the Pharo server; for each
connection the launcher creates a `GLSPServer` with copies of the diagram modules (they share the model).

```mermaid
sequenceDiagram
    autonumber
    participant Page as Browser page (app.ts)
    participant Bridge as server.js (bridge)
    participant Server as GLSPServer (one per connection)
    participant Module as GLSPDSMDiagramModule
    participant Session as GLSPClientSession
    participant Browser as GLSPDSMBrowser
    participant Model as MiDSMBrowserModel
    participant Vis as GLSPDSMVisualization

    Page->>Bridge: WebSocket /glsp
    Bridge->>Server: TCP connection (Content-Length framing)
    Page->>Server: initialize
    Server-->>Page: serverActions per diagram type (dsm-diagram: ..., dsmHoverCell)
    Page->>Server: initializeClientSession(diagramType: dsm-diagram)
    Server->>Module: createClientSession:server:clientActionKinds:
    Module->>Session: new
    Module->>Browser: new, session: session, model: model
    Browser->>Model: browser: self
    Note over Module,Browser: the browser is the source model of the session
    Page->>Server: process(requestModel)
    Server->>Session: process: GLSPRequestModelAction
    Session->>Session: GLSPMooseSourceModelStorage loadSourceModel: (nothing to read)
    Session->>Vis: createGModel: modelState
    Vis->>Browser: dsmModel
    Vis->>Model: orderedNodesX, orderedNodesY, getTupleDependencyWeight:, colorForTuple:...
    Vis-->>Session: GModel (headers, cells)
    Session-->>Page: setModel
```

The architectural map is opened the same way, with `GLSPArchitecturalMapDiagramModule`,
`GLSPArchitecturalMapBrowser`, `MiArchitecturalMapModel` and `GLSPArchitecturalMapVisualization` (which lets
`MiArchitecturalMapBuilder` and Roassal size and place the nodes).

## Hovering a DSM cell (callback from the client)

```mermaid
sequenceDiagram
    autonumber
    participant Listener as DsmHoverMouseListener (di.config.tsx)
    participant Server as GLSPServer
    participant Session as GLSPClientSession
    participant Handler as GLSPDSMHoverCellActionHandler
    participant Browser as GLSPDSMBrowser
    participant Model as MiDSMBrowserModel
    participant Vis as GLSPDSMVisualization

    Note over Listener: only when the cell under the mouse changes<br/>(no cellId when the mouse leaves the cells)
    Listener->>Server: process {kind: dsmHoverCell, cellId}
    Server->>Session: process: GLSPDSMHoverCellAction (GLSPAction class>>classForKind:)
    Session->>Handler: execute:in:
    Handler->>Browser: hoverCellWithId: cellId
    Browser->>Model: isCycle:, sccTuplesForTuple:
    alt neither the hovered cell nor the cells to highlight changed
        Browser-->>Handler: no action
    else one of them changed
        Browser->>Browser: hover: tuple (hoveredTuple, showSCC: tuples)
        Browser->>Session: updateGModel
        Session->>Vis: createGModel:
        Vis->>Browser: isHighlighted: tuple (for each cell)
        Vis->>Model: kindOf:in: (CSS classes dsm-cycle..., dsm-highlighted: the client colors the cells)
        Vis->>Browser: hoveredTuple (two node:rectangle outlines, class dsm-hovered-line, over the cells)
        Browser-->>Handler: { updateModel }
        Handler-->>Session: { updateModel }
        Session-->>Listener: updateModel (the client redraws)
    end
```

## A change of the model in Pharo (callback from the model)

For instance `model followEntity: otherEntities` on the DSM, or `updateFromConfiguration:` on the map:

```mermaid
sequenceDiagram
    autonumber
    participant Code as Pharo code
    participant Model as MiDSMBrowserModel
    participant Browser as GLSPDSMBrowser
    participant Session as GLSPClientSession
    participant Page as Browser page

    Code->>Model: followEntity: entities
    Model->>Browser: buildDSM (runVisualization for the map)
    Browser->>Browser: sendModelToClient
    Browser->>Session: updateGModel
    alt the client is connected
        Browser->>Page: updateModel
    else the client has gone (NetworkError)
        Browser->>Model: browser: (a new browser without client)
    end
```

## Notes for maintenance

- The server sends what the elements are, not how they look (native GLSP): types and CSS classes, no colors. The
  DSM colors (those of `MiDSMBrowserModel>>initializeColors`) and the outlines of the hovered column and row are in
  the client (`browser-client/index.html` of Pharo-GLSP).

- MooseIDE changes are committed to the `development` branch of the Midas fork (`git push midas development`).
  Its test workflow runs on pull requests only.
- Exporting the MooseIDE repository from Iceberg also rewrites files of unrelated packages (`.project`,
  `Famix-CriticBrowser*`, `MooseIDE-ButterflyMap-Tests`, `MooseIDE-Spotter*`): restore them before committing.
- After changing the Pharo side, restart the GLSP server (the running one keeps its modules and model), then
  reload the page; after changing `browser-client/`, restart `node server.js` (it rebuilds the client).
- The client must know the element types of a diagram (views in `browser-client/src/di.config.tsx`) and its name
  (`browser-client/src/app.ts`). A new diagram: a `GLSPMooseDiagramModule` subclass, a `GLSPMooseBrowser` subclass,
  a visualization (`GLSPGModelFactory` subclass), and its views in the client.
