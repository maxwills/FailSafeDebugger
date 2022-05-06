Class {
	#name : #FailSafeDebugSession,
	#superclass : #Object,
	#instVars : [
		'suspendedProcess'
	],
	#category : #'FailSafeDebugger-Core'
}

{ #category : #testing }
FailSafeDebugSession >> isContextPostMortem: aContext [
]

{ #category : #private }
FailSafeDebugSession >> privateStepToFirstInterestingBytecodeIn: aProcess [
	"After a restart of a method activation step to the first 
	bytecode instruction that is of interest for the debugger.
	
	In this case step until a bytecode that causes a context switch,
	as otherwise one will have to press may time step into without 
	seeing any visible results."
	
	"If we are are stepping into a quick method,
	make sure that we step correctly over the first primitive bytecode"
	| suspendedContext |
	suspendedContext := aProcess suspendedContext.
	(suspendedContext method isQuick and: [ suspendedContext pc == suspendedContext method initialPC ])
		ifTrue: [ ^ suspendedContext updatePCForQuickPrimitiveRestart ].
	
	^ aProcess stepToSendOrReturn
]

{ #category : #actions }
FailSafeDebugSession >> stepInto [

	"will this work?"

	suspendedProcess step
]

{ #category : #actions }
FailSafeDebugSession >> stepOver [

	| newContext aContext |
	aContext := self context.
	(self isContextPostMortem: aContext) ifTrue: [ ^ self ].

	newContext := suspendedProcess completeStep: aContext.

	newContext == aContext
		ifTrue: [ 
		self privateStepToFirstInterestingBytecodeIn: suspendedProcess ]
		ifFalse: [ newContext ]
]

{ #category : #actions }
FailSafeDebugSession >> stepOver: aContext [

	| newContext |
	(self isContextPostMortem: aContext) ifTrue: [ ^ self ].

	newContext := suspendedProcess completeStep: aContext.

	newContext == aContext
		ifTrue: [ 
		self privateStepToFirstInterestingBytecodeIn: suspendedProcess ]
		ifFalse: [ newContext ]
]
