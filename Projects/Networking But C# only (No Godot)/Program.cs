

using System.Text;

Packet packet = new();
packet.WriteString("Hello");
// packet.WriteInt(5);
// packet.WriteBool(true);
packet.CreateBytesArray();
// Console.WriteLine(packet.ReadInt());
// Console.WriteLine(packet.ReadBool());

Console.WriteLine(packet.ReadString());