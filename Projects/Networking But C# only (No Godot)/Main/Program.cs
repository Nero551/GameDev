using System.Net;
using System.Text;

IPAddress IP = IPAddress.Parse("127.0.0.1");
int Port = 7777;

Console.Clear();

Packet packet = new();

packet.WriteInt(1);
packet.WriteString("Hello");

var key = Console.ReadKey(true);
if (key.Key == ConsoleKey.S)
{
    Server server = new();
    server.Start(Port);
    server.SendToUDP(packet);
}
if (key.Key == ConsoleKey.C)
{
    Client client = new();
    client.Start(IP, Port);
}

Console.WriteLine("Press any key to exit...");
Console.ReadKey();


