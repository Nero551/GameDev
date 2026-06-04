using System;
using Godot;
using PULib;

public partial class CCombat : Component
{
    public int SwingNumber = 0;
    public double LastSwingTime = 0;
    public double LastComboTime = 0;

    private ICombatable combatable;

    protected override void OnInit()
    {
        combatable = ComponentHost.GetInterface<ICombatable>();
    }

    public void M1()
    {
        // ActiveHand = MainHand;
        BasicAttack();
    }
    public void M2()
    {
        // ActiveHand = OffHand;
        BasicAttack();
    }

    public void BasicAttack()
    {
        if (ComponentHost.GetComponent<CActionVerifier>().CanAttack())
        {
            if (combatable.ActiveHand == null || combatable.ActiveHand is not Item || combatable.ActiveHand.AnimationLibrary == null)
            {
                return;
            }
            var itemData = combatable.ActiveHand.ItemData;


            if ((GDHelper.CurrentSTime() - LastComboTime) < (double)itemData["ComboCooldown"])
            {
                GD.Print("1");
                return;
            }
            if ((GDHelper.CurrentSTime() - LastSwingTime) >= (double)itemData["ComboResetTime"])
            {
                SwingNumber = 0;
            }

            if (SwingNumber > (int)itemData["Swings"])
            {
                GD.Print("2");
                LastComboTime = GDHelper.CurrentSTime();
                SwingNumber = 0;
                return;
            }

            SwingNumber++;
            LastSwingTime = GDHelper.CurrentSTime();

            string itemName = (string)itemData["Name"];
            Animation swingAnim = ComponentHost.GetComponent<CAnimations>().GetAnim($"{itemName}/L{SwingNumber}");
            if (swingAnim == null)
            {
                GD.Print("3");
                return;
            }

            ComponentHost.GetComponent<CStates>().AddState("Attacking", swingAnim.Length);
            ComponentHost.GetComponent<CAnimations>().PlayAnim($"{itemName}/L{SwingNumber}", 1);
        }
    }

    public void OnHitMarker()
    {
        var itemData = combatable.ActiveHand.ItemData;
        string itemName = (string)itemData["Name"];
        string hitboxName = itemName + "Basic Attack Hitbox";
        if (Game.Hitboxes.GetNodeOrNull<Hitbox>(hitboxName) == null)
        {
            PackedScene scene = GD.Load<PackedScene>("res://Main/Workspace/Hitbox.tscn");
            Hitbox hitbox = scene.Instantiate<Hitbox>();

            hitbox.Name = hitboxName;

            var hitboxData = (Godot.Collections.Dictionary)itemData["Hitbox"];
            Vector3 hitboxSize = new Vector3((float)hitboxData["X"], (float)hitboxData["Y"], (float)hitboxData["Z"]);

            hitbox.Init(ComponentHost.Owner.GetNode<Node3D>("Armature/HitboxLocation").GlobalPosition, hitboxSize, ComponentHost.Owner as Character);
            GDHelper.ScheduleRemoval(hitbox, 0.1f);
        }
    }
}
