using Godot;
using System;

public partial class Converter
{
    public static Vector2 VectorMathToRender(MathVector2 mathVector)
    {
        float x = mathVector.X * CartesianPlane.BasisX;
        float y = -(mathVector.Y * CartesianPlane.BasisY);
        Vector2 renderVector = new Vector2(x, y);
        return renderVector;
    }
    public static MathVector2 VectorRenderToMath(Vector2 renderVector)
    {
        float x = renderVector.X / CartesianPlane.BasisX;
        float y = -(renderVector.Y / CartesianPlane.BasisY);

        MathVector2 mathVector = new MathVector2(x, y);
        return mathVector;
    }

    public static float LengthMathToRender(float length)
    {
        return length * Mathf.Sqrt(CartesianPlane.BasisX * CartesianPlane.BasisY);
    }

    public static float AngleMathToRender(float angle)
    {
        return -angle;
    }
}
