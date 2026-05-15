using Godot;
using System;

public abstract partial class Quadrilateral<TMode> : Element<TMode>
{
    protected MathVector2 B;
    protected MathVector2 C;
    protected MathVector2 D;

    protected LineSegment AB;
    protected LineSegment BC;
    protected LineSegment CD;
    protected LineSegment AD;

    protected LineSegment AC;
    protected LineSegment BD;
}
