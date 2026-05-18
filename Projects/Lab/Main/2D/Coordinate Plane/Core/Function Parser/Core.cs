using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata.Ecma335;

public abstract class Expression
{
    /*
    *from my understading, wut i need to do is: 
    * 1- tokenize the string(Lexer).
    * 2- order the tokens by operation priority (Parser)
    * 4-calculate the answer(Evaluator).
    */
    //! i will be postponing this , its hella hard. i will expand my knowledge on linear algebra.

    public static float Solve(string text)
    {
        List<Token> Tokens = Lexer.Tokenize(text);
        List<Token> ParsedData = Parser.Parse(Tokens);
        float result = Evaluator.Evaluate(ParsedData);
        return result;
    }

}