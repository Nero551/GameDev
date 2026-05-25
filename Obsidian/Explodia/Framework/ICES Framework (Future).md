# ICES Framework Overview

This project uses the **ICES Framework**, pronounced _"ices"_.

ICES is built around four core parts:

- **Entities**
- **Interfaces**
- **Components**
- **Systems**

The main rule is simple:

> **Entities contain components. Components contain gameplay data. Systems contain gameplay logic. Interfaces expose built-in engine data that systems need from the owning Godot class.**

---

# Core Design

## Entities

An **Entity** is the internal component container for one gameplay object.

Every main gameplay class creates an `Entity` instance, usually in `_Ready()`:

```csharp
Entity = Entity.Create(this);
```

The `Entity` is responsible for:

- Adding components
- Storing components
- Retrieving components
- Giving systems access to owner interfaces

Entities should stay lightweight.

They should **not** hold:

- Gameplay rules
- Character stats
- Animation state
- Combat state
- Movement decisions

That belongs in components and systems.

### Example

```csharp
Entity.AddComponent<CHealth>();

Entity.AddComponent<CMovement>();

Entity.AddComponent<CCombat>();
```

---

## Components

A **Component** owns a focused piece of gameplay data.

Components are responsible for:

- Storing gameplay state
- Storing data created by gameplay systems
- Remaining lightweight and reusable

Components should **not** contain gameplay behavior.

Systems operate on component data.

### Examples of Component-Owned Data

- Health values
- Movement speed
- Jump power
- Animation priority
- Timed states
- Combat swing counters
- Input state

### Example

```csharp
public partial class CHealth : Component
{
    public float MaxHealth = 100;
    public float CurrentHealth = 100;
}
```

Components should stay mostly data-oriented.

---

## Systems

A **System** owns gameplay behavior.

Systems are responsible for:

- Running gameplay logic
- Reading component data
- Modifying component data
- Coordinating interactions between gameplay systems
- Using interfaces to access engine functionality

### Example

```csharp
public partial class SHealth : System
{
    public void Damage(Entity entity, float damage)
    {
        CHealth health = entity.GetComponent<CHealth>();

        health.CurrentHealth -= damage;
    }
}
```

Systems communicate with components through the `Entity`:

```csharp
Entity.GetComponent<CHealth>().CurrentHealth -= damage;

Entity.GetComponent<CStates>().AddState("Attacking", duration);
```

Systems should contain the logic.

Components should contain the data.

---

## Interfaces

Interfaces are the bridge between systems and data that belongs to the owning Godot class or engine type.

Use interfaces for built-in data and engine capabilities that systems need but should not own.

### Examples

- `IVelocity` exposes `CharacterBody3D.Velocity`
- `IIsOnFloor` exposes `CharacterBody3D.IsOnFloor()`

```csharp
public interface IVelocity : Interface
{
    Vector3 Velocity { get; set; }
}
```

A system reads owner data through `Entity.GetInterface<T>()`:

```csharp
Vector3 velocity = Entity.GetInterface<IVelocity>().Velocity;
```

Interfaces should be limited to built-in engine data or engine behavior required by systems.

Avoid creating interfaces for data that a component can own directly.

---

# Ownership Rules

## Component-Owned Data

Put data in a component when:

- The data is created by gameplay logic
- The data belongs to a gameplay system
- The data can exist independently of the Godot base class
- The data should be reusable across multiple entity types

### Examples

- `CHealth.CurrentHealth`
- `CMovement.Speed`
- `CMovement.JumpPower`
- `CStates` state timers
- `CAnimations` animation priority

---

## System-Owned Logic

Put logic in a system when:

- The logic operates on gameplay data
- The logic may affect multiple entities
- The logic belongs to a gameplay feature
- The logic should stay reusable and centralized

### Examples

- Movement handling
- Combat calculations
- State updates
- Animation selection
- Health regeneration
- AI behavior

Systems should manipulate components rather than storing gameplay state themselves.

---

## Interface-Owned Data

Expose data through an interface when:

- The data already belongs to the Godot owner
- The data is built into an engine class
- A system needs access without depending on the concrete owner type

### Examples

- `Velocity` from `CharacterBody3D`
- `IsOnFloor()` from `CharacterBody3D`
- Node references required by engine systems

Interfaces should describe what the owner already has, not invent a new gameplay storage location.

---

# Communication Rules

## System → Owner

Systems communicate with the owning Godot class through interfaces:

```csharp
Entity.GetInterface<IVelocity>().Velocity += knockbackForce;
```

This allows systems to use engine data without knowing whether the owner is `ECharacter`, another character type, or a future compatible class.

---

## System → Component

Systems access gameplay data through the `Entity`:

```csharp
Entity.GetComponent<CStates>().AddState("Attacking", duration);
```

This keeps system relationships explicit and centralized.

---

## System → System

Systems should avoid tightly coupling to each other directly.

Prefer communication through:

- Components
- Events
- Shared entity state

This keeps systems modular and easier to maintain.

---

## Owner Class → Systems

The owning class forwards Godot lifecycle events into systems:

```csharp
public override void _PhysicsProcess(double delta)
{
    Smovement.Update(Entity, delta);

    Sstates.Update(Entity, delta);

    Sanimations.Update(Entity, delta);

    MoveAndSlide();
}
```

The owner should mostly forward:

- Godot lifecycle events
- Animation events
- Input events

into systems.

---

# System Runner

A central system runner can be used to manage:

- System update order
- Shared system execution
- Global gameplay systems
- Query-based processing

### Example

```csharp
public override void _PhysicsProcess(double delta)
{
    World.Run(delta);
}
```

The system runner is responsible for executing systems consistently.

Entities remain lightweight containers.

---

# Naming Conventions

Use these prefixes:

- **E** for gameplay owner classes  
  Example: `ECharacter`

- **I** for interfaces  
  Example: `IVelocity`

- **C** for components  
  Example: `CHealth`

- **S** for systems  
  Example: `SMovement`

---

# Design Checklist

When adding new behavior, ask:

- Is this gameplay logic? → Put it in a system.
- Is this gameplay data created by that logic? → Store it in a component.
- Is this built-in engine data from the owner? → Expose it through an interface.
- Does a system need gameplay data? → Access it through the `Entity`.
- Does the owner need to react to a Godot callback? → Forward that callback into a system.

---

# Goal

The goal of EICS is to:

- Keep gameplay systems modular
- Separate gameplay logic from gameplay data
- Keep ownership rules clear
- Keep engine-specific access isolated
- Avoid massive inheritance chains
- Allow systems and components to stay reusable across different entity types

The framework separates:

- **Gameplay data** → Components
- **Gameplay logic** → Systems
- **Engine data access** → Interfaces
- **System orchestration** → Entities and system runners

while keeping communication explicit and centralized.