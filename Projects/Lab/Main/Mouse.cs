// using Godot;
// using System;

// public partial class Mouse : Node3D
// {
//     public override void _Ready()
//     {
//         Input.MouseMode = Input.MouseModeEnum.Captured;
//     }
//     public override void _Process(double delta)
//     {
//         base._Process(delta);
//         if (Input.IsActionJustPressed("ToggleMouseMode"))
//         {
//             if (Input.MouseMode == Input.MouseModeEnum.Captured)
//             {
//                 Input.MouseMode = Input.MouseModeEnum.Visible;
//             }
//             else
//             {
//                 Input.MouseMode = Input.MouseModeEnum.Captured;
//             }
//         }
//     }
// }
