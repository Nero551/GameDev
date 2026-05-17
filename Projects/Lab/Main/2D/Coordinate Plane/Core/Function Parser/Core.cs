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
    * 2- map out each token to a class(Mapper).
    * 3- loop through the mapped out list and bind atoms to operators depending on binding power(Binder).
    * 4-loop through the binded operators and evaluate the answer(Evaluator).
    */

    public static List<Expression> Parse(string text)
    {
        List<Token> Tokens = Lexer.Tokenize(text);

        return null;
    }

}