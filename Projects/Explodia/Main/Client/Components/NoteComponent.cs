using Godot;
using System;

public partial class Note : Component 
{
     
    /*
    TODO- migrate to Composition + Inheritance instead of just inheritance

    ? Components will basically be functions, classes will be a coordinator for the functions it needs.
    ? Components wont have nodes, classes call components and give owner/master on construct.
    ? Components do work , classes manange flow for each object.
    ? Inheritance will still exist for classes E.X. Player inherits Character inherits from Entity.
    ? basically instead of scripts being part of the class they are seperate component.
    ? this will allow reusabilty anywhere even if its not the same class , as long as it meets the conditions.

    i have done some research. to move into the new framework i need a good understanding of:
        1- interfaces
        2- generics
        2- composition
        3- polymorphism

    what i need to make:
        1-a component adder 
        2- abstract component class

    flow:
        1-class adds component with the component adder.
        2-component adder runs init component and onInit methods and assigns owner.
        3-component init checks if owner has the required interface.
        4-component now works.
        5-class manages and organizes its components.
    */
}
