package yeungda.coffeescript.lang;


import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;

%%

%class Lexer
%implements FlexLexer
%unicode
%function advance
%type IElementType
%eof{  return;
%eof}

WS=[\ \t]+

IDENTIFIER    = [a-zA-Z\$_]([a-zA-Z_0-9$])*
NUMBER        = (0(x|X)[0-9a-fA-F]+)|([0-9]+(\.[0-9]+)?(e[+\-]?[0-9]+)?)
INTERPOLATION = \$([a-zA-Z_@]\w*(\.\w+)*)
OPERATOR      = ([+\*&|\/\-%=<>:!?][=+])
WHITESPACE    = ([ \t]+)
COMMENT       = (((\n?[ \t]*)?#[^\n]*)+)
CODE          = ((-|=)>)
MULTI_DENT    = ((\n([ \t]*))+)(\.)?
LAST_DENT     = \n([ \t]*)
ASSIGNMENT    = (:|=)

CHARACTERS_IN_DOUBLE_QUOTES  = ([^\"\r\n\\]+)
CHARACTERS_IN_SINGLE_QUOTES  = ([^\'\r\n\\]+)
LINE_TERMINATOR = [\n\r]

REGEX_START        = \/[^\/ ]
REGEX_INTERPOLATION= ([^\\]\$[a-zA-Z_@]|[^\\]\$\{.*[^\\]\})
REGEX_FLAGS        = [imgy]{0,4}
REGULAR_EXPRESSION = [^/\\\r\n]+
REGULAR_EXPRESSION_LITERAL = \\[^\$]
%state NOUN, DOUBLE_QUOTE_STRING, SINGLE_QUOTE_STRING, REGULAR_EXPRESSION, VERB

%%

<YYINITIAL> {
    "case"      |
    "default"   |
    "do"        |
    "function"  |
    "var"       |
    "void"      |
    "with"      |
    "const"     |
    "let"       |
    "debugger"  |
    "enum"      |
    "export"    |
    "import"    |
    "native"    |
    "__extends" |
    "__hasProp"                 { return Tokens.RESERVED_WORD; }
    ";"                         { return Tokens.SEMI_COLON; }
    \"                          { yybegin(DOUBLE_QUOTE_STRING); return Tokens.STRING; }
    \'                          { yybegin(SINGLE_QUOTE_STRING); return Tokens.STRING; }
    {LINE_TERMINATOR}           { return Tokens.LINE_TERMINATOR; }
}

<VERB> {
    "+"                         |
    "++"                        |
    "*"                         |
    "&"                         |
    "|"                         |
    "/"                         |
    "-"                         |
    "--"                        |
    "%"                         |
    "<"                         |
    ">"                         |
    "::"                        |
    "!"                         |
    "!="                        |
    "=="                        |
    "<="                        |
    ">="                        |
    "?"                         { yybegin(NOUN); return Tokens.OPERATOR; }
    ")"                         { return Tokens.PARENTHESIS; }
    "="                         |
    ":"                         { yybegin(NOUN); return Tokens.ASSIGNMENT; }
    "."                         { yybegin(NOUN); return Tokens.DOT; }
    ","                         { yybegin(NOUN); return Tokens.COMMA; }
    "then"                      |
    "in"                        |
    "unless"                    { yybegin(NOUN); return Tokens.KEYWORD; }
    "]"                         { yybegin(VERB); return Tokens.BRACKET; }
}
<YYINITIAL, NOUN, VERB> {
    "@"                         { yybegin(NOUN); return Tokens.ACCESSOR; }
    "if"                        |
    "and"                       |
    "or"                        |
    "is"                        |
    "isnt"                      |
    "not"                       { yybegin(NOUN); return Tokens.KEYWORD; }
    "for"                       { yybegin(NOUN); return Tokens.KEYWORD; }
    "("                         { yybegin(NOUN); return Tokens.PARENTHESIS; }
    "["                         { yybegin(NOUN); return Tokens.BRACKET; }
    {WS}                        { return Tokens.WHITESPACE; }
    {LINE_TERMINATOR}           { yybegin(YYINITIAL); return Tokens.LINE_TERMINATOR; }
    {COMMENT}                   { return Tokens.COMMENT; }
    "->"                        { yybegin(NOUN); return Tokens.FUNCTION; }
}

<YYINITIAL, NOUN> {
    "else"                      |
    "new"                       |
    "return"                    |
    "try"                       |
    "catch"                     |
    "finally"                   |
    "throw"                     |
    "break"                     |
    "continue"                  |
    "while"                     |
    "delete"                    |
    "instanceof"                |
    "typeof"                    |
    "switch"                    |
    "super"                     |
    "extends"                   |
    "class"                     |
    "of"                        |
    "by"                        |
    "where"                     |
    "when"                      { yybegin(NOUN); return Tokens.KEYWORD; }
    "true"                      |
    "false"                     |
    "yes"                       |
    "no"                        |
    "on"                        |
    "off"                       { yybegin(VERB); return Tokens.BOOLEAN; }
    {IDENTIFIER}                { yybegin(VERB); return Tokens.IDENTIFIER; }
    {NUMBER}                    { yybegin(VERB); return Tokens.NUMBER; }
    "{"                         { yybegin(NOUN); return Tokens.BRACE; }
    "}"                         { yybegin(VERB); return Tokens.BRACE; }


}

<NOUN> {
    ")"                         { yybegin(VERB); return Tokens.PARENTHESIS; }
    "="                         { return Tokens.ASSIGNMENT; }
    "/"                         { yybegin(REGULAR_EXPRESSION); return Tokens.REGULAR_EXPRESSION; }
    \"                          { yybegin(DOUBLE_QUOTE_STRING); return Tokens.STRING; }
    \'                          { yybegin(SINGLE_QUOTE_STRING); return Tokens.STRING; }
}

<REGULAR_EXPRESSION> {
    {REGULAR_EXPRESSION}       { return Tokens.REGULAR_EXPRESSION; }
    "\\/"                      { return Tokens.REGULAR_EXPRESSION_LITERAL; }
    {REGULAR_EXPRESSION_LITERAL} { return Tokens.REGULAR_EXPRESSION_LITERAL; }
    "/"                        { yybegin(VERB); return Tokens.REGULAR_EXPRESSION; }
    {LINE_TERMINATOR}          { yybegin(YYINITIAL); return Tokens.BAD_CHARACTER; }
}

<DOUBLE_QUOTE_STRING> {
    \"                             { yybegin(VERB); return Tokens.STRING; }
    "\\\""                         { return Tokens.STRING_LITERAL; }
    {CHARACTERS_IN_DOUBLE_QUOTES}  { return Tokens.STRING; }
}

<SINGLE_QUOTE_STRING> {
    \'                             { yybegin(VERB); return Tokens.STRING; }
    "\\'"                          { return Tokens.STRING_LITERAL; }
    {CHARACTERS_IN_SINGLE_QUOTES}  { return Tokens.STRING; }
}

<DOUBLE_QUOTE_STRING, SINGLE_QUOTE_STRING> {
    "\\n"                          |
    "\\\\"                         { return Tokens.STRING_LITERAL; }
    "\n"                           |
    "\r"                           { return Tokens.LINE_TERMINATOR; }
    \\.                            { return Tokens.BAD_CHARACTER; }
}

.                                  { yybegin(YYINITIAL);   return Tokens.BAD_CHARACTER; }