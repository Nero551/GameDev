using Godot;
using System;

public partial class Grid
{
    public void CreateTriangle(Vector3 a, Vector3 b, Vector3 c)
    {
        Point A = CreatePoint(a.ToString(), a);
        Point B = CreatePoint(b.ToString(), b);
        Point C = CreatePoint(c.ToString(), c);
        Line AB = CreateLine(A.Position.ToString(), A.Position, B.Position);
        Line BC = CreateLine(B.Position.ToString(), B.Position, C.Position);
        Line AC = CreateLine(C.Position.ToString(), A.Position, C.Position);
    }
}
