# 🧠 C# Syntax Cheat Sheet (Power Moves)

```csharp
// 🔹 Conditional & Null Handling
var result = condition ? a : b;      // Ternary

var name = input ?? "Default";       // Null-coalescing
name ??= "Default";                 // Assign if null

var length = player?.Name?.Length;  // Null-conditional


// 🔹 Switch Expressions (Modern C#)
var result2 = number switch
{
    > 0 => "Positive",
    < 0 => "Negative",
    0 => "Zero"
};


// 🔹 Expression-bodied Members
int Square(int x) => x * x;

public int Health => maxHealth - damage;


// 🔹 Pattern Matching
if (obj is Player player)
{
    player.Move();
}

if (enemy is { Health: > 0 })
{
    Attack(enemy);
}


// 🔹 Deconstruction
(var x, var y) = GetPosition();

public void Deconstruct(out int x, out int y)
{
    x = this.x;
    y = this.y;
}


// 🔹 Discards
(_, var y) = GetPosition();


// 🔹 Object & Collection Initializers
var player = new Player
{
    Name = "Hero",
    Health = 100
};

var list = new List<int> { 1, 2, 3 };


// 🔹 Records + `with` (Immutable Copy)
var newPlayer = player with { Health = 50 };


// 🔹 Strings
var text = $"Player {name} has {health} HP";


// 🔹 nameof (Refactor-safe)
Console.WriteLine(nameof(player.Health)); // "Health"


// 🔹 Index & Range
var last = array[^1];     // Last element
var slice = array[1..4];  // Index 1 → 3


// 🔹 Using Shortcut (Auto Dispose)
using var file = File.OpenRead("data.txt");


// 🔹 Static Import
using static System.Math;

var x = Sqrt(16);


// 🔹 Tuples
var player2 = (Name: "Hero", Health: 100);
Console.WriteLine(player2.Name);


// 🔹 Local Functions
void DoStuff()
{
    int Add(int a, int b) => a + b;
}


// 🔹 Ref Returns (Advanced)
ref int GetRef(int[] arr, int index)
{
    return ref arr[index];
}