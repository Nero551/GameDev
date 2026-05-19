using Godot;
using System;

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
            if (combatable.ActiveHand == null || combatable.ActiveHand is not EItem || combatable.ActiveHand.animationLibrary == null)
            {
                return;
            }

            if ((PULib.CurrentSTime() - LastComboTime) < (double)combatable.ActiveHand.itemData["ComboCooldown"])
            {
                return;
            }

            if ((PULib.CurrentSTime() - LastSwingTime) >= (double)combatable.ActiveHand.itemData["ComboResetTime"])
            {
                SwingNumber = 0;
            }

            SwingNumber++;
            LastSwingTime = PULib.CurrentSTime();

            if (SwingNumber > (int)combatable.ActiveHand.itemData["Swings"])
            {
                LastComboTime = PULib.CurrentSTime();
                SwingNumber = 0;
            }

            string itemName = (string)combatable.ActiveHand.itemData["Name"];
            Animation swingAnim = Entity.GetComponent<CAnimations>().GetAnim(itemName + "/" + "L" + SwingNumber);
            if (swingAnim == null)
            {
                return;
            }

            Entity.GetComponent<CStates>().AddState("Attacking", swingAnim.Length);
            Entity.GetComponent<CAnimations>().PlayAnim(itemName + "/" + "L" + SwingNumber, 1);
        }
    }

    public void OnHitMarker()
    {
        string itemName = (string)combatable.ActiveHand.itemData["Name"];
        string hitboxName = itemName + "Basic Attack Hitbox";
        if (World.Hitboxes.GetNodeOrNull<EHitbox>(hitboxName) == null)
        {
            PackedScene scene = GD.Load<PackedScene>("res://Main/Workspace/Hitbox.tscn");
            EHitbox hitbox = scene.Instantiate<EHitbox>();

            hitbox.Name = hitboxName;

            Godot.Collections.Dictionary hitboxData = (Godot.Collections.Dictionary)combatable.ActiveHand.itemData["Hitbox"];
            Vector3 hitboxSize = new Vector3((float)hitboxData["X"], (float)hitboxData["Y"], (float)hitboxData["Z"]);

            hitbox.Init(combatable.Rig.GetNode<Marker3D>("HitboxLocation").GlobalPosition, hitboxSize, Entity.Owner as ECharacter);
            PULib.ScheduleRemoval(hitbox, 0.1f);
        }
    }
}
