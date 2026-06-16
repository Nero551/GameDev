using System;
using Godot;

namespace Packets;

public  class TestPacket : Packet
{
    public override void Send(int id, object[] data)
    {
        //Encoding Goes Here
        
        base.Send(id, data);
    }
    public override void Recieve(Packet packet)
    {
        //Decoding Goes Here

        base.Recieve(packet);

    }
}
