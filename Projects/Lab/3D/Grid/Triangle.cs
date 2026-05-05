using Godot;
using System;

public partial class Grid3D
{
    public void CreateTriangle(Vector3 a, Vector3 b, Vector3 c)
    {
        Point3D A = CreatePoint(a.ToString(), a);
        Point3D B = CreatePoint(b.ToString(), b);
        Point3D C = CreatePoint(c.ToString(), c);
        Line3D AB = CreateLine(A.Position.ToString(), A.Position, B.Position);
        Line3D BC = CreateLine(B.Position.ToString(), B.Position, C.Position);
        Line3D AC = CreateLine(C.Position.ToString(), A.Position, C.Position);
    }
}
