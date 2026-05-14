using Godot;
using System;

public partial class LineSegment : Node2D
{
    [Export] public float AX;
    [Export] public float AY;
    [Export] public float BX;
    [Export] public float BY;
    public MathVector2 AB;

    [Export] public float Length = default;
    [Export] public float Angle = default;
    [Export] public float AngleRad = default;
    [Export] public float Slope = default;

    [Export] public string LineName;
    [Export] public Color Color;

    public static LineSegment Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/LineSegment.tscn");
        LineSegment line = scene.Instantiate<LineSegment>();

        line.LineName = name == default ? "Line Segment" : name;
        line.Color = color == default ? Colors.White : color;
        parent = parent == default ? CartesianPlane.Plane.GetNodeOrNull<Node2D>("Content/LineSegments") : parent;

        parent.AddChild(line);
        return line;
    }

    //* i need a way to track change and adjust values accordingly.
    //* maybe using setters that call a function?

    //* another idea is have each variable turn a boolean true on setter.
    //* then a function executes adjustments on true then falses the boolean
    public override void _Process(double delta)
    {
        AB = new MathVector2(BX - AX, BY - AY);
        AngleRad = Mathf.Atan2(AB.Y, AB.X);
        Angle = Mathf.RadToDeg(AngleRad);
        Slope = Mathf.Tan(AngleRad);
        Length = AB.Length();


        Name = LineName;
        GetNode<MeshInstance2D>("Line").Modulate = Color;

        Scale = new Vector2(Converter.LengthMathToRender(Length), 0.5f);
        Position = Converter.VectorMathToRender(new MathVector2(AX, AY));
        Rotation = Converter.AngleMathToRender(AngleRad);

    }
}
