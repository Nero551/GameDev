using System;
using System.Collections.Generic;

public class Lexer
{
    public enum TokenType
    {
        Constant,
        Add,
        Subtract,
        Multiply,
        Divide,
        OpenParen,
        CloseParen
    }

    public static List<Token> Tokenize(string text)
    {
        List<Token> tokens = new();

        text = text.ToUpper();

        for (int i = 0; i < text.Length; i++)
        {
            char c = text[i];

            if (char.IsDigit(c))
            {
                string num = "";
                int start = i;
                while (i < text.Length && char.IsDigit(text[i]))
                {
                    i++;
                }
                num = text.Substring(start, i - start);
                i--;

                tokens.Add(new Token(TokenType.Constant, num));
                continue;
            }

            if (c == '+')
                tokens.Add(new Token(TokenType.Add, "+"));

            else if (c == '-')
                tokens.Add(new Token(TokenType.Subtract, "-"));

            else if (c == '*')
                tokens.Add(new Token(TokenType.Multiply, "*"));

            else if (c == '/')
                tokens.Add(new Token(TokenType.Divide, "/"));

            else if (c == '(')
                tokens.Add(new Token(TokenType.OpenParen, "("));

            else if (c == ')')
                tokens.Add(new Token(TokenType.CloseParen, ")"));
        }

        return tokens;
    }
}