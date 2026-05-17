using Godot;
using System;
using System.Collections.Generic;

public partial class Lexer
{
    public enum TokenType
    {
        Atom,
        Operator,
        OpenedParenthesis,
        ClosedParenthesis,
        Constant,
    }

    public int Pos = -1;
    public int End;
    public List<Token> Tokens = new();
    public List<Token> Tokenize(string text)
    {

        text = text.ToUpper();
        for (int i = 0; i < text.Length; i++)
        {
            char c = text[i];
            if (char.IsDigit(c))
            {
                Tokens.Add(new Token(TokenType.Atom, c.ToString()));
            }
            else if ("+-/*".Contains(c))
            {
                Tokens.Add(new Token(TokenType.Operator, c.ToString()));
            }
            else if ("(".Contains(c))
            {
                Tokens.Add(new Token(TokenType.OpenedParenthesis, c.ToString()));
            }
            else if (")".Contains(c))
            {
                Tokens.Add(new Token(TokenType.ClosedParenthesis, c.ToString()));
            }
        }
        End = Tokens.Count;
        return Tokens;
    }

    public Token Next()
    {
        return Tokens[Pos++];
    }
    public bool Peek()
    {
        return Pos == End;
    }
}

