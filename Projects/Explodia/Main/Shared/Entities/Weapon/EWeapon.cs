using System;
using Godot;

public partial class EWeapon : EItem
{
    public override void InitClass()
    {
        ItemData = PULib.JSONToCSharp("Main/Shared/Data/ItemData/WeaponData");
        ItemData = (Godot.Collections.Dictionary)ItemData[this.Name];
        AnimationLibrary = Master.cAnimations.LoadAnimLibrary($"Main/Shared/Assets/Items/Weapons/{ItemData["Type"]}/{ItemData["Name"]}/Animations");
        Master.cAnimations.AddAnimLibrary((string)ItemData["Name"], AnimationLibrary);
    }
}
