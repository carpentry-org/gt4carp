Class {
	#name : #CarpParser,
	#superclass : #SmaCCGLRParser,
	#category : #'Carp-Parser'
}

{ #category : #'generated-accessing' }
CarpParser class >> cacheId [
	^'2022-06-13T14:48:36.40126+02:00'
]

{ #category : #generated }
CarpParser class >> definitionComment [
"%glr;

%root Expression;
%prefix Carp;
%suffix Node;

%hierarchy Expression (
	Array
	Deref
	List
	Map
	ModuleOrType
	Pattern
	RefCall
	Ref
	Unquote
	Character
	Number
	Pair
	Quote
	Start
	String
	Variable
);

<escape>
	: \\ (. | u[0-9A-F]{4,4} | o[0-7]{3,3} | newline | return | space | tab | space | backspace | formfeed)	# other character types
	;
<string_literal>
	: \"" ([^\""\\] | <escape>)* \""
	;
<open_paren>
	: \(
	;
<close_paren>
	: \)
	;
<quote>
	: \' | \`
	;
<variable_start>
	: <isLowercase> | _ | \$ | \+ | \* | \/ | \? | ! | > | < | = | : | -
	;
default <variable>
	: <variable_start> <variable_part>*
	;
<variable_part>
	: <variable_start> | <isDigit> | <isUppercase>
	;
<module>
	: <isUppercase> <variable_part>*
	;
<dot>
	: \.
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
<sign>
	: \-
	;
<decimal>
	: <sign>? (<decimal_integer> \. <decimal_integer> f?)
|	<sign>? (<decimal_integer> (f|l|b)?)
	;
<numeric_literal>
	: <decimal> | <hex_integer> | <binary_integer> 
	;
<comment>
	: \; [^\r\n]*
	| \,	# commas are treated as whitespace, but whitespace is not saved, so I made them comments instead
	;
<whitespace>
	: \s+
	;
<character>
	: \\ (. | u[0-9A-F]{4,4} | o[0-7]{3,3} | newline | return | space | tab | space | backspace | formfeed)	# other character types
	;Start 
	: Expressions {{}}
	;
Expressions
	:
	| Expressions Expression 'expression'
	;
Expression
	: Literal
	| Deref
	| Ref
	| RefCall
	| Unquote
	;
RefCall
	: ""~"" 'refGlyph' Expression 'value' {{}}
	;
Unquote
	: (""%"" 'unquoteGlyph' | ""%@""'unquoteGlyph') Expression 'value' {{}}
	;
Ref
	: ""&"" 'refGlyph' Expression 'value' {{}}
	;
Deref
	: ""@"" 'derefGlyph' Expression 'value' {{}}
	;
Literal
	: String | List | Array | Symbol | Quote | Number | Character | Pattern | Map
	;
Map
	: ""{"" 'leftBrace' MapPairs ""}"" 'rightBrace' {{}}
	;
MapPairs
	:
	| MapPairs MapPair 'pair'
	;
MapPair
	: Expression 'key' Expression 'value' {{Pair}}
	;
Pattern
	: ""#"" 'patternGlyph' <string_literal> 'value' {{}}
	;
Character
	: <character> 'value' {{}}
	;
Number
	: <numeric_literal> 'value' {{}} 
	;
Array
	: <open_bracket> 'leftBracket' Expressions <close_bracket> 'rightBracket' {{}}
	;
Quote
	: <quote> Expression 'value' {{}}
	;
Symbol
	: ModuleOrType | Variable
	;
Variable
	: <variable> 'value' {{}}
	;
ModuleOrType
	: <module> 'module' <dot> Symbol 'value' {{}}
	| <module> 'module' {{}}
	;
List
	: <open_paren> 'leftParen' Expressions <close_paren> 'rightParen' {{}}
	;
String
	: <string_literal> 'value' {{}}
	;"
]

{ #category : #generated }
CarpParser class >> reduceTable [
^#(
	#(24 0 #reduceActionForExpressions1: 1449985 false) 
	#(23 1 #reduceActionForStart1: 1419265 false) 
	#(32 0 #reduceActionForExpressions1: 1964033 false) 
	#(43 1 #reduceActionForString1: 2607105 false) 
	#(40 1 #reduceActionForVariable1: 2394113 false) 
	#(41 1 #reduceActionForModuleOrType2: 2434050 false) 
	#(36 1 #reduceActionForNumber1: 2173953 false) 
	#(35 1 #reduceActionForCharacter1: 2131969 false) 
	#(24 2 #reduceActionForExpressions2: 1449986 false) 
	#(25 1 #liftFirstValue: 1508356 false) 
	#(25 1 #liftFirstValue: 1508357 false) 
	#(25 1 #liftFirstValue: 1508355 false) 
	#(25 1 #liftFirstValue: 1508354 false) 
	#(25 1 #liftFirstValue: 1508353 false) 
	#(30 1 #liftFirstValue: 1813513 false) 
	#(30 1 #liftFirstValue: 1813512 false) 
	#(30 1 #liftFirstValue: 1813511 false) 
	#(30 1 #liftFirstValue: 1813510 false) 
	#(30 1 #liftFirstValue: 1813507 false) 
	#(30 1 #liftFirstValue: 1813509 false) 
	#(30 1 #liftFirstValue: 1813508 false) 
	#(39 1 #liftFirstValue: 2356226 false) 
	#(39 1 #liftFirstValue: 2356225 false) 
	#(30 1 #liftFirstValue: 1813506 false) 
	#(30 1 #liftFirstValue: 1813505 false) 
	#(34 2 #reduceActionForPattern1: 2067457 false) 
	#(27 2 #reduceActionForUnquote1: 1627137 false) 
	#(27 2 #reduceActionForUnquote1: 1627138 false) 
	#(28 2 #reduceActionForRef1: 1709057 false) 
	#(29 2 #reduceActionForDeref1: 1759233 false) 
	#(26 2 #reduceActionForRefCall1: 1572865 false) 
	#(38 2 #reduceActionForQuote1: 2311169 false) 
	#(31 3 #reduceActionForMap1: 1905665 false) 
	#(32 2 #reduceActionForExpressions2: 1964034 false) 
	#(42 3 #reduceActionForList1: 2525185 false) 
	#(41 3 #reduceActionForModuleOrType1: 2434049 false) 
	#(37 3 #reduceActionForArray1: 2220033 false) 
	#(33 2 #reduceActionForMapPair1: 2007041 false)
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

	^ #( '"#"' '"%"' '"%@"' '"&"' '"@"' '"{"' '"}"' '"~"' '<string_literal>'
	     '<open_paren>' '<close_paren>' '<quote>' '<variable>'
	     '<module>' '<dot>' '<open_bracket>' '<close_bracket>'
	     '<numeric_literal>' '<comment>' '<whitespace>' '<character>'
	     'B e g i n' 'Start' 'Expressions' 'Expression' 'RefCall'
	     'Unquote' 'Ref' 'Deref' 'Literal' 'Map' 'MapPairs' 'MapPair'
	     'Pattern' 'Character' 'Number' 'Array' 'Quote' 'Symbol' 'Variable'
	     'ModuleOrType' 'List' 'String' 'E O F' 'error' )
]

{ #category : #generated }
CarpParser class >> symbolTypes [

	^ #( #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken
	     #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken
	     #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken
	     #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken
	     #SmaCCToken #CarpStartNode #CarpStartNode #OrderedCollection
	     #CarpExpressionNode #CarpRefCallNode #CarpUnquoteNode
	     #CarpRefNode #CarpDerefNode #CarpExpressionNode
	     #CarpMapNode #OrderedCollection #CarpPairNode #CarpPatternNode
	     #CarpCharacterNode #CarpNumberNode #CarpArrayNode #CarpQuoteNode
	     #CarpExpressionNode #CarpVariableNode #CarpModuleOrTypeNode
	     #CarpListNode #CarpStringNode #SmaCCToken #SmaCCErrorNode )
]

{ #category : #generated }
CarpParser class >> transitionTable [
^#(
#[1 0 6 0 1 0 6 0 2 0 6 0 3 0 6 0 4 0 6 0 5 0 6 0 6 0 6 0 8 0 6 0 9 0 6 0 10 0 6 0 12 0 6 0 13 0 6 0 14 0 6 0 16 0 6 0 18 0 6 0 21 0 9 0 23 0 13 0 24 0 6 0 44] 
#[0 0 0 0 44] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 13 0 61 0 14 0 65 0 16 0 69 0 18 0 73 0 21 0 77 0 25 0 77 0 26 0 77 0 27 0 77 0 28 0 77 0 29 0 77 0 30 0 77 0 31 0 77 0 34 0 77 0 35 0 77 0 36 0 77 0 37 0 77 0 38 0 77 0 39 0 77 0 40 0 77 0 41 0 77 0 42 0 77 0 43 0 10 0 44] 
#[0 0 145 0 9] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 13 0 61 0 14 0 65 0 16 0 69 0 18 0 73 0 21 0 149 0 25 0 149 0 26 0 149 0 27 0 149 0 28 0 149 0 29 0 149 0 30 0 149 0 31 0 149 0 34 0 149 0 35 0 149 0 36 0 149 0 37 0 149 0 38 0 149 0 39 0 149 0 40 0 149 0 41 0 149 0 42 0 149 0 43] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 13 0 61 0 14 0 65 0 16 0 69 0 18 0 73 0 21 0 153 0 25 0 153 0 26 0 153 0 27 0 153 0 28 0 153 0 29 0 153 0 30 0 153 0 31 0 153 0 34 0 153 0 35 0 153 0 36 0 153 0 37 0 153 0 38 0 153 0 39 0 153 0 40 0 153 0 41 0 153 0 42 0 153 0 43] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 13 0 61 0 14 0 65 0 16 0 69 0 18 0 73 0 21 0 157 0 25 0 157 0 26 0 157 0 27 0 157 0 28 0 157 0 29 0 157 0 30 0 157 0 31 0 157 0 34 0 157 0 35 0 157 0 36 0 157 0 37 0 157 0 38 0 157 0 39 0 157 0 40 0 157 0 41 0 157 0 42 0 157 0 43] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 13 0 61 0 14 0 65 0 16 0 69 0 18 0 73 0 21 0 161 0 25 0 161 0 26 0 161 0 27 0 161 0 28 0 161 0 29 0 161 0 30 0 161 0 31 0 161 0 34 0 161 0 35 0 161 0 36 0 161 0 37 0 161 0 38 0 161 0 39 0 161 0 40 0 161 0 41 0 161 0 42 0 161 0 43] 
#[1 0 14 0 1 0 14 0 2 0 14 0 3 0 14 0 4 0 14 0 5 0 14 0 6 0 14 0 7 0 14 0 8 0 14 0 9 0 14 0 10 0 14 0 12 0 14 0 13 0 14 0 14 0 14 0 16 0 14 0 18 0 14 0 21 0 165 0 32] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 13 0 61 0 14 0 65 0 16 0 69 0 18 0 73 0 21 0 169 0 25 0 169 0 26 0 169 0 27 0 169 0 28 0 169 0 29 0 169 0 30 0 169 0 31 0 169 0 34 0 169 0 35 0 169 0 36 0 169 0 37 0 169 0 38 0 169 0 39 0 169 0 40 0 169 0 41 0 169 0 42 0 169 0 43] 
#[0 0 18 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[1 0 6 0 1 0 6 0 2 0 6 0 3 0 6 0 4 0 6 0 5 0 6 0 6 0 6 0 8 0 6 0 9 0 6 0 10 0 6 0 11 0 6 0 12 0 6 0 13 0 6 0 14 0 6 0 16 0 6 0 18 0 6 0 21 0 173 0 24] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 13 0 61 0 14 0 65 0 16 0 69 0 18 0 73 0 21 0 177 0 25 0 177 0 26 0 177 0 27 0 177 0 28 0 177 0 29 0 177 0 30 0 177 0 31 0 177 0 34 0 177 0 35 0 177 0 36 0 177 0 37 0 177 0 38 0 177 0 39 0 177 0 40 0 177 0 41 0 177 0 42 0 177 0 43] 
#[0 0 22 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[1 0 26 0 1 0 26 0 2 0 26 0 3 0 26 0 4 0 26 0 5 0 26 0 6 0 26 0 7 0 26 0 8 0 26 0 9 0 26 0 10 0 26 0 11 0 26 0 12 0 26 0 13 0 26 0 14 0 181 0 15 0 26 0 16 0 26 0 17 0 26 0 18 0 26 0 21 0 26 0 44] 
#[1 0 6 0 1 0 6 0 2 0 6 0 3 0 6 0 4 0 6 0 5 0 6 0 6 0 6 0 8 0 6 0 9 0 6 0 10 0 6 0 12 0 6 0 13 0 6 0 14 0 6 0 16 0 6 0 17 0 6 0 18 0 6 0 21 0 185 0 24] 
#[0 0 30 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 34 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 38 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 42 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 46 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 50 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 54 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 58 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 62 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 66 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 70 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 74 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 78 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 82 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 86 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 90 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 94 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 98 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 102 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 106 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 110 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 114 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 118 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 122 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 189 0 7 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 13 0 61 0 14 0 65 0 16 0 69 0 18 0 73 0 21 0 193 0 25 0 193 0 26 0 193 0 27 0 193 0 28 0 193 0 29 0 193 0 30 0 193 0 31 0 197 0 33 0 193 0 34 0 193 0 35 0 193 0 36 0 193 0 37 0 193 0 38 0 193 0 39 0 193 0 40 0 193 0 41 0 193 0 42 0 193 0 43] 
#[0 0 126 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 201 0 11 0 53 0 12 0 57 0 13 0 61 0 14 0 65 0 16 0 69 0 18 0 73 0 21 0 77 0 25 0 77 0 26 0 77 0 27 0 77 0 28 0 77 0 29 0 77 0 30 0 77 0 31 0 77 0 34 0 77 0 35 0 77 0 36 0 77 0 37 0 77 0 38 0 77 0 39 0 77 0 40 0 77 0 41 0 77 0 42 0 77 0 43] 
#[0 0 130 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[1 0 57 0 13 0 61 0 14 0 205 0 39 0 205 0 40 0 205 0 41] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 13 0 61 0 14 0 65 0 16 0 209 0 17 0 69 0 18 0 73 0 21 0 77 0 25 0 77 0 26 0 77 0 27 0 77 0 28 0 77 0 29 0 77 0 30 0 77 0 31 0 77 0 34 0 77 0 35 0 77 0 36 0 77 0 37 0 77 0 38 0 77 0 39 0 77 0 40 0 77 0 41 0 77 0 42 0 77 0 43] 
#[0 0 134 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 13 0 61 0 14 0 65 0 16 0 69 0 18 0 73 0 21 0 213 0 25 0 213 0 26 0 213 0 27 0 213 0 28 0 213 0 29 0 213 0 30 0 213 0 31 0 213 0 34 0 213 0 35 0 213 0 36 0 213 0 37 0 213 0 38 0 213 0 39 0 213 0 40 0 213 0 41 0 213 0 42 0 213 0 43] 
#[0 0 138 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 16 0 18 0 21] 
#[0 0 142 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 146 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 150 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 13 0 14 0 16 0 17 0 18 0 21 0 44] 
#[0 0 154 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 16 0 18 0 21]
	).
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForArray1: nodes [

	| result |
	result := CarpArrayNode new.
	result leftBracket: (nodes at: 1).
	result addNodes: (nodes at: 2) to: result expressions.
	result rightBracket: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForCharacter1: nodes [

	| result |
	result := CarpCharacterNode new.
	result value: (nodes at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForDeref1: nodes [

	| result |
	result := CarpDerefNode new.
	result derefGlyph: (nodes at: 1).
	result value: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForExpressions1: nodes [

	| result |
	result := OrderedCollection new: 2.
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForExpressions2: nodes [

	| result |
	result := nodes at: 1.
	self add: (nodes at: 2) to: result.
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForList1: nodes [

	| result |
	result := CarpListNode new.
	result leftParen: (nodes at: 1).
	result addNodes: (nodes at: 2) to: result expressions.
	result rightParen: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForMap1: nodes [

	| result |
	result := CarpMapNode new.
	result leftBrace: (nodes at: 1).
	result addNodes: (nodes at: 2) to: result pairs.
	result rightBrace: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForMapPair1: nodes [

	| result |
	result := CarpPairNode new.
	result key: (nodes at: 1).
	result value: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForModuleOrType1: nodes [

	| result |
	result := CarpModuleOrTypeNode new.
	result module: (nodes at: 1).
	result value: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForModuleOrType2: nodes [

	| result |
	result := CarpModuleOrTypeNode new.
	result module: (nodes at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForNumber1: nodes [

	| result |
	result := CarpNumberNode new.
	result value: (nodes at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForPattern1: nodes [

	| result |
	result := CarpPatternNode new.
	result patternGlyph: (nodes at: 1).
	result value: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForQuote1: nodes [

	| result |
	result := CarpQuoteNode new.
	result value: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForRef1: nodes [

	| result |
	result := CarpRefNode new.
	result refGlyph: (nodes at: 1).
	result value: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForRefCall1: nodes [

	| result |
	result := CarpRefCallNode new.
	result refGlyph: (nodes at: 1).
	result value: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForStart1: nodes [

	| result |
	result := CarpStartNode new.
	result addNodes: (nodes at: 1) to: result expressions.
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForString1: nodes [

	| result |
	result := CarpStringNode new.
	result value: (nodes at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForUnquote1: nodes [

	| result |
	result := CarpUnquoteNode new.
	result unquoteGlyph: (nodes at: 1).
	result value: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForVariable1: nodes [

	| result |
	result := CarpVariableNode new.
	result value: (nodes at: 1).
	^ result
]
