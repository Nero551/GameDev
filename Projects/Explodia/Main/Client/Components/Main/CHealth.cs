using Godot;
using System;

public partial class CHealth : Component
{
    public float MaxHealth = 100;
    public float CurrentHealth { get; set => field = Mathf.Clamp(value, 0, MaxHealth); } = 100;
}
