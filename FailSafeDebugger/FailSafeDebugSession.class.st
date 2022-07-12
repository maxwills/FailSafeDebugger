Class {
	#name : #FailSafeDebugSession,
	#superclass : #Object,
	#instVars : [
		'name',
		'suspendedProcess',
		'suspendedContext'
	],
	#category : #'FailSafeDebugger-Core'
}

{ #category : #accessing }
FailSafeDebugSession class >> named: aString on: aProcess startedAt: aContext [

	^ self new
		  name: aString;
		  process: aProcess context: aContext
]

{ #category : #actions }
FailSafeDebugSession >> clear [

	suspendedProcess := nil.
	self updateContextTo: nil
]

{ #category : #testing }
FailSafeDebugSession >> isContextPostMortem: aContext [

	"return whether we're inspecting a frozen exception without a process attached"
	| interruptedContext |
	interruptedContext := suspendedProcess suspendedContext.
	interruptedContext ifNil: [ ^ false ].
	^ (interruptedContext hasContext: aContext) not.
]

{ #category : #'debug - execution' }
FailSafeDebugSession >> isInterruptedContextATest [

	^ (self isTestObject: suspendedContext receiver) and: [ 
		  self
			  isTestMethod: suspendedContext method
			  of: suspendedContext receiver ]
]

{ #category : #'updating - actions' }
FailSafeDebugSession >> isLatestContext: aContext [

	^ suspendedProcess suspendedContext == aContext
]

{ #category : #testing }
FailSafeDebugSession >> isTestMethod: aCompiledMethod of: aTestCase [

	^ aCompiledMethod selector = aTestCase selector
]

{ #category : #testing }
FailSafeDebugSession >> isTestObject: anObject [

	"I'm not sure this is the best way to doit because it creates a coupling with TestCase, but due that SUnit is part of the core I think it is not bad after all - Hernan'"
	^ anObject isKindOf: TestCase
]

{ #category : #accessing }
FailSafeDebugSession >> name [

	^ name
]

{ #category : #accessing }
FailSafeDebugSession >> name: anObject [

	name := anObject
]

{ #category : #private }
FailSafeDebugSession >> prepareTestToRunAgain [

	suspendedContext receiver prepareToRunAgain
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
	| interruptedContext |
	interruptedContext := aProcess suspendedContext.
	(interruptedContext method isQuick and: [ interruptedContext pc == interruptedContext method initialPC ])
		ifTrue: [ ^ interruptedContext updatePCForQuickPrimitiveRestart ].
	
	^ aProcess stepToSendOrReturn
]

{ #category : #testing }
FailSafeDebugSession >> proceedDebugSession [

	"Proceed execution of the receiver's model, starting after the expression at 
	which an interruption occurred."

	"If the user of this session does not plan to reuse it, it should call 'self clean' "

	Smalltalk okayToProceedEvenIfSpaceIsLow
		ifFalse: [ ^ self ].
	(self isContextPostMortem: suspendedContext)
		ifTrue: [ ^ self ].
	self resumeProcess.
]

{ #category : #initialization }
FailSafeDebugSession >> process: aProcess context: aContext [

	suspendedProcess := aProcess.
	suspendedContext ifNil: [ suspendedContext := aContext ]
]

{ #category : #'debug - execution' }
FailSafeDebugSession >> restartContext: aContext [
	"Proceed from the initial state of selectedContext." 
	"Closing now depends on a setting (RestartAlsoProceeds class variable) --> not supported in this version"

	(self isContextPostMortem: aContext) ifTrue: [^ self].

	"Issue 3015 - Hernan"
	self isInterruptedContextATest ifTrue: [ self prepareTestToRunAgain ].
	self unwindAndRestartToContext: aContext.	
]

{ #category : #testing }
FailSafeDebugSession >> resumeProcess [

	"Make sure the interrupted process is restored properly and restart the low space handler"

	suspendedProcess resume.

	"restart low space handler"
	Smalltalk installLowSpaceWatcher
]

{ #category : #'updating - actions' }
FailSafeDebugSession >> selectedCodeRangeForContext: aContext [

	"Answer the indices in the source code for the method corresponding to 
	aContext's program counter value."

	(aContext isNil or: [ aContext isDead ])
		ifTrue: [ ^ 1 to: 0 ].
	^ aContext pcRangeContextIsActive: (self isLatestContext: aContext)
]

{ #category : #accessing }
FailSafeDebugSession >> stack [

	^ suspendedContext stack
]

{ #category : #actions }
FailSafeDebugSession >> stepInto [

	"will this work?"

	suspendedProcess step
]

{ #category : #actions }
FailSafeDebugSession >> stepInto: aContext [

	"will this work?"

	(self isContextPostMortem: aContext) ifTrue: [ ^ self ].

	suspendedProcess step: aContext.

	self updateContextTo:
		(self privateStepToFirstInterestingBytecodeIn: suspendedProcess)
]

{ #category : #actions }
FailSafeDebugSession >> stepOver [

	self stepOver: suspendedContext 
]

{ #category : #actions }
FailSafeDebugSession >> stepOver: aContext [

	| newContext |
	(self isContextPostMortem: aContext) ifTrue: [ ^ self ].

	newContext := suspendedProcess completeStep: aContext.

	self updateContextTo: (newContext == aContext
			 ifTrue: [ 
			 self privateStepToFirstInterestingBytecodeIn: suspendedProcess ]
			 ifFalse: [ newContext ])
]

{ #category : #actions }
FailSafeDebugSession >> stepThrough [

	self stepThrough: suspendedContext 
]

{ #category : #actions }
FailSafeDebugSession >> stepThrough: aContext [

	(self isContextPostMortem: aContext) ifTrue: [^ self].
	
	suspendedProcess stepToHome: aContext.
	self updateContextTo: (self privateStepToFirstInterestingBytecodeIn: suspendedProcess)
]

{ #category : #accessing }
FailSafeDebugSession >> suspendedContext [

	^ suspendedContext
]

{ #category : #evaluating }
FailSafeDebugSession >> unwindAndRestartToContext: aContext [

	| ctx |
	ctx := suspendedProcess popTo: aContext.
	ctx == aContext ifTrue: [ "Only restart the process if the stack was unwind"
		suspendedProcess restartTop.
		self privateStepToFirstInterestingBytecodeIn: suspendedProcess ].
	
	self updateContextTo: aContext
]

{ #category : #accessing }
FailSafeDebugSession >> updateContextTo: aContext [

	suspendedContext := aContext
]
