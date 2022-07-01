Class {
	#name : #FailSafeDebugger,
	#superclass : #SpPresenter,
	#traits : 'TDebugger',
	#classTraits : 'TDebugger classTrait',
	#instVars : [
		'fsDebugSession',
		'code',
		'stackTable',
		'toolbar',
		'inspector'
	],
	#category : #'FailSafeDebugger-UI'
}

{ #category : #utilities }
FailSafeDebugger class >> closeAllDebuggers [

	<script>
	FailSafeDebugger allInstancesDo: [ :dbg | dbg close ]
]

{ #category : #'instance creation' }
FailSafeDebugger class >> debugSession: aDebugSession [

	| fsDebugSession debugger |
	"OupsDebugRequest calls this method with a debug session. So, if we want to use an fsDebugSession, we have to convert it"
	fsDebugSession := FailSafeDebugSession
		                  named: aDebugSession name
		                  on: aDebugSession interruptedProcess
		                  startedAt: aDebugSession interruptedContext.
	debugger := self on: fsDebugSession.
	debugger open.

	^ debugger
]

{ #category : #'initialize-release' }
FailSafeDebugger >> clear [

	self fsDebugSession clear
]

{ #category : #'initialize-release' }
FailSafeDebugger >> close [

	[ self withWindowDo: #close ] ensure: [ 
		self fsDebugSession ifNotNil: [ :session | session clear ] ]
]

{ #category : #accessing }
FailSafeDebugger >> context [

	^ self fsDebugSession suspendedContext 
]

{ #category : #'presenter - code' }
FailSafeDebugger >> createCode [

	^ self newCode
]

{ #category : #'presenter - code' }
FailSafeDebugger >> createInspector [

	"maybe we will remove it later. I just don't know right now how to have a similar inspector more easily, without relying on StDebuggerContext"

	^ (StRawInspection
		  on: (FsDebuggerContext context: self selectedContext) "self selectedContext")
		  beForDebugger;
		  yourself
]

{ #category : #initialization }
FailSafeDebugger >> createStack [

	^ self newTable
		  addColumn: ((SpStringTableColumn
				    title: 'Class'
				    evaluated: [ :item | self printReceiverClassInContext: item ])
				   sortFunction: nil;
				   yourself);
		  addColumn:
			  ((SpStringTableColumn title: 'Method' evaluated: [ :item | 
					    | method |
					    method := item method.
					    method isCompiledBlock
						    ifTrue: [ method sourceNode sourceCode ]
						    ifFalse: [ method selector ] ])
				   sortFunction: nil;
				   yourself);
		  addColumn:
			  ((SpStringTableColumn title: 'Package' evaluated: [ :item | 
					    | package |
					    package := item method package.
					    package ifNil: [ '-' ] ifNotNil: [ package name asString ] ])
				   sortFunction: nil;
				   yourself);
		  transmitDo: [ :context | 
			  stackTable selection isEmpty ifFalse: [ 
				  self updateInspectorFromContext: context.
				  self updateCodeFromContext: context.
				  "self updateWindowTitle" ] ];
		  yourself
]

{ #category : #initialization }
FailSafeDebugger >> createToolbar [

	^ self newToolbar
		  addItem: (self newToolbarButton
				   label: 'Proceed';
				   icon: (self iconNamed: #glamorousGo);
				   action: [ self proceedClicked ];
				   yourself);
		  addItem: (self newToolbarButton
				   label: 'Restart';
				   icon: (self iconNamed: #glamorousRestart);
				   action: [ self restartClicked ];
				   yourself);
		  addItem: (self newToolbarButton
				   label: 'stepInto';
				   icon: (self iconNamed: #glamorousDown);
				   action: [ self stepIntoClicked ];
				   yourself);
		  addItem: (self newToolbarButton
				   label: 'stepOver';
				   icon: (self iconNamed: #glamorousRight);
				   action: [ self stepOverClicked ];
				   yourself);
		  addItem: (self newToolbarButton
				   label: 'stepThrough';
				   icon: (self iconNamed: #glamorousThrough);
				   action: [ self stepThroughClicked ];
				   yourself);
		  yourself
]

{ #category : #accessing }
FailSafeDebugger >> fsDebugSession [

	^ fsDebugSession 
]

{ #category : #accessing }
FailSafeDebugger >> fsDebugSession: aFsDebugSession [

	fsDebugSession := aFsDebugSession.
	self updateStackFromSession: fsDebugSession
]

{ #category : #'morphic ui' }
FailSafeDebugger >> initialExtent [ 
	
	^ [ | w h |
		w := Display width.
		h := Display height.
		(w - (w // 3)) @ (h - (h // 5)) ]
		on: Error
		do: [ 850@650 ]
]

{ #category : #initialization }
FailSafeDebugger >> initialize [

	super initialize.
	
]

{ #category : #initialization }
FailSafeDebugger >> initializeLayout [

	self layout: (SpBoxLayout newVertical
			 add: stackTable;
			 add: toolbar expand: false;
			 add: code;
			 add: inspector;
			 yourself)
]

{ #category : #initialization }
FailSafeDebugger >> initializePresenters [

	code := self createCode.
	stackTable := self createStack.
	self updateStackFromSession: self fsDebugSession.
	inspector := self createInspector.
	toolbar := self createToolbar.
	self initializeLayout
]

{ #category : #initialization }
FailSafeDebugger >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self context printString;
		initialExtent: self initialExtent;
		whenClosedDo: [ self clear ]
]

{ #category : #printing }
FailSafeDebugger >> printReceiverClassInContext: aContext [

	| receiverClass methodClass |
	receiverClass := aContext receiver class.
	methodClass := aContext method methodClass.
	receiverClass == methodClass ifTrue: [ ^ receiverClass name ].
	^ (WriteStream on: String new)
		  nextPutAll: receiverClass name;
		  space;
		  nextPut: $(;
		  nextPutAll: methodClass name;
		  nextPut: $);
		  contents
]

{ #category : #actions }
FailSafeDebugger >> proceedClicked [

	self error: 'not yet implemented'
]

{ #category : #actions }
FailSafeDebugger >> restartClicked [

	self error: 'not yet implemented'
]

{ #category : #accessing }
FailSafeDebugger >> selectedContext [

	^ self stackTable selectedItem
]

{ #category : #initialization }
FailSafeDebugger >> setModelBeforeInitialization: anFsDebugSession [

	self fsDebugSession: anFsDebugSession
]

{ #category : #accessing }
FailSafeDebugger >> stack [

	^ self context stack
]

{ #category : #accessing }
FailSafeDebugger >> stackTable [

	^ stackTable
]

{ #category : #actions }
FailSafeDebugger >> stepIntoClicked [

	fsDebugSession stepInto.
	self updateUI
]

{ #category : #actions }
FailSafeDebugger >> stepOverClicked [

	fsDebugSession stepOver.
	self updateUI
]

{ #category : #actions }
FailSafeDebugger >> stepThroughClicked [

	fsDebugSession stepThrough.
	self updateUI
]

{ #category : #updating }
FailSafeDebugger >> updateCode [

	"not implemented"
]

{ #category : #'presenter - code' }
FailSafeDebugger >> updateCodeFromContext: aContext [

	"not yet implemented"

	
]

{ #category : #updating }
FailSafeDebugger >> updateInspector [

	self updateInspectorFromContext: self selectedContext
]

{ #category : #'updating - widgets' }
FailSafeDebugger >> updateInspectorFromContext: aContext [

	inspector ifNotNil: [ 
		inspector model: (FsDebuggerContext context: aContext) ]
]

{ #category : #accessing }
FailSafeDebugger >> updateStackFromSession: aFsDebugSession [

	stackTable ifNotNil: [ :stack | 
		stack
			items: aFsDebugSession stack;
			selectIndex: 1 scrollToSelection: true ]
]

{ #category : #updating }
FailSafeDebugger >> updateStackTable [

	self updateStackFromSession: self fsDebugSession
]

{ #category : #updating }
FailSafeDebugger >> updateUI [

	self
		updateStackTable;
		updateCode;
		updateInspector
]
