using System;
using System.Collections.Generic;
using Godot;


namespace Events.Remote;

public abstract class Remote : Event
{
    protected object[] DecodedData;
    public int SenderPeerId;
}
