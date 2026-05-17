class Student : Person
{
    public float GPA  {get; set;} = 0;

    public Student()
    {
        Console.WriteLine("I am in class student");
    }
}