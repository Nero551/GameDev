public readonly struct Token
{
    public readonly Lexer.TokenType Type;
    public readonly string Value;

    public Token(Lexer.TokenType type, string value)
    {
        Type = type;
        Value = value;
    }
}