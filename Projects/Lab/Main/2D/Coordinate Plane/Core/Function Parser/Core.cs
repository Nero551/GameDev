using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public abstract class Math
{

    public static List<Math> Parse(string text)
    {
        List<Math> Expressionified = new();
        Lexer lexer = new Lexer();
        lexer.Tokenize(text);
        
        return Expressionified;
    }
}