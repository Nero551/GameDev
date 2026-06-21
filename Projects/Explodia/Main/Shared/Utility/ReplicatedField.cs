using System;
using System.Reflection;
using Godot;

public class ReplicatedField(FieldInfo fieldInfo, Replicated attribute)
{
	public FieldInfo Field => fieldInfo;
	public Replicated Attribute => attribute;
}


