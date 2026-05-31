using System;
using Godot;

public partial class CCombat : Component
{
    public int SwingNumber = 0;
    public double LastSwingTime = 0;
    public double LastComboTime = 0;

    private ICombatable combatable;

    protected override void OnInit()
    {
        combatable = Entity.GetInterface<ICombatable>();
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
        if (Entity.GetComponent<CActionVerifier>().CanAttack())
        {
            if (combatable.ActiveHand == null || combatable.ActiveHand is not Item || combatable.ActiveHand.AnimationLibrary == null)
            {
                return;
            }
            var itemData = combatable.ActiveHand.ItemData;


            if ((PULib.CurrentSTime() - LastComboTime) < (double)itemData["ComboCooldown"])
            {
                return;
            }
            if ((PULib.CurrentSTime() - LastSwingTime) >= (double)itemData["ComboResetTime"])
            {
                SwingNumber = 0;
            }

            if (SwingNumber > (int)itemData["Swings"])
            {
                LastComboTime = PULib.CurrentSTime();
                SwingNumber = 0;
                return;
            }

            SwingNumber++;
            LastSwingTime = PULib.CurrentSTime();

            string itemName = (string)itemData["Name"];
            Animation swingAnim = Entity.GetComponent<CAnimations>().GetAnim($"{itemName}/L{SwingNumber}");
            if (swingAnim == null)
            {
                return;
            }

            Entity.GetComponent<CStates>().AddState("all ", swingAnim.Length);
            Entity.GetComponent<CAnimations>().PlayAnim($"{itemName}/L{SwingNumber}", 1);
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

            hitbox.Init(Entity.Owner.GetNode<Node3D>("Armature/HitboxLocation").GlobalPosition, hitboxSize, Entity.Owner as Character);
            PULib.ScheduleRemoval(hitbox, 0.1f);
        }
    }
}
