
Person compareAge(Person a, Person b)
{
    Person older;
    if (a.Age > b.Age)
    {
        older = a;
    }
    else
    {
        older = b;
    }
    return older;
}

Student student = new Student();
student.Age = 15;
student.Name = "Asta";
student.GPA = 50;

Console.WriteLine($"Name: {student.Name}, Age: {student.Age}, GPA: {student.GPA}");

Person person = new Person();
person.Age = 27;
person.Name = "Yuno";

Console.WriteLine(compareAge(student, person).Name);

