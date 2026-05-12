using Godot;
using System;

public partial class CartesianPlane
{
    public void Circle(Vector2 origin, float radius)
    {
        Node2D node = new Node2D();
        node.Name = "Circle: " + origin.ToString() + " | " + radius;
        GetNode<Node2D>("My Stuff").AddChild(node);

        CreatePoint(node, origin);

        for (float theta = 0; theta < 360; theta += 1)
        {
            float rad = Mathf.DegToRad(theta);
            float x = Mathf.Cos(rad) * radius;
            float y = Mathf.Sin(rad) * radius;

            CreatePoint(node, Vector2(x, y) + origin);
        }
    }
}
