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

    am thinking 3 main methods , arthimitic solver, equation solver and function solver,
    arthimitic is just the Solve function down thhere
    equation solver solves equations with 1 unkown (X)
    function solver, u just give it the equation and X and it gives Y.
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