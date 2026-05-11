using Godot;
using System;

public partial class CartesianPlane : Node
{
	public Vector2 Origin = new Vector2(0, 0);
	public int BasisX = 5;
	public int BasisY = 5;
	public int Size;

	public override void _Ready()
	{
		Size = BasisX * BasisY * 2;
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
		CreatePoint(this, Origin, Colors.RoyalBlue);
	}




}
