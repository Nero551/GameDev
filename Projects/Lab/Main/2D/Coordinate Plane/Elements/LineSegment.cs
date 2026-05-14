// using Godot;
// using System;

// public partial class CartesianPlane
// {
//     //Vector Method
//     public LineSegment LineSegment(Vector2 a, Vector2 b, Color color = default)
//     {
//         PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/LineSegment.tscn");
//         LineSegment line = scene.Instantiate<LineSegment>();
//         var meshInstance = line.GetNode<MeshInstance2D>("Line");

//         Vector2 vAB = b - a;

//         line.Position = a;
//         line.Scale = new Vector2(vAB.Length(), 0.5f);
//         line.Rotation = (vAB).Angle();

//         line.Name = "Line Segment: " + (a + b).ToString();
//         meshInstance.Modulate = color == default ? Colors.DimGray : color;

//         line.RegisterData(line, a, b);

//         GetNode<Node2D>("My Stuff").AddChild(line);

//         return line;
//     }
// }
