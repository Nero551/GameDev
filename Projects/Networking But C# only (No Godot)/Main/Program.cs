

using System.Text;

Packet packet = new();

packet.WriteString("Hello");
packet.WriteInt(5);
packet.WriteFloat(2.3f);
packet.WriteBool(true);

packet.CreateBytesArray();

Console.WriteLine(BitConverter.ToString(packet.BufferList.ToArray()));

Console.WriteLine(packet.ReadString());
Console.WriteLine(packet.ReadInt());
Console.WriteLine(packet.ReadFloat());
Console.WriteLine(packet.ReadBool());