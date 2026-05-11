using Godot;
using System;

public partial class CartesianPlane : Node
{
	public Vector2 Origin = new Vector2(0, 0);
	public int BasisX = 5;
	public int BasisY = 5;

	public override void _Ready()
	{
		CreateGrid(50);
		CreateLine(Origin, new Vector2(30, -25), Colors.Blue);
		CreateLine(new Vector2(30, -25), new Vector2(30, 5), Colors.Red);
		// CreateLine(new Vector2(0, 4), new Vector2(3, 0));
	}

	public void CreateGrid(int size)
	{

		for (int x = -size; x <= size; x += BasisX)
		{
			Vector2 positiveEnd = new Vector2(x, size);
			Vector2 negativeEnd = new Vector2(x, -size);
			if (x == 0)
			{
				CreateLine(negativeEnd, positiveEnd, default, true, true);
			}
			else
			{
				CreateLine(negativeEnd, positiveEnd, default, true);
			}
		}
		for (int y = -size; y <= size; y += BasisY)
		{
			Vector2 positiveEnd = new Vector2(size, y);
			Vector2 negativeEnd = new Vector2(-size, y);
			if (y == 0)
			{
				CreateLine(negativeEnd, positiveEnd, default, true, true);
			}
			else
			{
				CreateLine(negativeEnd, positiveEnd, default, true);
			}
		}
		CreatePoint(Origin, Colors.Green);

	}

	public Node2D CreatePoint(Vector2 pos, Color color = default)
	{
		PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/point.tscn");
		Node2D point = scene.Instantiate<Node2D>();

		point.Position = new Vector2(pos.X, pos.Y * -1);

		point.Name = pos.ToString();

		point.GetNode<MeshInstance2D>("MeshInstance2D").Modulate = color == default ? Colors.White : color;


		AddChild(point);

		return point;
	}

	public void CreateLine(Vector2 a, Vector2 b, Color color = default, bool core = false, bool axis = false)
	{
		PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/line.tscn");
		Node2D line = scene.Instantiate<Node2D>();
		var meshInstance = line.GetNode<MeshInstance2D>("MeshInstance2D");

		a = new Vector2(a.X, -a.Y);
		b = new Vector2(b.X, -b.Y);
		Vector2 vAB = b - a;

		line.Position = a;
		line.Scale = new Vector2(vAB.Length(), 0.5f);
		line.Rotation = (b - a).Angle();

		line.Name = (a + b).ToString();

		meshInstance.Modulate = color == default ? Colors.DimGray : color;

		//Parenting and axis or custom line differentiation bs. dont come near here
		//Scroll back up please.
		if (core)
		{
			if (axis)
			{
				line.ZIndex = 3;
				GetNode<Node2D>("Core/Axis").AddChild(line);
				if (line.Rotation == 0)
				{
					meshInstance.Modulate = color == default ? Colors.IndianRed : color;
					line.Name = "X Axis";
				}
				else
				{
					meshInstance.Modulate = color == default ? Colors.LightGreen : color;
					line.Name = "Y Axis";
				}
			}
			else
			{
				GetNode<Node2D>("Core").AddChild(line);
			}

		}
		else
		{
			GetNode<Node2D>("My Stuff").AddChild(line);
		}
	}
}
