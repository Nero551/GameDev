# DICES Framework

The **DICES Framework** is a lightweight gameplay architecture for Godot designed around strict ownership rules and modular gameplay design.

It is built around five core concepts:

- Data
- Interfaces
- Components
- Entities
- Services

---

# Core Principle

> Data defines data.  
> Interfaces define capabilities.  
> Components define behavior.  
> Entities define objects and coordination.  
> Services define global systems.

---

# Data

**Data** is raw information with no behavior.

It is used as input for systems.

## Examples

- JSON data
- Config files

---

# Interfaces

Interfaces expose **capabilities provided by the engine or owner class**.

They allow components to access engine-level data without coupling to concrete types.

## Rules

- Interfaces do not store gameplay data
- Interfaces expose capabilities, not logic
- Interfaces expose class capabilities provided by the engine

## Example

```csharp
public interface IVelocity{	Vector3 Velocity { get; set; }}
```

## Usage

```csharp
Entity.GetInterface<IVelocity>().Velocity += knockback;
```

---

# Components

A **Component** is a self-contained gameplay system.

Each component owns a single responsibility.

## Responsibilities

- Owns a gameplay system
- Stores state for that system
- Executes logic for that system
- Is reusable across entities

## Examples

- Health
- Movement
- Combat
- Animation

## Example

```csharp
public partial class CHealth : Component
{
    public float MaxHealth = 100;
    public float CurrentHealth = 100;
    public void TakeDamage(float amount)
    {
        CurrentHealth -= amount;        
    }
}
```

---

# Entities

An **Entity** is a gameplay object that exists in the world.

It is the composition root of all gameplay behavior.

## Responsibilities

- Owns and manages a ComponentHost
- Acts as a communication hub between components
- Forwards engine callbacks (Godot lifecycle events)
- Represents a complete gameplay object
- It can implement its own logic if it relates to its identity and isn't reusable

## Rules

- Entities do not contain complex gameplay logic
- Entities remain lightweight

## Example

```csharp
ComponentHost = new ComponentHost(this);
ComponentHost.AddComponent<CHealth>();
ComponentHost.AddComponent<CMovement>();
ComponentHost.AddComponent<CCombat>();
```

---

## Important Note

Because of Godot’s inheritance-based system, an Entity is a separate class that exists as a Node-based object.  
The object can still be categorized as an Entity even if it does not contain a ComponentHost.

However, when it **does use components**, it owns a ComponentHost to manage them.

---

# Services

A **Service** is a global system that operates independently of entities.

Services handle game-wide functionality.

## Responsibilities

- Global systems (audio, saving, scene management)
- Cross-entity coordination
- Resource management
- Game-wide logic

## Examples

- AudioService
- SceneService
- SaveService

## Example

```csharp
AudioService.Play("Hit");
```

## Rules

- Services are globally accessible
- Services do not depend on specific entities
- Services operate at game level, not object level

---

# Ownership Rules

## Data

Use when:

- Information has no behavior
- It is used as input only

## Interfaces

Use when:

- Engine-level data must be accessed safely
- Multiple components need shared capabilities

## Components

Use when:

- Logic belongs to a specific system
- Behavior should be reusable
- State is local to that system

## Entities

Use when:

- Something exists in the world
- It has lifecycle
- It is a complete gameplay object

## Services

Use when:

- System is global
- It affects multiple entities
- It does not belong to a single object

---

# Communication Rules

## Component → Component

All communication goes through the ComponentHost.

```csharp
ComponentHost.GetComponent<CStates>().SetState("Attacking");
```

---

## Component → Engine

Through Interfaces.

```csharp
Entity.GetInterface<IVelocity>().Velocity += knockback;
```

---

## Component / Entity → Service

Global access.

```csharp
AudioService.Play("Jump");
```

---

## Entity → ComponentHost → Component

Entities forward engine events and access systems through ComponentHost.

```csharp
public override void _Process(double delta)
{
	ComponentHost.GetComponent<CMovement>().Process(delta);
	ComponentHost.GetComponent<CHealth>().Process(delta);
}
```

---

# Naming Conventions

- Data → Data assets
- I → Interfaces
- C → Components
- Entities don't have a prefix or suffix, just call it whatever it is.
- Service → Services

---

# Goal of DICES

The DICES Framework aims to:

- Keep gameplay systems modular
- Maintain clear ownership rules
- Avoid inheritance complexity
- Separate gameplay logic from engine access
- Stay compatible with Godot’s scene system

---

# Final Architecture Identity

The DICES Framework is:

> A component-based gameplay architecture with service-layer global systems and interface-based engine abstraction.

It is NOT ECS.

It is a hybrid system designed around Godot’s scene-based architecture.

---

# Final Takeaway

Everything in the project has a clear place:

- Data → raw information
- Interfaces → engine capability access
- Components → gameplay systems
- Entities → gameplay objects (Node + optional ComponentHost)
- Services → global systems