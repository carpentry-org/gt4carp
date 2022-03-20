Class {
	#name : #CarpParser,
	#superclass : #SmaCCGLRParser,
	#category : #Carp
}

{ #category : #'generated-accessing' }
CarpParser class >> cacheId [
	^'2022-03-20T19:54:13.067877+01:00'
]

{ #category : #generated }
CarpParser class >> definitionComment [
"%glr;

%root Expression;
%prefix Carp;
%suffix Node;
<escape>
	: \\ (. | u[0-9A-F]{4,4} | o[0-7]{3,3} | newline | return | space | tab | space | backspace | formfeed)	# other character types
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
<decimal>
	: (<decimal_integer> \. <decimal_integer> f?)
|	(<decimal_integer> (f|l|b)?)
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
	| Unquote
	;
Unquote
	: (""%"" | ""%@"") Expression 'value' {{}}
	;
Ref
	: ""&"" Expression 'value' {{}}
	;
Deref
	: ""@"" Expression 'value' {{}}
	;
Literal
	: String | List | Array | Symbol | Quote | Number | Character 
	;
Character
	: <character> 'value' {{}}
	;
Number
	: <numeric_literal> 'value' {{}} 
	;
Array
	: <open_bracket> Expressions <close_bracket> {{}}
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
	: <module> <dot> Symbol 'value' {{}}
	| <module> 'value' {{}}
	;
List
	: <open_paren> Expressions <close_paren> {{}}
	;
String
	: <string_literal> 'value' {{}}
	;"
]

{ #category : #generated }
CarpParser class >> reduceTable [
^#(
	#(20 0 #reduceActionForExpressions1: 1258497 false) 
	#(19 1 #reduceActionForStart1: 1227777 false) 
	#(34 1 #reduceActionForString1: 1988609 false) 
	#(31 1 #reduceActionForVariable1: 1811457 false) 
	#(32 1 #reduceActionForModuleOrType2: 1851394 false) 
	#(27 1 #reduceActionForNumber1: 1620993 false) 
	#(26 1 #reduceActionForCharacter1: 1579009 false) 
	#(20 2 #reduceActionForExpressions2: 1258498 false) 
	#(21 1 #liftFirstValue: 1316868 false) 
	#(21 1 #liftFirstValue: 1316867 false) 
	#(21 1 #liftFirstValue: 1316866 false) 
	#(21 1 #liftFirstValue: 1316865 false) 
	#(25 1 #liftFirstValue: 1502215 false) 
	#(25 1 #liftFirstValue: 1502214 false) 
	#(25 1 #liftFirstValue: 1502211 false) 
	#(25 1 #liftFirstValue: 1502213 false) 
	#(25 1 #liftFirstValue: 1502212 false) 
	#(30 1 #liftFirstValue: 1773570 false) 
	#(30 1 #liftFirstValue: 1773569 false) 
	#(25 1 #liftFirstValue: 1502210 false) 
	#(25 1 #liftFirstValue: 1502209 false) 
	#(22 2 #reduceActionForUnquote1: 1370113 false) 
	#(22 2 #reduceActionForUnquote1: 1370114 false) 
	#(23 2 #reduceActionForRef1: 1422337 false) 
	#(24 2 #reduceActionForDeref1: 1461249 false) 
	#(29 2 #reduceActionForQuote1: 1728513 false) 
	#(33 3 #reduceActionForList1: 1932289 false) 
	#(32 3 #reduceActionForModuleOrType1: 1851393 false) 
	#(28 3 #reduceActionForArray1: 1667073 false)
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

	^ #( '"%"' '"%@"' '"&"' '"@"' '<string_literal>' '<open_paren>'
	     '<close_paren>' '<quote>' '<variable>' '<module>' '<dot>'
	     '<open_bracket>' '<close_bracket>' '<numeric_literal>'
	     '<comment>' '<whitespace>' '<character>' 'B e g i n' 'Start'
	     'Expressions' 'Expression' 'Unquote' 'Ref' 'Deref' 'Literal'
	     'Character' 'Number' 'Array' 'Quote' 'Symbol' 'Variable'
	     'ModuleOrType' 'List' 'String' 'E O F' 'error' )
]

{ #category : #generated }
CarpParser class >> symbolTypes [

	^ #( #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken
	     #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken
	     #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken
	     #SmaCCToken #SmaCCToken #CarpStartNode #CarpStartNode
	     #OrderedCollection #CarpExpressionNode #CarpUnquoteNode
	     #CarpRefNode #CarpDerefNode #CarpExpressionNode
	     #CarpCharacterNode #CarpNumberNode #CarpArrayNode #CarpQuoteNode
	     #CarpExpressionNode #CarpVariableNode #CarpModuleOrTypeNode
	     #CarpListNode #CarpStringNode #SmaCCToken #SmaCCErrorNode )
]

{ #category : #generated }
CarpParser class >> transitionTable [
^#(
#[1 0 6 0 1 0 6 0 2 0 6 0 3 0 6 0 4 0 6 0 5 0 6 0 6 0 6 0 8 0 6 0 9 0 6 0 10 0 6 0 12 0 6 0 14 0 6 0 17 0 9 0 19 0 13 0 20 0 6 0 35] 
#[0 0 0 0 35] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 14 0 61 0 17 0 65 0 21 0 65 0 22 0 65 0 23 0 65 0 24 0 65 0 25 0 65 0 26 0 65 0 27 0 65 0 28 0 65 0 29 0 65 0 30 0 65 0 31 0 65 0 32 0 65 0 33 0 65 0 34 0 10 0 35] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 14 0 61 0 17 0 121 0 21 0 121 0 22 0 121 0 23 0 121 0 24 0 121 0 25 0 121 0 26 0 121 0 27 0 121 0 28 0 121 0 29 0 121 0 30 0 121 0 31 0 121 0 32 0 121 0 33 0 121 0 34] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 14 0 61 0 17 0 125 0 21 0 125 0 22 0 125 0 23 0 125 0 24 0 125 0 25 0 125 0 26 0 125 0 27 0 125 0 28 0 125 0 29 0 125 0 30 0 125 0 31 0 125 0 32 0 125 0 33 0 125 0 34] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 14 0 61 0 17 0 129 0 21 0 129 0 22 0 129 0 23 0 129 0 24 0 129 0 25 0 129 0 26 0 129 0 27 0 129 0 28 0 129 0 29 0 129 0 30 0 129 0 31 0 129 0 32 0 129 0 33 0 129 0 34] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 14 0 61 0 17 0 133 0 21 0 133 0 22 0 133 0 23 0 133 0 24 0 133 0 25 0 133 0 26 0 133 0 27 0 133 0 28 0 133 0 29 0 133 0 30 0 133 0 31 0 133 0 32 0 133 0 33 0 133 0 34] 
#[0 0 14 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[1 0 6 0 1 0 6 0 2 0 6 0 3 0 6 0 4 0 6 0 5 0 6 0 6 0 6 0 7 0 6 0 8 0 6 0 9 0 6 0 10 0 6 0 12 0 6 0 14 0 6 0 17 0 137 0 20] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 14 0 61 0 17 0 141 0 21 0 141 0 22 0 141 0 23 0 141 0 24 0 141 0 25 0 141 0 26 0 141 0 27 0 141 0 28 0 141 0 29 0 141 0 30 0 141 0 31 0 141 0 32 0 141 0 33 0 141 0 34] 
#[0 0 18 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[1 0 22 0 1 0 22 0 2 0 22 0 3 0 22 0 4 0 22 0 5 0 22 0 6 0 22 0 7 0 22 0 8 0 22 0 9 0 22 0 10 0 145 0 11 0 22 0 12 0 22 0 13 0 22 0 14 0 22 0 17 0 22 0 35] 
#[1 0 6 0 1 0 6 0 2 0 6 0 3 0 6 0 4 0 6 0 5 0 6 0 6 0 6 0 8 0 6 0 9 0 6 0 10 0 6 0 12 0 6 0 13 0 6 0 14 0 6 0 17 0 149 0 20] 
#[0 0 26 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 30 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 34 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 38 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 42 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 46 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 50 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 54 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 58 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 62 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 66 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 70 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 74 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 78 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 82 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 86 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 90 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 94 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 98 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 102 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 153 0 7 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 57 0 14 0 61 0 17 0 65 0 21 0 65 0 22 0 65 0 23 0 65 0 24 0 65 0 25 0 65 0 26 0 65 0 27 0 65 0 28 0 65 0 29 0 65 0 30 0 65 0 31 0 65 0 32 0 65 0 33 0 65 0 34] 
#[0 0 106 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[1 0 45 0 9 0 49 0 10 0 157 0 30 0 157 0 31 0 157 0 32] 
#[1 0 17 0 1 0 21 0 2 0 25 0 3 0 29 0 4 0 33 0 5 0 37 0 6 0 41 0 8 0 45 0 9 0 49 0 10 0 53 0 12 0 161 0 13 0 57 0 14 0 61 0 17 0 65 0 21 0 65 0 22 0 65 0 23 0 65 0 24 0 65 0 25 0 65 0 26 0 65 0 27 0 65 0 28 0 65 0 29 0 65 0 30 0 65 0 31 0 65 0 32 0 65 0 33 0 65 0 34] 
#[0 0 110 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 114 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35] 
#[0 0 118 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 12 0 13 0 14 0 17 0 35]
	).
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForArray1: nodes [

	| result |
	result := CarpArrayNode new.
	result addNodes: (nodes at: 2) to: result expressions.
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
	result addNodes: (nodes at: 2) to: result expressions.
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForModuleOrType1: nodes [

	| result |
	result := CarpModuleOrTypeNode new.
	result value: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CarpParser >> reduceActionForModuleOrType2: nodes [

	| result |
	result := CarpModuleOrTypeNode new.
	result value: (nodes at: 1).
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
