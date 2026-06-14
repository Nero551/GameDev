using System.Buffers.Binary;
using System.Net;
using System.Net.Sockets;

class Client
{
    private UdpClient UDPClient;
    private bool Running = false;

    public void Start(IPAddress ip, int port)
    {
        Running = true;
        Console.WriteLine("Client Is Running");

        UDPClient = new UdpClient();
        UDPClient.Connect(ip, port);
        UDPClient.BeginReceive(OnRecieveUDP, null);
    }


    private void OnRecieveUDP(IAsyncResult result)
    {
        Console.WriteLine("Recieved By Client");

        IPEndPoint endPoint = new(IPAddress.Any, 0);
        byte[] recievedData = UDPClient.EndReceive(result, ref endPoint);

        Packet packet = new();
        packet.WriteBytes(recievedData);
        packet.CreateBytesArray();
        int id = packet.ReadInt();
        if (id == 1)
        {
            string message = packet.ReadString();
            Console.WriteLine("UDP: " + message);
        }

        UDPClient.BeginReceive(OnRecieveUDP, null);

    }

    private void SendToUDP(Packet packet)
    {
        var data = packet.CreateBytesArray();
        IPEndPoint endPoint = new(IPAddress.Any, 0);
        UDPClient.BeginSend(data, data.Length, endPoint, null, null);
    }
}