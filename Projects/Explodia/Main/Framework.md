---

# Framework Overview

This project uses the **EIC Framework**, pronounced "ice".

EIC is built around three core parts:

* **Entities**
* **Interfaces**
* **Components**

The main rule is simple:

> Entities contain components. Components contain gameplay logic and the data that logic creates. Interfaces expose built-in engine data that components need from the owning Godot class.

---

# Core Design

## Entities

An **Entity** is the internal component container for one gameplay object.

Every main gameplay class creates an Entity instance, usually in `_Ready()`:

```csharp
Entity = Entity.Create(this);
```

The Entity is responsible for:

* Adding components
* Storing components
* Retrieving components
* Giving components access to owner interfaces

Entities should stay lightweight. They should not hold gameplay rules, character stats, animation state, combat state, or movement decisions. That belongs in components.

Example:

```csharp
Chealth = Entity.AddComponent<CHealth>();
Cmovement = Entity.AddComponent<CMovement>();
Ccombat = Entity.AddComponent<CCombat>();
```

---

## Components

A **Component** owns a focused piece of gameplay behavior.

Components are responsible for:

* Their own logic
* Their own state
* Data created by that logic
* Communication with other components through the Entity

Examples of component-owned data:

* Health values
* Movement speed
* Jump power
* Animation priority
* Timed states
* Combat swing counters
* Input state created by an input component

If the data is part of a gameplay system, the component that creates or manages that system should own it.

Example:

```csharp
public partial class CHealth : Component
{
    public float MaxHealth = 100;
    public float CurrentHealth = 100;
}
```

Components can use other components through the Entity:

```csharp
Entity.GetComponent<CHealth>().CurrentHealth -= damage;
Entity.GetComponent<CAnimations>().PlayAnim("Default/Idle", 3);
```

This keeps component relationships explicit and routed through one place.

---

## Interfaces

Interfaces are the bridge between components and data that belongs to the owning Godot class or engine type.

Use interfaces for built-in data and engine capabilities that components need but should not own.

Examples:

* `IVelocity` exposes `CharacterBody3D.Velocity`
* `IIsOnFloor` exposes `CharacterBody3D.IsOnFloor()`

```csharp
public interface IVelocity : Interface
{
    Vector3 Velocity { get; set; }
}
```

A component reads owner data through `Entity.GetInterface<T>()`:

```csharp
Vector3 velocity = Entity.GetInterface<IVelocity>().Velocity;
```

Interfaces should be limited to built-in engine data or engine behavior required by components. Avoid creating interfaces for data that a component can own directly.

---

# Ownership Rules

## Component-Owned Data

Put data in a component when:

* The data is created by gameplay logic
* The data belongs to a gameplay system
* The data can exist independently of the Godot base class
* The data should be reusable across multiple entity types

Examples:

* `CHealth.CurrentHealth`
* `CMovement.Speed`
* `CMovement.JumpPower`
* `CStates` state timers
* `CAnimations` animation priority

---

## Interface-Owned Data

Expose data through an interface when:

* The data already belongs to the Godot owner
* The data is built into an engine class
* A component needs access without depending on the concrete owner type

Examples:

* `Velocity` from `CharacterBody3D`
* `IsOnFloor()` from `CharacterBody3D`
* Node references required by engine systems

Interfaces should describe what the owner already has, not invent a new gameplay storage location.

---

# Communication Rules

## Component To Owner

Components communicate with the owning Godot class through interfaces:

```csharp
Entity.GetInterface<IVelocity>().Velocity += knockbackForce;
```

This allows components to use engine data without knowing whether the owner is `ECharacter`, another character type, or a future compatible class.

---

## Component To Component

Components communicate through the Entity:

```csharp
Entity.GetComponent<CStates>().AddState("Attacking", duration);
```

This avoids hidden direct wiring between components while still allowing systems to work together.

---

## Owner Class To Component

The owning class creates and stores the component references it needs to call from Godot callbacks:

```csharp
public override void _Process(double delta)
{
    Cstates.HandleStates(delta);
    CmainStates.HandleMainStates();
    CmainAnimations.MainAnimations();
    MoveAndSlide();
}
```

The owner should mostly forward Godot lifecycle events, animation events, and input events into components.

---

# Naming

Use these prefixes:

* **E** for gameplay owner classes, such as `ECharacter`
* **I** for interfaces, such as `IVelocity`
* **C** for components, such as `CHealth`

---

# Design Checklist

When adding new behavior, ask:

* Is this gameplay logic? Put it in a component.
* Is this gameplay data created by that logic? Store it in the component.
* Is this built-in engine data from the owner? Expose it through an interface.
* Does one component need another component? Access it through the Entity.
* Does the owner need to react to a Godot callback? Forward that callback into a component.

The goal is to keep gameplay systems modular while keeping engine-specific data access clean and limited.

---
