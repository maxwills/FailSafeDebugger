Class {
	#name : #FsDebuggerContext,
	#superclass : #Object,
	#instVars : [
		'context'
	],
	#category : #FailSafeDebugger
}

{ #category : #accessing }
FsDebuggerContext class >> context: aContext [

	^ self new
		  context: aContext;
		  yourself
]

{ #category : #accessing }
FsDebuggerContext >> allInspectorNodes [

	| nodes argsNodes tempsNodes tempsAndArgs |
	nodes := OrderedCollection new.
	tempsAndArgs := self temporaryVariablesNodes.
	argsNodes := tempsAndArgs select: [ :tempNode | tempNode tempVariable isArgumentVariable ].
	tempsNodes := tempsAndArgs select: [ :tempNode | tempNode tempVariable isTempVariable ].
	nodes add: self selfNode.
	nodes addAll: argsNodes.
	nodes addAll: tempsNodes.
	nodes addAll: self receiverNodes.
	nodes add: self stackTopNode.
	nodes add: self thisContextNode.
	^ nodes
]

{ #category : #accessing }
FsDebuggerContext >> context [

	^ context ifNil: [ context := [] asContext ]
]

{ #category : #accessing }
FsDebuggerContext >> context: anObject [
	context := anObject
]

{ #category : #printing }
FsDebuggerContext >> printOn: aStream [
	aStream nextPutAll: context asString 
]

{ #category : #nodes }
FsDebuggerContext >> receiverNodes [

	^ self context receiver allInspectorNodes reject: [ :node | 
		  node label = 'self' ]
]

{ #category : #nodes }
FsDebuggerContext >> selfNode [

	^ StInspectorSelfNode hostObject: self context receiver
]

{ #category : #nodes }
FsDebuggerContext >> stackTopNode [
	^StInspectorStackTopNode hostObject: self context
]

{ #category : #nodes }
FsDebuggerContext >> temporaryVariablesNodes [

	^ self context astScope allTemps collect: [ :temp | 
		  (StInspectorTempNode hostObject: self context) tempVariable: temp ]
]

{ #category : #nodes }
FsDebuggerContext >> thisContextNode [ 
	^StInspectorThisContextNode hostObject: self context
]
