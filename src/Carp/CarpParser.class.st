Class {
	#name : #CarpParser,
	#superclass : #SmaCCGLRParser,
	#category : #Carp
}

{ #category : #'generated-accessing' }
CarpParser class >> cacheId [
	^'2020-10-05T22:57:25.346883+02:00'
]

{ #category : #generated }
CarpParser class >> definitionComment [
"%glr;

<hexa>
	: [0-9a-fA-F]
	;
<escape>
	: \\ ([^\r\n] | (u <hexa>{4,4}))+
	;
<string_literal>
	: (\"" ([^\""\\] | <escape>)* \"")
	;
<open_paren>
	: \(
	;
<close_paren>
	: \)
	;
<quote>
	: \'
	;
<variable_start>
	: <isLowercase> | _ | \$ | \+ | \* | \/ | \? | ! | > | < | = | :
	;
default <variable>
	: <variable_start> <variable_part>*
	;
<variable_part>
	: <variable_start> | <isDigit>
	;
<module>
	: <isUppercase> <variable_part>*
	;
<space>
	: (<isSpaceSeparator> | ,)+
	;
<dot>
	: \.
	;
<Symbol>
	: a
	;
<open_bracket>
	: \[
	;
<close_bracket>
	: \]
	;
<binary_integer>
	: 0 b [0-1]
	;
<hex_integer>
	: 0 x [0-9a-fA-F]
	;
<decimal_integer>
	: [0-9]+
	;
<decimal>
	: (<decimal_integer> \. <decimal_integer> f?)
|	(<decimal_integer> (f|l|b)?)
	;
<numeric_literal>
	: <decimal> | <hex_integer> | <binary_integer> 
	;Start 
	: Expression+
	;
Expression
	: Literal
	;
Literal
	: String | List | Array | Symbol | Quote | Number
	;
Number
	: <numeric_literal>
	;
Array
	: <open_bracket> ListContents <close_bracket>
	;
Quote
	: <quote> Expression
	;
Symbol
	: ModuleOrType | Variable
	;
Variable
	: <variable>
	;
ModuleOrType
	: <module> <dot> Symbol
	| <module>
	;
List
	: <open_paren> ListContents <close_paren>
	;
ListContents
	: Expression <space> ListContents
	| Expression
	;
String
	: <string_literal>
	;"
]

{ #category : #generated }
CarpParser class >> reduceTable [
^#(
	#(25 1 #reduceFor: 1310721 false ) 
	#(21 1 #reduceFor: 1111041 false ) 
	#(22 1 #reduceFor: 1137666 false ) 
	#(17 1 #reduceFor: 952321 false ) 
	#(13 1 #reduceFor: 837633 false ) 
	#(14 1 #reduceFor: 847873 false ) 
	#(15 1 #reduceFor: 863233 false ) 
	#(16 1 #reduceFor: 888838 false ) 
	#(16 1 #reduceFor: 888835 false ) 
	#(16 1 #reduceFor: 888837 false ) 
	#(16 1 #reduceFor: 888836 false ) 
	#(20 1 #reduceFor: 1073154 false ) 
	#(20 1 #reduceFor: 1073153 false ) 
	#(16 1 #reduceFor: 888834 false ) 
	#(16 1 #reduceFor: 888833 false ) 
	#(24 1 #reduceFor: 1244162 false ) 
	#(19 2 #reduceFor: 1041409 false ) 
	#(14 2 #reduceFor: 847874 false ) 
	#(23 3 #reduceFor: 1191937 false ) 
	#(22 3 #reduceFor: 1137665 false ) 
	#(18 3 #reduceFor: 984065 false ) 
	#(24 3 #reduceFor: 1244161 false )
	).
]

{ #category : #generated }
CarpParser class >> scannerClass [
	^CarpScanner
]

{ #category : #generated }
CarpParser class >> startingStateForStart [
	^ 1
]

{ #category : #generated }
CarpParser class >> symbolNames [
	^ #('<string_literal>' '<open_paren>' '<close_paren>' '<quote>' '<variable>' '<module>' '<space>' '<dot>' '<open_bracket>' '<close_bracket>' '<numeric_literal>' 'B e g i n' 'Start' 'Expression+' 'Expression' 'Literal' 'Number' 'Array' 'Quote' 'Symbol' 'Variable' 'ModuleOrType' 'List' 'ListContents' 'String' 'E O F' 'error')
]

{ #category : #generated }
CarpParser class >> transitionTable [
^#(
#[1 0 9 0 1 0 13 0 2 0 17 0 4 0 21 0 5 0 25 0 6 0 29 0 9 0 33 0 11 0 37 0 13 0 41 0 14 0 45 0 15 0 49 0 16 0 53 0 17 0 57 0 18 0 61 0 19 0 65 0 20 0 69 0 21 0 73 0 22 0 77 0 23 0 81 0 25] 
#[0 0 6 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[1 0 9 0 1 0 13 0 2 0 17 0 4 0 21 0 5 0 25 0 6 0 29 0 9 0 33 0 11 0 85 0 15 0 49 0 16 0 53 0 17 0 57 0 18 0 61 0 19 0 65 0 20 0 69 0 21 0 73 0 22 0 77 0 23 0 89 0 24 0 81 0 25] 
#[1 0 9 0 1 0 13 0 2 0 17 0 4 0 21 0 5 0 25 0 6 0 29 0 9 0 33 0 11 0 93 0 15 0 49 0 16 0 53 0 17 0 57 0 18 0 61 0 19 0 65 0 20 0 69 0 21 0 73 0 22 0 77 0 23 0 81 0 25] 
#[0 0 10 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[1 0 14 0 1 0 14 0 2 0 14 0 3 0 14 0 4 0 14 0 5 0 14 0 6 0 14 0 7 0 97 0 8 0 14 0 9 0 14 0 10 0 14 0 11 0 14 0 26] 
#[1 0 9 0 1 0 13 0 2 0 17 0 4 0 21 0 5 0 25 0 6 0 29 0 9 0 33 0 11 0 85 0 15 0 49 0 16 0 53 0 17 0 57 0 18 0 61 0 19 0 65 0 20 0 69 0 21 0 73 0 22 0 77 0 23 0 101 0 24 0 81 0 25] 
#[0 0 18 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[0 0 0 0 26] 
#[1 0 9 0 1 0 13 0 2 0 17 0 4 0 21 0 5 0 25 0 6 0 29 0 9 0 33 0 11 0 105 0 15 0 49 0 16 0 53 0 17 0 57 0 18 0 61 0 19 0 65 0 20 0 69 0 21 0 73 0 22 0 77 0 23 0 81 0 25 0 22 0 26] 
#[0 0 26 0 1 0 2 0 4 0 5 0 6 0 9 0 11 0 26] 
#[0 0 30 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[0 0 34 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[0 0 38 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[0 0 42 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[0 0 46 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[0 0 50 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[0 0 54 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[0 0 58 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[0 0 62 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[1 0 66 0 3 0 109 0 7 0 66 0 10] 
#[0 0 113 0 3] 
#[0 0 70 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[1 0 21 0 5 0 25 0 6 0 117 0 20 0 69 0 21 0 73 0 22] 
#[0 0 121 0 10] 
#[0 0 74 0 1 0 2 0 4 0 5 0 6 0 9 0 11 0 26] 
#[1 0 9 0 1 0 13 0 2 0 17 0 4 0 21 0 5 0 25 0 6 0 29 0 9 0 33 0 11 0 85 0 15 0 49 0 16 0 53 0 17 0 57 0 18 0 61 0 19 0 65 0 20 0 69 0 21 0 73 0 22 0 77 0 23 0 125 0 24 0 81 0 25] 
#[0 0 78 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[0 0 82 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[0 0 86 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 9 0 10 0 11 0 26] 
#[0 0 90 0 3 0 10]
	).
]
