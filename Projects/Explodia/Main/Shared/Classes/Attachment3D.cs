using Godot;

[Tool, GlobalClass]
public partial class Attachment3D : Marker3D
{
    [Export] public Node3D AttachWhat;
    [Export] public Node3D AttachTo;

    public override void _Ready()
    {
        SetProcess(true);
    }

    public override void _Process(double delta)
    {
        if (AttachWhat == null || AttachTo == null)
        {
            return;
        }

        AttachWhat.GlobalTransform = AttachTo.GlobalTransform;
    }
}