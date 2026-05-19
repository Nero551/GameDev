using Godot;
using System;

public partial class CartesianPlane : Node2D
{
	public static Node2D Plane;
	public static MathVector2 Origin = new MathVector2(0, 0);
	public static int BasisX = 5;
	public static int BasisY = 5;
	public static int Size;

	public override void _Ready()
	{
		Plane = this;

		Size = BasisX * BasisY * 4;
		CreateGrid();
		Sandbox();
	}

	public void CreateGrid()
	{
		for (int x = -Size; x <= Size; x += BasisX)
		{
			Vector2 positiveEnd = new Vector2(x, Size);
			Vector2 negativeEnd = new Vector2(x, -Size);
			if (x == 0)
			{
				AxisLine(negativeEnd, positiveEnd);
			}
			else
			{
				PlaneLine(negativeEnd, positiveEnd);
			}
		}
		for (int y = -Size; y <= Size; y += BasisY)
		{
			Vector2 positiveEnd = new Vector2(Size, y);
			Vector2 negativeEnd = new Vector2(-Size, y);
			if (y == 0)
			{
				AxisLine(negativeEnd, positiveEnd);
			}
			else
			{
				PlaneLine(negativeEnd, positiveEnd);
			}
		}
		Point.Create(Origin, "Origin", Colors.RoyalBlue, this);
	}

	public void PlaneLine(Vector2 a, Vector2 b)
	{
		PackedScene scene = SceneLoader.Load("PlaneLine");
		Node2D line = scene.Instantiate<Node2D>();
		var meshInstance = line.GetNode<MeshInstance2D>("Line");

		a = new Vector2(a.X, -a.Y);
		b = new Vector2(b.X, -b.Y);
		Vector2 vAB = b - a;

		line.Position = a;
		line.Scale = new Vector2(Size * 2, 0.5f);
		line.Rotation = (b - a).Angle();

		line.Name = (a + b).ToString();

		meshInstance.Modulate = Colors.DimGray;
		GetNode<Node2D>("Core/Plane").AddChild(line);

	}

	public void AxisLine(Vector2 a, Vector2 b)
	{
		PackedScene scene = SceneLoader.Load("AxisLine");
		Node2D line = scene.Instantiate<Node2D>();
		var meshInstance = line.GetNode<MeshInstance2D>("Line/LineMesh");
		var arrow1 = line.GetNode<MeshInstance2D>("Arrow1/Arrow1Mesh");
		var arrow2 = line.GetNode<MeshInstance2D>("Arrow2/Arrow2Mesh");

		a = new Vector2(a.X, -a.Y);
		b = new Vector2(b.X, -b.Y);
		Vector2 vAB = b - a;

		line.Position = (a + b) / 2;
		line.GetNode<Node2D>("Line").Scale = new Vector2(Size * 2, 0.5f);
		line.Rotation = (b - a).Angle();

		line.GetNode<Node2D>("Arrow1").Position = new Vector2(line.GetNode<Node2D>("Line").Scale.X / 2, 0);
		line.GetNode<Node2D>("Arrow2").Position = new Vector2(-line.GetNode<Node2D>("Line").Scale.X / 2, 0);

		GetNode<Node2D>("Core/Axis").AddChild(line);
		if (line.Rotation == 0)
		{
			arrow1.Modulate = Colors.IndianRed;
			arrow2.Modulate = Colors.IndianRed;

			meshInstance.Modulate = Colors.IndianRed;
			line.Name = "X Axis";
		}
		else
		{
			arrow1.Modulate = Colors.LightGreen;
			arrow2.Modulate = Colors.LightGreen;

			meshInstance.Modulate = Colors.LightGreen;
			line.Name = "Y Axis";
		}
	}
}
