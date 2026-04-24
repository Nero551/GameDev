
---

# 🎮 GAME DESIGN DOCUMENT (v2)

## 1. Core Concept

**Genre:** Action RPG (Skill-based combat, progression-heavy)  
**Perspective:** Likely 3D third-person (fits your Godot setup)

### High Concept

You are part of an empire that **conquers worlds**.  
Each world has:

- Different environments
    
- Unique materials
    
- Distinct combat styles / resistances
    

The twist:

> You are not the hero — you are part of the conquering force… until something goes wrong.

---

## 2. Core Pillars

These define your game. Everything should support them.

### 1. Skill-Based Combat

- No brainless clicking
    
- Timing, positioning, stamina management matter
    

### 2. Build Freedom

- Player defines their playstyle:
    
    - Melee
        
    - Magic (Arts)
        
    - Hybrid
        
    - Status / chemistry-based
        

### 3. System Depth (Chemistry Idea 🔥)

- Mana = ATP (energy system)
    
- Materials interact logically
    
- Crafting is not just recipes → it's experimentation
    

### 4. World Progression Through Conquest

- Each world expands gameplay systems
    
- Not just new enemies → new mechanics
    

---

## 3. Core Gameplay Loop

**Moment-to-moment:**

1. Explore
    
2. Fight enemies
    
3. Manage stamina/mana
    
4. Use abilities (Arts)
    
5. Loot materials
    

**Mid loop:**

1. Return / rest
    
2. Craft / upgrade
    
3. Improve build
    

**Long loop:**

1. Unlock new world
    
2. Gain new mechanics
    
3. Adapt build to new challenges
    

---

## 4. Combat System

### Base Controls

- **M1** → Main Hand Weapon
    
- **M2** → Off Hand Weapon
    
- **Shift** → Dodge (i-frames potential)
    
- **Abilities (Arts)** → bound keys
    

---

### Core Mechanics

#### 1. Stamina System

- Consumed by:
    
    - Attacks
        
    - Dodging
        
- Prevents spam
    
- Forces pacing
    

#### 2. Mana (ATP System)

- Used for abilities (Arts)
    
- Regeneration tied to:
    
    - Rest
        
    - Possibly items or mechanics
        

👉 This is where you can go deeper later (fatigue, overload, etc.)

---

#### 3. Hit System

- Weapon hitboxes triggered via animation markers (you already started this ✔)
    
- Different hit types:
    
    - Light
        
    - Heavy
        
    - Ability-based
        

---

#### 4. Damage Types (Important Expansion)

You _need this_ for depth:

- Physical
    
- Fire
    
- Frost
    
- Lightning
    
- Chemical (poison, corrosion, etc.)
    

Enemies resist differently → forces build diversity

---

#### 5. Status Effects

- Burn
    
- Freeze / slow
    
- Poison
    
- Shock
    

These tie directly into your **chemistry system**

---

## 5. Weapons System

### Weapon Types

- Swords
    
- Staffs
    
- Possibly fists (you already have this)
    

### Each weapon defines:

- Attack speed
    
- Combo pattern
    
- Scaling (strength vs magic)
    
- Special mechanic
    

Example:

- Staff → weaker melee, strong arts scaling
    
- Sword → balanced
    
- Fist → fast, stamina-heavy
    

---

## 6. Arts (Abilities System)

This is one of your strongest ideas.

### What are Arts?

Special abilities powered by mana (ATP)

### Types:

- Offensive
    
- Defensive
    
- Utility
    

---

### System Design (Improved)

Instead of random abilities:

Each Art should have:

- Cost (mana)
    
- Cooldown OR cast constraint
    
- Scaling stat
    
- Element/type
    

---

### Future Expansion (VERY IMPORTANT)

You can evolve this into:

- **Modular abilities**
    
    - Base + modifier
        
    - Example:
        
        - Fireball + spread
            
        - Dash + shockwave
            

---

## 7. Chemistry / Crafting System (Your Unique Selling Point)

This is your **standout feature**. Don’t make it shallow.

### Core Idea

Materials are not just items — they have **properties**

Example properties:

- Reactive
    
- Toxic
    
- Flammable
    
- Stable
    

---

### Crafting System

Instead of:

> "3 herbs = potion"

You do:

> Combine properties → result emerges

---

### Example

- Fire material + unstable material → explosion potion
    
- Toxic + liquid → poison vial
    

---

### Big Opportunity

You can allow:

- Discovery (player finds combos)
    
- Mistakes (bad mixtures)
    
- Rare reactions
    

This is what can make your game feel **different from every Roblox-style RPG**

---

## 8. Progression System

### Player Growth

- Stats (optional, but recommended):
    
    - Strength
        
    - Agility
        
    - Intelligence
        

OR

- Usage-based:
    
    - Use swords → get better at swords
        
    - Use magic → improve magic
        

---

### Mastery System (Recommended)

Each weapon/skill:

- Levels up with use
    
- Unlocks:
    
    - New combos
        
    - New effects
        

---

### Resistances

- Player builds resistance to damage types
    
- Important for world progression
    

---

## 9. World Design

### Structure

Multiple worlds:

- Each world introduces:
    
    - New enemies
        
    - New materials
        
    - New mechanics
        

---

### Narrative Direction

- You are part of an empire conquering worlds
    
- Later:
    
    - Betrayal / shift in perspective
        
    - Possibly rebellion
        

---

## 10. Enemy & AI System

### Basic Types

- Melee
    
- Ranged
    
- Ability users
    

---

### Behavior Layers

Start simple:

- Chase
    
- Attack
    
- Cooldown
    

Then expand:

- Dodge
    
- Group behavior
    
- Weak points
    

---

## 11. Development Roadmap (Important for YOU)

Based on your current stage:

### Phase 1 (YOU ARE HERE)

- ✅ Movement
    
- 🔄 Combat base (finish this properly)
    
- 🔄 Animation + hit detection
    

---

### Phase 2

- Basic enemy AI
    
- Basic weapons
    
- Simple abilities (Arts v1)
    

---

### Phase 3

- Inventory
    
- Crafting (simple first, NOT full chemistry yet)
    

---

### Phase 4

- Expand combat depth
    
- Add status effects
    
- Add progression
    

---

### Phase 5

- Chemistry system (full version)
    
- World expansion
    

---

## 12. Critical Feedback (Important)

I’m going to push you a bit here:

### What you're doing right:

- You’re building systems first → GOOD
    
- You’re thinking depth → VERY GOOD
    
- Chemistry idea → VERY STRONG
    

---

### What you need to fix:

1. **Don’t overdesign too early**
    
    - Your chemistry system is complex → don’t build it yet
        
2. **Finish ONE working loop first**
    
    - Movement + Combat + 1 enemy = playable
        
3. **Avoid feature explosion**
    
    - You have:
        
        - combat
            
        - abilities
            
        - crafting
            
        - chemistry
            
        - worlds  
            → too much at once if unmanaged
            

---