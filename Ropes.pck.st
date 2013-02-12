'From Cuis 4.1 of 12 December 2012 [latest update: #1590] on 11 February 2013 at 7:23:51 pm'!
'Description Please enter a description for this package '!
!classDefinition: #Rope category: #Ropes!
ArrayedCollection subclass: #Rope
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Ropes'!
!classDefinition: 'Rope class' category: #Ropes!
Rope class
	instanceVariableNames: ''!

!classDefinition: #ConcatRope category: #Ropes!
Rope subclass: #ConcatRope
	instanceVariableNames: 'leftLength totalLength leftRope rightRope'
	classVariableNames: ''
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
	instanceVariableNames: 'flatRope subRope concRope1 concRope2 concRope3'
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
!

!RopeTest commentStamp: '<historical>' prior: 0!
Test Cases for Ropes!

!SubRope commentStamp: '<historical>' prior: 0!
I refer to an immutable string shared with another Rope.!

!Character methodsFor: '*ropes' stamp: 'KenD 2/9/2013 20:08'!
asRope
	"Answer self as a rope"

	^self asString asRope! !

!ConcatRope methodsFor: 'accessing' stamp: 'KenD 2/9/2013 19:38'!
at: anIndex

	(anIndex <= self leftLength)
	ifTrue: [^leftRope at: anIndex]
	ifFalse: [^rightRope at: (anIndex - leftLength)]! !

!ConcatRope methodsFor: 'accessing' stamp: 'KenD 2/10/2013 19:35'!
at: index put: aCharacter 

	"Answer a new rope"
	(index <= self leftLength)
	ifTrue: [ ^ (self leftRope at: index put: aCharacter) , self rightRope]
	ifFalse: [ ^ self leftRope ,
		          (self rightRope at: (index - self leftLength) put: aCharacter)]! !

!ConcatRope methodsFor: 'copying' stamp: 'KenD 2/11/2013 17:12'!
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

	leftMaxIndex := self leftLength.
	
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

!ConcatRope methodsFor: 'private' stamp: 'KenD 2/8/2013 16:58'!
leftLength
	
	^leftLength! !

!ConcatRope methodsFor: 'private' stamp: 'KenD 2/8/2013 16:58'!
leftRope
	
	^leftRope! !

!ConcatRope methodsFor: 'private' stamp: 'KenD 2/10/2013 15:48'!
meldThreshold

	"Answer combined size below which we should meld short strings together"
	^ 10! !

!ConcatRope methodsFor: 'private' stamp: 'KenD 2/8/2013 16:59'!
rightRope
	
	^rightRope! !

!ConcatRope methodsFor: 'accessing' stamp: 'KenD 2/8/2013 19:31'!
size

	^totalLength! !

!ConcatRope methodsFor: 'initialize-release' stamp: 'KenD 2/10/2013 15:45'!
withLeft: aRope andRight: anotherRope

	leftRope := aRope asRope.
	leftLength := aRope size.
	rightRope := anotherRope asRope.
	totalLength := leftLength + anotherRope size.
	
	(totalLength < (self meldThreshold))
	"@@FIXME: optimize the meld case @@"
	ifTrue: [ ^ FlatRope fromString: ((aRope asString) , (anotherRope asString))]
	ifFalse: [ ^self ]! !

!ConcatRope class methodsFor: 'instance creation' stamp: 'KenD 2/10/2013 15:44'!
concatenate: aRope with: otherRope
	"Answer a new ConcatRope"

	"Don't bother to concat zero length ropes"
	(aRope size = 0)
		ifTrue: [^otherRope asRope].
		
	(otherRope size = 0)
		ifTrue: [^aRope asRope].

	"Non-trivial. Answer a new instance"	
	^(self new initialize withLeft: aRope andRight: otherRope)! !

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

!Rope methodsFor: 'printing' stamp: 'KenD 2/9/2013 19:36'!
stringRepresentation

	^String streamContents: [:s | self do: [ :char | s nextPut: char]]! !

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

!RopeTest methodsFor: 'testing' stamp: 'KenD 2/10/2013 14:47'!
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
 ! !

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
