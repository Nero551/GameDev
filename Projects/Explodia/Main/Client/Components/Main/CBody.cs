using System;
using Godot;

public partial class CBody : Component
{
    public Attachment3D Root;
    protected override void OnInit()
    {
        Root = ComponentHost.Owner.GetNode<Attachment3D>("Root");
    }
}
