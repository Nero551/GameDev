using System.Net;
using System.Net.Sockets;

class Server
{
    private UdpClient UDPListener;
    private bool Running = false;

    public void Start(int port)
    {
        Running = true;
        Console.WriteLine("Server Is Running");

        UDPListener = new UdpClient(port);
        UDPListener.BeginReceive(OnRecieveUDP, null);
    }

    private void OnRecieveUDP(IAsyncResult result)
    {
        IPEndPoint endPoint = new(IPAddress.Any, 0);
        byte[] recievedData = UDPListener.EndReceive(result, ref endPoint);

        Packet packet = new();
        packet.WriteBytes(recievedData);
        packet.CreateBytesArray();
        int id = packet.ReadInt();
        if (id == 1)
        {
            string message = packet.ReadString();
            Console.WriteLine("UDP: " + message);
        }

        UDPListener.BeginReceive(OnRecieveUDP, null);
    }

    public void SendToUDP(Packet packet)
    {
        var data = packet.CreateBytesArray();
        IPEndPoint endPoint = new(IPAddress.Any, 0);
        UDPListener.BeginSend(data, data.Length, endPoint, null, null);
    }

}