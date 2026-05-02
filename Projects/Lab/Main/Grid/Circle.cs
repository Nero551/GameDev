using Godot;
using System;

public partial class Grid
{
    public void CreateCircle(Vector3 origin, float radius)
    {
        CreatePoint("M", origin);
        for (float theta = 0; theta <= 360; theta += 1)
        {
            Vector3 C;

            float cos = Mathf.Cos(Mathf.DegToRad(theta));
            float sin = Mathf.Sin(Mathf.DegToRad(theta));

            C = new Vector3(cos * radius, sin * radius, 0) + origin;
            CreatePoint(C.ToString(), C);
        }
    }

}
