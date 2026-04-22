using Godot;
using System;

public partial class PULib
{
	public static void CallInitMethods(object obj)
	{
		var methods = obj.GetType().GetMethods();

		foreach (var method in methods)
		{
			if (method.Name.Contains("Init") && method.GetParameters().Length == 0)
			{
				method.Invoke(obj, null);
			}
		}
	}
	public static void CallPhysUpdMethods(object obj, double delta)
	{
		var methods = obj.GetType().GetMethods();

		foreach (var method in methods)
		{
			if (method.Name.Contains("PhysUpd"))
			{
				var parameters = method.GetParameters();

				if (parameters.Length == 1 && parameters[0].ParameterType == typeof(double))
				{
					method.Invoke(obj, new object[] { delta });
				}
			}
		}
	}
	public static void CallUpdMethods(object obj, double delta)
	{
		var methods = obj.GetType().GetMethods();

		foreach (var method in methods)
		{
			if (method.Name.Contains("Upd"))
			{
				var parameters = method.GetParameters();

				if (parameters.Length == 1 && parameters[0].ParameterType == typeof(double))
				{
					method.Invoke(obj, new object[] { delta });
				}
			}
		}
	}
	public static void CallInpMethods(object obj, InputEvent @event)
	{
		var methods = obj.GetType().GetMethods();

		foreach (var method in methods)
		{
			if (method.Name.Contains("Upd"))
			{
				var parameters = method.GetParameters();

				if (parameters.Length == 1 && parameters[0].ParameterType == typeof(InputEvent))
				{
					method.Invoke(obj, new object[] { @event });
				}
			}
		}
	}
}
