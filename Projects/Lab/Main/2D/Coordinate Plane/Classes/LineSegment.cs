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

    public static LineSegment Create(string name = default, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/LineSegment.tscn");
        LineSegment line = scene.Instantiate<LineSegment>();
        var meshInstance = line.GetNode<MeshInstance2D>("Line");

        // line.Scale = new Vector2(vAB.Length(), 0.5f);
        // line.Rotation = (vAB).Angle();

        line.LineName = name == default ? "Line Segment" : name;
        line.Color = color == default ? Colors.White : color;
        GD.Print(MathWorld.World);
        MathWorld.World.GetNode<Node2D>("Cartesian Plane/My Stuff").AddChild(line);

        return line;
    }

    public override void _Process(double delta)
    {
        // Name = LineName;
        GetNode<MeshInstance2D>("Line").Modulate = Color;
        AB = new MathVector2(BX - AX, BY - AY);
        Length = AB.Length();
        AngleRad = Mathf.DegToRad(Angle);


        Scale = new Vector2(Converter.LengthMathToRender(Length), 0.5f);
        Position = Converter.MathToRender(new MathVector2(AX, AY));
        Rotation = Converter.AngleMathToRender(AngleRad);

    }
}
