using Godot;
using System;
using System.Linq;

public readonly struct MathVector2
{
    public readonly float X;
    public readonly float Y;

    public MathVector2(float x, float y)
    {
        X = x;
        Y = y;
    }

    public static MathVector2 operator +(MathVector2 a, MathVector2 b)
    {
        float x = a.X + b.X;
        float y = a.Y + b.Y;
        return new MathVector2(x, y);
    }

    public static MathVector2 operator -(MathVector2 a, MathVector2 b)
    {
        float x = a.X - b.X;
        float y = a.Y - b.Y;
        return new MathVector2(x, y);
    }

    public static MathVector2 operator *(float scalar, MathVector2 b)
    {
        float x = scalar * b.X;
        float y = scalar * b.Y;
        return new MathVector2(x, y);
    }

    public static void Print(params MathVector2[] mathVectors)

    {
        string text = "";
        foreach (MathVector2 v in mathVectors)
        {
            text += $"[{v.X}, {v.Y}] ";
        }
        GD.Print(text);
    }

    public float Length()
    {
        return Mathf.Sqrt(Mathf.Pow(X, 2) + Mathf.Pow(Y, 2));
    }

    public float Angle()
    {
        return Mathf.Atan2(Y, X);
    }
}
