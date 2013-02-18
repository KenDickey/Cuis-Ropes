'From Cuis 4.1 of 12 December 2012 [latest update: #1590] on 18 February 2013 at 9:23:26 am'!
'Description Please enter a description for this package '!
!classDefinition: #Rope category: #Ropes!
ArrayedCollection subclass: #Rope
	instanceVariableNames: ''
	classVariableNames: 'Fibonacci MaxRopeDepth'
	poolDictionaries: ''
	category: 'Ropes'!
!classDefinition: 'Rope class' category: #Ropes!
Rope class
	instanceVariableNames: ''!

!classDefinition: #ConcatRope category: #Ropes!
Rope subclass: #ConcatRope
	instanceVariableNames: 'depth totalLength leftRope rightRope'
	classVariableNames: 'MeldThreshold'
	poolDictionaries: ''
	category: 'Ropes'!
!classDefinition: 'ConcatRope class' category: #Ropes!
ConcatRope class
	instanceVariableNames: ''!

!classDefinition: #FlatRope category: #Ropes!
Rope subclass: #FlatRope
	instanceVariableNames: 'theString'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Ropes'!
!classDefinition: 'FlatRope class' category: #Ropes!
FlatRope class
	instanceVariableNames: ''!

!classDefinition: #RopeTest category: #Ropes!
TestCase subclass: #RopeTest
	instanceVariableNames: 'flatRope longFlat shortFlat subRope concRope1 concRope2 concRope3'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Ropes'!
!classDefinition: 'RopeTest class' category: #Ropes!
RopeTest class
	instanceVariableNames: ''!

!classDefinition: #SubRope category: #Ropes!
Rope subclass: #SubRope
	instanceVariableNames: 'startIndex length theString'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Ropes'!
!classDefinition: 'SubRope class' category: #Ropes!
SubRope class
	instanceVariableNames: ''!


!ConcatRope commentStamp: '<historical>' prior: 0!
I am the concatenation of two other ropes.!

!FlatRope commentStamp: '<historical>' prior: 0!
A flat rope is basically a string.  It is a "leaf".!

!Rope commentStamp: '<historical>' prior: 0!
I am the abstract class of immutable strings known as Ropes.

Functional string operations return new Ropes. See #at:put: in subclasses.

Multithreaded sharing of ropes needs no locking.

See:
	https://en.wikipedia.org/wiki/Rope_%28computer_science%29

Ropes offers better performance than strings for common operations, and generally reduce memory allocations and copies, while only entailing a small degradation of less common operations.

Where a string is represented in memory by an array of character values, a rope is a tree structure whose leaves are slices of immutable strings. Therefore, concatenation, appending, prepending, substrings, etc. are operations that require only trivial tree manipulation, generally without having to copy memory. In addition, the tree structure of ropes makes them suitable as a form of index to speed-up access to Unicode characters by index in long chunks of text.

The following operations are algorithmically faster in ropes:

    - extracting a subrope is logarithmic (linear in strings);
    - appending/prepending is near-constant time (linear in strings);
    - concatenation is near-constant time (linear in strings);
    - char length is constant-time (linear in strings);

    - access to a character by index is logarithmic (linear in strings);

Note:
	Character>>asRope
	String>>asRope
	Rope class>>fromString
	!

!RopeTest commentStamp: '<historical>' prior: 0!
Test Cases for Ropes!

!SubRope commentStamp: '<historical>' prior: 0!
I refer to an immutable string shared with another Rope.!

!Character methodsFor: '*ropes' stamp: 'KenD 2/9/2013 20:08'!
asRope
	"Answer self as a rope"

	^self asString asRope! !

!ConcatRope methodsFor: 'accessing' stamp: 'KenD 2/12/2013 14:05'!
at: anIndex

	| leftLength |
	leftLength := self leftRope size.
	(anIndex <= leftLength)
	ifTrue:  [^leftRope  at: anIndex]
	ifFalse: [^rightRope at: (anIndex - leftLength)]! !

!ConcatRope methodsFor: 'accessing' stamp: 'KenD 2/12/2013 14:02'!
at: index put: aCharacter 

	"Answer a new rope"
	| leftLength |
	leftLength := self leftRope size.
	(index <= leftLength)
	ifTrue: [ ^ (self leftRope at: index put: aCharacter) , self rightRope]
	ifFalse: [ ^ self leftRope ,
		          (self rightRope at: (index - leftLength) put: aCharacter)]! !

!ConcatRope methodsFor: 'private' stamp: 'KenD 2/12/2013 18:50'!
balanceAsRequired
	"Rebalance as required"

	(self depth > Rope maxRopeDepth)
	ifTrue:  [ ^ self rebalance ]
	ifFalse: [ ^ self ]! !

!ConcatRope methodsFor: 'copying' stamp: 'KenD 2/12/2013 14:04'!
copyFrom: start to: stop 
	"Answer a Rope."
	
	| leftMaxIndex left right |
	"Handle odd case the same way as OrderedCollection"
	(stop < start) ifTrue: [^ FlatRope fromString: ''].

	((1 <= start) and: [stop <= self size])
	ifFalse: [
		(1 <= start) 
		ifTrue:  [self errorSubscriptBounds: stop]
		ifFalse: [self errorSubscriptBounds: start]
	].

	leftMaxIndex := self leftRope size.
	
	"Contained in left rope?"
	(stop <= leftMaxIndex)
	ifTrue: [^self leftRope copyFrom: start to: stop].
	
	"Contained in right ropt?"
	(start > leftMaxIndex)
	ifTrue: [^self rightRope copyFrom: (start - leftMaxIndex) to: (stop - leftMaxIndex)].
	
	"Spans both ropes"
	left   := self leftRope  copyFrom: start to: leftMaxIndex..
	right := self rightRope copyFrom: 1     to: (stop - leftMaxIndex).
	^ConcatRope concatenate: left with: right

! !

!ConcatRope methodsFor: 'private' stamp: 'KenD 2/12/2013 14:21'!
depth
	
	^depth! !

!ConcatRope methodsFor: 'enumerating' stamp: 'KenD 2/15/2013 21:50'!
do: aBlock
	"aBlock takes each Character in me as an argument"

	"recurse into the leaves, give them aBlock, and let them do the work"
	self leftRope do: aBlock.
	self rightRope do: aBlock.! !

!ConcatRope methodsFor: 'private' stamp: 'KenD 2/8/2013 16:58'!
leftRope
	
	^leftRope! !

!ConcatRope methodsFor: 'private' stamp: 'KenD 2/12/2013 15:28'!
meldThreshold

	"Answer combined size below which we should meld short strings together"
	^ ConcatRope meldThreshold ! !

!ConcatRope methodsFor: 'private' stamp: 'KenD 2/8/2013 16:59'!
rightRope
	
	^rightRope! !

!ConcatRope methodsFor: 'accessing' stamp: 'KenD 2/8/2013 19:31'!
size

	^totalLength! !

!ConcatRope methodsFor: 'initialize-release' stamp: 'KenD 2/12/2013 19:02'!
withLeft: aRope andRight: anotherRope

	leftRope := aRope asRope.
	rightRope := anotherRope asRope.
	totalLength := aRope size + anotherRope size.
	
	"Common special cases to optimize"
	
	"Meld two short flat ropes"
	(totalLength < ConcatRope meldThreshold )
	ifTrue: [ ^ FlatRope fromString: ((aRope asString) , (anotherRope asString))]. "'FIXME: optimize"
	
	"If left rope has short right child and right rope is short, meld them"
	((leftRope class == ConcatRope)
		and: [ ((leftRope rightRope size) + rightRope size) 
			 < ConcatRope meldThreshold  ])
	ifTrue: [
		^((ConcatRope
			concatenate: (leftRope leftRope) "LeftRope's left child"
			with: (FlatRope fromString: ((leftRope rightRope asString) , 
										(rightRope asString)))  "'FIXME: optimize"
			) balanceAsRequired)
	].

	"The General Case"
	
	"depth is not defined for Strings; be sure to use Ropes"
	depth := 1 + (leftRope depth max: (rightRope depth)).
	^(self balanceAsRequired)! !

!ConcatRope class methodsFor: 'instance creation' stamp: 'KenD 2/12/2013 15:29'!
concatenate: aRope with: otherRope
	"Answer a new ConcatRope"

	"Don't bother to concat zero length ropes"
	(aRope size = 0)
		ifTrue: [^otherRope asRope].
		
	(otherRope size = 0)
		ifTrue: [^aRope asRope].

	"Non-trivial. Answer a new instance"	
	^(self new initialize withLeft: aRope andRight: otherRope) "NB: may return a FlatRope"! !

!ConcatRope class methodsFor: 'class initialization' stamp: 'KenD 2/12/2013 15:28'!
initialize
	"ConcatRope class initialization"
"
	ConcatRope initialize.
"
	MeldThreshold := 17.! !

!ConcatRope class methodsFor: 'accessing' stamp: 'KenD 2/12/2013 15:27'!
meldThreshold
	"Concatenating short ropes (combined lenth < meldThreshold) get melded (joined) together"

	^MeldThreshold ! !

!FlatRope methodsFor: 'accessing' stamp: 'KenD 2/8/2013 16:45'!
at: anIndex
	
	^self theString at: anIndex! !

!FlatRope methodsFor: 'accessing' stamp: 'KenD 2/10/2013 19:23'!
at: index put: aCharacter 

	"Answer a new rope"
	(self size = 1)
	ifTrue: [
		(index = 1)
		ifTrue: [^ aCharacter asRope]
		ifFalse: [self errorSubscriptBounds: index]
	].
	
	(index = 1)
	ifTrue: [ ^ (aCharacter asRope , (self copyFrom: 2 to: self size))].
	
	(index = self size)
	ifTrue: [ ^ (self copyFrom: 1 to: (self size - 1)) , aCharacter asRope ].
	
	^ (self copyFrom: 1 to: (index - 1)) ,
	   aCharacter asRope ,
	   (self copyFrom: (index + 1) to: (self size))! !

!FlatRope methodsFor: 'copying' stamp: 'KenD 2/11/2013 17:12'!
copyFrom: start to: stop 
	"Answer a Rope."

	"Handle odd case the same way as OrderedCollection"
	(stop < start) ifTrue: [^ FlatRope fromString: ''].

	((start = 1) and: (stop = self size))
	ifTrue: [^self].
	
	((1 <= start) and: [stop <= self size])
	ifTrue: [
		^(SubRope new initialize 
			string: (self theString) startIndex: start length: (stop - start + 1))
	]
	ifFalse: [
		(stop > self size) 
		ifTrue: [self errorSubscriptBounds: stop]
		ifFalse: [self errorSubscriptBounds: start]
	]! !

!FlatRope methodsFor: 'private' stamp: 'KenD 2/12/2013 14:22'!
depth
	"I am a leaf"
	
	^0! !

!FlatRope methodsFor: 'enumerating' stamp: 'KenD 2/15/2013 21:49'!
do: aBlock
	"aBlock takes each Character in me (my string) as an argument"

	self theString do: aBlock! !

!FlatRope methodsFor: 'accessing' stamp: 'KenD 2/8/2013 16:53'!
size
	"??cash this as an instance variable??"
	
	^self theString size! !

!FlatRope methodsFor: 'accessing' stamp: 'KenD 2/8/2013 19:55'!
substringFrom: startIndex length: numChars

	((0 <= startIndex) and: [startIndex + numChars <= self size])
	ifTrue: [
		^(SubRope new initialize string: (self string) startIndex: startIndex length: numChars)
	]
	ifFalse: [self errorSubscriptBounds: startIndex]! !

!FlatRope methodsFor: 'private' stamp: 'KenD 2/8/2013 16:44'!
theString
	
	^theString! !

!FlatRope methodsFor: 'initialize-release' stamp: 'KenD 2/9/2013 19:28'!
with: aString

	theString := aString. "@@FixMe -- aString assumed immutable"
	^self! !

!FlatRope class methodsFor: 'instance creation' stamp: 'KenD 2/10/2013 19:43'!
fromString: aString
	"Answer a new rope.
	As the string must be immutable, we will keep a copy"

	^(self new initialize with: aString copy;
	   yourself)! !

!Rope methodsFor: 'copying' stamp: 'KenD 2/9/2013 19:55'!
, aRopeOrString
	^ (ConcatRope concatenate: self with: aRopeOrString).! !

!Rope methodsFor: 'converting' stamp: 'KenD 2/8/2013 19:12'!
asRope

	^self! !

!Rope methodsFor: 'converting' stamp: 'KenD 2/10/2013 14:30'!
asString

	^self stringRepresentation! !

!Rope methodsFor: 'converting' stamp: 'KenD 2/11/2013 16:59'!
asText
	"Answer a Text whose ''string'' is the receiver."

	^Text fromString: self! !

!Rope methodsFor: 'copying' stamp: 'KenD 2/11/2013 18:47'!
copyReplaceFrom: start to: stop with: ropeOrString

	^((self copyFrom: 1 to: (start - 1)) , ropeOrString asRope , (self copyFrom: (stop + 1) to: (self size))) ! !

!Rope methodsFor: 'debugging' stamp: 'KenD 2/11/2013 17:43'!
doesNotUnderstand: aMessage

	"See what is missing from Ropes"
	Transcript log: (String streamContents: [:s | aMessage storeOn: s]).
	
	"Do what a String would do"
	aMessage sendTo: (self asString)! !

!Rope methodsFor: 'accessing' stamp: 'KenD 2/11/2013 18:30'!
first
	"Answer first index -- like Text"
	^1! !

!Rope methodsFor: 'private' stamp: 'KenD 2/12/2013 17:14'!
isBalanced
	"Answer if the Rope is balanced"

	| fib |
	fib := Rope fibonacci.
	(self depth >= (fib size - 2))
	ifTrue:  [^false]
	ifFalse: [^ (fib at: (self depth + 2)) <= self size]! !

!Rope methodsFor: 'accessing' stamp: 'KenD 2/11/2013 18:30'!
last
	"Answer last index -- like Text"
	^self size! !

!Rope methodsFor: 'printing' stamp: 'KenD 2/10/2013 20:10'!
printOn: aStream
	"Look good in the inspector"

	aStream nextPutAll: 'Rope('. "??self class printOn:??"
	aStream nextPut: $' .
	aStream nextPutAll: self stringRepresentation.
	aStream nextPut: $' .
	aStream nextPut: $)! !

!Rope methodsFor: 'printing' stamp: 'KenD 2/10/2013 19:56'!
printString

	^String streamContents: [:s | self printOn: s]! !

!Rope methodsFor: 'private' stamp: 'KenD 2/13/2013 15:49'!
rebalance
	"Answer a new balanced rope with my data"

	| leafNodes toExamine |
	leafNodes  := OrderedCollection new.
	toExamine := OrderedCollection new.
	toExamine addLast: self.
	"depth first"
	[toExamine size > 0] whileTrue: [
		| node |
		node := toExamine removeFirst.
		(node class == ConcatRope)
		ifTrue: [
			toExamine addLast: node rightRope.
			toExamine addLast: node leftRope
		]
		ifFalse: [leafNodes addLast: node]
	].
	^ Rope merge: leafNodes start: 1 end: (leafNodes size).! !

!Rope methodsFor: 'printing' stamp: 'KenD 2/9/2013 19:36'!
stringRepresentation

	^String streamContents: [:s | self do: [ :char | s nextPut: char]]! !

!Rope class methodsFor: 'private' stamp: 'KenD 2/12/2013 17:08'!
fibonacci

"
	self fibonacci size.
"
	^Fibonacci ! !

!Rope class methodsFor: 'instance creation' stamp: 'KenD 2/16/2013 14:46'!
fromString: aString
	"Answer a new rope"

	^FlatRope fromString: aString! !

!Rope class methodsFor: 'class initialization' stamp: 'KenD 2/16/2013 14:47'!
initialize
"
	Rope initialize.
"
	Fibonacci :=   #( 0  1  1  2  3  5  8  13  21  34  55  89  144  233  377  610  987  1597  2584  4181  6765  10946  17711  28657  46368  75025  121393  196418  317811  514229  832040  1346269  2178309  3524578  5702887  9227465  14930352  24157817  39088169  63245986  102334155  165580141  267914296  433494437  701408733  1134903170  1836311903  2971215073  4807526976  7778742049  12586269025  20365011074  32951280099  53316291173  86267571272  139583862445  225851433717  365435296162  591286729879  956722026041  1548008755920  2504730781961  4052739537881  6557470319842  10610209857723  17167680177565  27777890035288  44945570212853  72723460248141  117669030460994  190392490709135  308061521170129  498454011879264  806515533049393  1304969544928657  2111485077978050  3416454622906707  5527939700884757  8944394323791464  14472334024676221  23416728348467685  37889062373143906  61305790721611591  99194853094755497  160500643816367088  259695496911122585  420196140727489673  679891637638612258  1100087778366101931  1779979416004714189  2880067194370816120  4660046610375530309  7540113804746346429 ).
	
	MaxRopeDepth := 96.  "rebalance ropes whose depth exceeds this"! !

!Rope class methodsFor: 'private' stamp: 'KenD 2/12/2013 18:33'!
maxRopeDepth
	"Rebalance a Rope when its depth exceeds this."
"
	self fibonacci size.
"
	^MaxRopeDepth ! !

!Rope class methodsFor: 'private' stamp: 'KenD 2/12/2013 18:28'!
merge: leafNodes start: start end: end
	"Answer a balanced rope based on data from Rope\>>rebalance"

	| range middle |
	range := end - start.
	
	(range = 1)
	ifTrue: [^ leafNodes at: start].
	
	(range = 2)
	ifTrue: [^ (leafNodes at: start) , (leafNodes at: (start + 1)) ].
	
	middle := start + (range // 2).
	
	^ (self merge: leafNodes start: start end: middle ) ,
	   (self merge: leafNodes start: middle end: end)
	! !

!Rope class methodsFor: 'user interface' stamp: 'KenD 2/11/2013 19:22'!
openTextEditor

"
	Rope openTextEditor.
"
	SystemWindow 
		editText: (TextModel 
			withText: (FlatRope fromString: 'Let us see what these Rope things can do.')) 
			label: 'Text Editor' 
			wrap: true! !

!RopeTest methodsFor: 'testing' stamp: 'KenD 2/12/2013 15:17'!
setUp

	"Set up class variables (before each test)."
	"This could be done once, as Ropes are immutable"
	| testString |
	testString := '1234abcd5678hijk90lm'.
	flatRope := FlatRope fromString: testString.
	"Build SubRope by hand as we need to test constructor"
	subRope := SubRope new initialize string: testString startIndex: 5 length: 12.
	concRope1 := ConcatRope concatenate: subRope with: (' new string tail' asRope).
	concRope2 := ConcatRope concatenate: concRope1 with:concRope1.
	concRope3 := ConcatRope concatenate: ('Now is the time ' asRope) with: subRope.
	longFlat  := FlatRope fromString: '123456789012345678901234567890'. "long"
	shortFlat := FlatRope fromString: 'short'. "short"! !

!RopeTest methodsFor: 'testing' stamp: 'KenD 2/10/2013 14:45'!
testAccess
	"Can we get there from here?"

	self assert: ((flatRope at: 5) = $a).
	self assert: ((subRope at: 2) = $b).
	self assert: ((concRope1 at: 2) = $b).
	self assert: ((concRope1 at: 14) = $n).
	self assert: ((concRope2 at: 5) = $5).
	self assert: ((concRope2 at: (concRope1 size + 5)) = $5).
	self assert: ((concRope3 at: 5) = $i).
	self assert: ((concRope3 at: (16 + 5)) = $5).! !

!RopeTest methodsFor: 'performance' stamp: 'hjh 2/17/2013 22:35'!
testConcatTime
	"self new testConcatTime"

	| r r2 result africanProverb interpretation |
	africanProverb :=  'A hundred pieces of elephant (reed) grass cannot cause the one fetching water to fall down on the way.'.
	interpretation := 'If you are serious about doing something, nothing can prevent you from doing it.'.
	
	r := Rope fromString: africanProverb.
	r2 := Rope fromString: interpretation.
	
	Transcript newLine.
	Transcript show: 'concat time for Ropes: ',  [500000 timesRepeat: [ result := r2, r]] timeToRun asString, 'ms'.
	Transcript newLine.
	
	Transcript show: 'concat time for Strings: ',  
					[500000 timesRepeat: [ result := interpretation, africanProverb]] timeToRun asString, 'ms'.
	Transcript newLine.
	
	
	africanProverb :=  'A hundred pieces of elephant (reed) grass cannot cause the one fetching water to fall down on the way.'.
	interpretation := 'If you are serious about doing something, nothing can prevent you from doing it.'.
	
	
	r := Rope fromString: africanProverb.
	r2 := Rope fromString: interpretation.
	
	
	result := Rope fromString: ''.
	Transcript show: 'concat time for Ropes: ',  [1000 timesRepeat: [ result := r2, r, result]] timeToRun asString, 'ms'.
	Transcript newLine.
	
	result := ''.
	Transcript show: 'concat time for Strings: ',  
			[1000 timesRepeat: [ result := interpretation, africanProverb, result]] timeToRun asString, 'ms'.
	Transcript newLine.
	
	
	
	! !

!RopeTest methodsFor: 'performance' stamp: 'hjh 2/18/2013 09:21'!
testIterationTime
	"self new testIterationTime"

	| r r2 ropeTest stringTest africanProverb interpretation ropeResult stringResult ir is|
	africanProverb :=  'A hundred pieces of elephant (reed) grass cannot cause the one fetching water to fall down on the way.'.
	interpretation := 'If you are serious about doing something, nothing can prevent you from doing it.'.
	
	r := Rope fromString: africanProverb.
	r2 := Rope fromString: interpretation.
	
	Transcript newLine.
	ropeResult := 'concat time for Ropes: ',  
		[500000 timesRepeat: [ ropeTest := r2, r]] timeToRun asString, 'ms', String newLineString.
		ropeResult	:=	ropeResult, '  time for #do: loop: ',
		[ ir:=0. ropeTest do: [ :ch | ir := ir + 1. 10000 timesRepeat: [ir=ir "busy waiting"]]] 
			timeToRun asString, 'ms'.
	Transcript show: ropeResult. Transcript newLine.
	

	stringResult	:=	'concat time for Strings: ',
	    [500000 timesRepeat: [ stringTest := interpretation, africanProverb]] timeToRun asString, 'ms',
	             String newLineString.
	    stringResult	:=	stringResult, '  time for #do: loop: ',
		[ is:=0. stringTest do: [ :ch | is := is + 1. 10000 timesRepeat: [is=is "busy waiting"]]] 
		timeToRun asString, 'ms'.
	Transcript show: stringResult. Transcript newLine.
	
	self assert: is = ir. "the end indices of the string and the rope must be equal"
	
	
	
	
! !

!RopeTest methodsFor: 'testing' stamp: 'KenD 2/12/2013 18:55'!
testMeld
	"Do we meld short ropes?"

	self assert: ( (shortFlat , shortFlat) class == FlatRope ).
	self deny: ( (longFlat , shortFlat) class == FlatRope ).
	self deny: ( (shortFlat , longFlat) class == FlatRope ).
	self deny: ( (longFlat , longFlat) class == FlatRope ).

	self assert: ( (shortFlat , shortFlat) depth = 0).
	self assert: ( (longFlat ,  shortFlat) depth = 1).
	self assert: ( (shortFlat , longFlat)  depth = 1).
	self assert: ( (longFlat ,  longFlat , longFlat) depth = 2 ).
	self assert: ( (longFlat , shortFlat , longFlat) depth = 2 ).
	self assert: ( (longFlat , shortFlat , shortFlat) depth = 1 ).
	self assert: ( (shortFlat , longFlat ,  longFlat) depth = 2 ).
	self assert: ( (shortFlat , shortFlat , longFlat) depth = 1 ).
	self assert: ( (shortFlat , longFlat , shortFlat) depth = 2 ).
	self assert: ( (shortFlat , shortFlat , shortFlat) depth = 0 ).
! !

!RopeTest methodsFor: 'testing' stamp: 'KenD 2/10/2013 19:40'!
testMutation
	"Can we make a change which makes a difference?"

	self assert: ((flatRope at: 1 put: $0) asString = '0234abcd5678hijk90lm' ).
	self assert: ((flatRope at: (flatRope size) put: $0) asString = '1234abcd5678hijk90l0'  ).
	self assert: ((flatRope at: 5 put: $5) asString = '12345bcd5678hijk90lm' ).
	
	self assert: ((subRope at: 5 put: $e) asString =  'abcde678hijk' ).
	self assert: ((subRope at: 1 put: $0) asString = '0bcd5678hijk' ).
	self assert: ((subRope at: (subRope size) put: $0) asString = 'abcd5678hij0' ).
	
	self assert: ((concRope1 at: 2 put: $0) asString =  'a0cd5678hijk new string tail' ).
	self assert: ((concRope1 at: 20 put: $0) asString =  'abcd5678hijk new st0ing tail' ).
	self assert: ((concRope1 at: (concRope1 size) put: $0) asString =  'abcd5678hijk new string tai0' ).

	self assert: ((concRope3 at: 2 put: $0) asString =   'N0w is the time abcd5678hijk' ).
	self assert: ((concRope3 at: 20 put: $0) asString =   'Now is the time abc05678hijk' ).
	self assert: ((concRope3 at: (concRope1 size) put: $0) asString =   'Now is the time abcd5678hij0' ).
! !

!RopeTest methodsFor: 'testing' stamp: 'KenD 2/10/2013 20:12'!
testPrint
	"What does it look like?"

	self assert: ((flatRope asString) = '1234abcd5678hijk90lm').
	self assert: ((subRope asString) = 'abcd5678hijk').
	self assert: ((concRope1 asString) = 'abcd5678hijk new string tail').
	self assert: ((concRope2 asString) =
				 'abcd5678hijk new string tailabcd5678hijk new string tail').
	self assert: ((concRope3 asString) =  'Now is the time abcd5678hijk').
	
	self assert: ((flatRope printString) =  'Rope(''1234abcd5678hijk90lm'')' ).
	self assert: ((subRope printString) =  'Rope(''abcd5678hijk'')' ).
	self assert: ((concRope1 printString) =  'Rope(''abcd5678hijk new string tail'')' ).
	self assert: ((concRope2 printString) =
				  'Rope(''abcd5678hijk new string tailabcd5678hijk new string tail'')' ).
	self assert: ((concRope3 printString) =  'Rope(''Now is the time abcd5678hijk'')').
! !

!RopeTest methodsFor: 'testing' stamp: 'KenD 2/15/2013 21:05'!
testRebalance

	| fr1 fr2 t1 t2 |
	fr1 := FlatRope fromString: '12345678901234567890'.
	fr2 := FlatRope fromString: 'abcdefghijklmnopqrstuvwxyz'.
	t1 := (fr1, fr2, fr1, fr2, fr1, fr2, fr1, fr2).
	t2 := (fr1, concRope1, fr2, concRope2, fr1, fr2, fr1, fr2, concRope3, fr1, fr2).

	self assert: ( t1 depth = 7 ).
	self assert: ( t1 rebalance depth = 3 ).
	self assert: ( t2 depth = 11 ).
	self assert: ( t2 rebalance depth = 4 ).! !

!RopeTest methodsFor: 'testing' stamp: 'KenD 2/11/2013 18:50'!
testSubstring
	"Can we copy?"

	self assert: ((flatRope copyFrom: 5 to: 8) asString = 'abcd').
	self assert: ((flatRope copyFrom: 1 to: (flatRope size)) == flatRope). "return self"
	self should: [flatRope copyFrom: -3 to: 5] raise: Error.
	self should: [flatRope copyFrom: 2 to: 55] raise: Error.
	self assert: ((flatRope copyFrom: 10 to: 5) asString = '' ).

	self assert: ((subRope copyFrom: 5 to: 8) asString = '5678').
	self should: [subRope copyFrom: -3 to: 5] raise: Error.
	self should: [subRope copyFrom: 2 to: 55] raise: Error.
	self assert: ((subRope copyFrom: 10 to: 5) asString = '' ).


	"from left rope"
	self assert: ((concRope1 copyFrom: 2 to:5) asString = 'bcd5').
	"fron right rope"
	self assert: ((concRope1  copyFrom: 14 to: 16) asString = 'new').
	"copy spans both ropes"
	self assert: ((concRope1  copyFrom: 9 to: 16) asString = 'hijk new').

	self should: [concRope1 copyFrom: -3 to: 5] raise: Error.
	self should: [concRope1 copyFrom: 2 to: 55] raise: Error.
	self assert: ((concRope1 copyFrom: 10 to: 5) asString = '' ).

	"span above meld trreshold"
	self assert: ((concRope2 copyFrom: 22 to:30) asString = 'ng tailab').
	self assert: ((concRope3 copyFrom: 12 to: 20) asString =  'time abcd').
	"span is less than meld threshold"
	self assert: ((concRope2 copyFrom: 26 to: 30) asString = 'ailab').
	self assert: ((concRope3 copyFrom: 14 to: 18) asString =  'me ab').
	
	self assert: ((concRope1 copyReplaceFrom: 9 to: 19  with: '@@ new stuff @@') asString
					=  'abcd5678@@ new stuff @@ring tail' ).
	self assert: ((concRope1 copyReplaceFrom: 9 to: 9  with: '@@ new stuff @@') asString
					=  'abcd5678@@ new stuff @@ijk new string tail' ).

! !

!String methodsFor: '*ropes' stamp: 'KenD 2/9/2013 19:48'!
asRope

	^FlatRope fromString: self! !

!SubRope methodsFor: 'accessing' stamp: 'KenD 2/9/2013 19:30'!
at: anIndex

	^self string at: (anIndex + startIndex - 1)! !

!SubRope methodsFor: 'accessing' stamp: 'KenD 2/10/2013 19:31'!
at: index put: aCharacter 

	"Answer a new rope"
	| offsetIndex startIndex endIndex |
	
	startIndex := self startIndex.
	endIndex := startIndex + self size - 1.
	offsetIndex := index +  startIndex - 1.
	
	(self size = 1)
	ifTrue:  [
		(offsetIndex = 1)
		ifTrue: [^ aCharacter asRope]
		ifFalse: [self errorSubscriptBounds: index]
	].
	
	(index = 1)
	ifTrue: [ ^ aCharacter asRope , (self copyFrom: 2 to: self size)].
	
	(offsetIndex = endIndex)
	ifTrue: [ ^ (self copyFrom: 1 to: (index - 1)) , aCharacter asRope ].
	
	^ (self copyFrom: 1 to: (index - 1)) ,
	   aCharacter asRope ,
	   (self copyFrom: (index + 1) to: self size )! !

!SubRope methodsFor: 'copying' stamp: 'KenD 2/11/2013 17:11'!
copyFrom: start to: stop 
	"Answer a SubRope which shares my string"
	
	| offsetStart offsetStop |
	offsetStart := start - 1 + self startIndex.
	offsetStop := stop  - 1 + self startIndex.
	
	"Handle odd case the same way as OrderedCollection"
	(stop < start) ifTrue: [^ FlatRope fromString: ''].

	((1 <= start) and: [stop <= (self string size)])
	ifTrue: [
		^(SubRope new initialize 
			string: (self string) 
			startIndex: offsetStart
			length: (stop - start + 1))
	]
	ifFalse: [
		(offsetStop > self string size) 
		ifTrue: [self errorSubscriptBounds: stop]
		ifFalse: [self errorSubscriptBounds: start]
	]! !

!SubRope methodsFor: 'private' stamp: 'KenD 2/12/2013 14:21'!
depth
	"I am a leaf"

	^0! !

!SubRope methodsFor: 'enumerating' stamp: 'KenD 2/15/2013 21:46'!
do: aBlock
	"aBlock takes each Character in me as an argument"

	| start end string |
	start := self startIndex.
	end := start + self size - 1.
	string := self string.
	start to: end do: [ :index |  aBlock value: (string at: index) ]! !

!SubRope methodsFor: 'accessing' stamp: 'KenD 2/8/2013 19:30'!
size
	^length! !

!SubRope methodsFor: 'private' stamp: 'KenD 2/8/2013 19:29'!
startIndex
	^startIndex! !

!SubRope methodsFor: 'private' stamp: 'KenD 2/9/2013 16:19'!
string
	^theString! !

!SubRope methodsFor: 'initialize-release' stamp: 'KenD 2/9/2013 19:29'!
string: aString startIndex: anIndex length: numberOfChars
	
	startIndex := anIndex.
	length := numberOfChars.
	theString := aString.
	
	"Idiot checks"
	(aString size < (numberOfChars - anIndex + 1))
	ifTrue: [self error: 'Length exceeds max' , (numberOfChars - anIndex + 1) printString ].
	
	(numberOfChars < 0)
	ifTrue: [self error: 'Can''t have negative length' , numberOfChars].
	
	((anIndex < 1) or: (anIndex > aString size))
	ifTrue: [self errorSubscriptBounds: anIndex].
	
	^self! !
ConcatRope initialize!
Rope initialize!
