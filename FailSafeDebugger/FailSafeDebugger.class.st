Class {
	#name : #FailSafeDebugger,
	#superclass : #SpPresenter,
	#instVars : [
		'fsDebugSession',
		'code',
		'stackTable',
		'toolbar',
		'inspector'
	],
	#category : #'FailSafeDebugger-UI'
}

{ #category : #'presenter - code' }
FailSafeDebugger >> createCode [

	^ self newCode
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

{ #category : #initialization }
FailSafeDebugger >> initialize [

	super initialize.
	
]

{ #category : #initialization }
FailSafeDebugger >> initializeLayout [

	self layout: (SpBoxLayout newVertical
			 add: stackTable;
			 add: toolbar;
			 add: code;
			 add: inspector;
			 yourself)
]

{ #category : #initialization }
FailSafeDebugger >> initializePresenters [

	code := self createCode.
	stackTable := self newTable.
	inspector := StInspector on: nil.
	toolbar := self createToolbar.
	self initializeLayout
]

{ #category : #actions }
FailSafeDebugger >> proceedClicked [

	self error: 'not yet implemented'
]

{ #category : #actions }
FailSafeDebugger >> restartClicked [

	self error: 'not yet implemented'
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

	self error: 'not implmenented'
]

{ #category : #updating }
FailSafeDebugger >> updateInspector [

	self error: 'not implmenented'
]

{ #category : #updating }
FailSafeDebugger >> updateStackTable [

	self error: 'not implmenented'
]

{ #category : #updating }
FailSafeDebugger >> updateUI [

	self
		updateStackTable;
		updateCode;
		updateInspector
]
