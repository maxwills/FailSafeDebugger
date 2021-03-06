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

{ #category : #'as yet unclassified' }
FailSafeDebugger >> createCode [

	^ self newCode
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
	toolbar := self newToolbar.
	self initializeLayout
]

{ #category : #'as yet unclassified' }
FailSafeDebugger >> stepIntoClicked [

	fsDebugSession stepInto.
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
