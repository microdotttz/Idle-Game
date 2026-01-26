# Potion Shop Tycoon - Game Design Document

## Overview
A cozy fantasy idle game where you run a potion shop with an expanding back-room workshop. Grow ingredients, extract essences, process materials through magical machines, brew potions, and build an alchemical empire.

## Core Loop
```
Gather Raw Materials → Process & Refine → Brew Potions → Sell → Expand Workshop → Repeat
```

---

## Resource System

### Resource Tiers
Materials flow through increasingly refined states:

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    RAW      │ →  │  PROCESSED  │ →  │   REFINED   │ →  │  ENCHANTED  │
│  (Gather)   │    │  (Extract)  │    │  (Purify)   │    │  (Infuse)   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
   Moonpetal    →    Lunar Essence  →   Pure Moonlight →  Celestial Dew
   Firefern     →    Ember Extract  →   Condensed Flame → Phoenix Tears
   Crystalstone →    Crystal Dust   →   Resonant Shard  → Mana Crystal
```

### Resource Categories

**Botanical** (grown in garden)
| Raw | Processed | Refined | Enchanted |
|-----|-----------|---------|-----------|
| Moonpetal | Lunar Essence | Pure Moonlight | Celestial Dew |
| Firefern | Ember Extract | Condensed Flame | Phoenix Tears |
| Whisperroot | Spirit Sap | Ghost Vapor | Ethereal Mist |
| Frostbloom | Ice Nectar | Frozen Core | Permafrost Crystal |
| Shadowmoss | Dark Residue | Void Dust | Null Essence |

**Mineral** (mined from caves/expeditions)
| Raw | Processed | Refined | Enchanted |
|-----|-----------|---------|-----------|
| Crystalstone | Crystal Dust | Resonant Shard | Mana Crystal |
| Iron Ore | Iron Filings | Tempered Iron | Runic Iron |
| Sulfite | Sulfur Powder | Brimite | Hellite |
| Salt Rock | Pure Salt | Blessed Salt | Divine Salt |
| Moonite Ore | Moonite Dust | Moon Silver | Astral Silver |

**Creature** (from expeditions/visitors)
| Raw | Processed | Refined | Enchanted |
|-----|-----------|---------|-----------|
| Slime Glob | Slime Extract | Purified Gel | Living Ooze |
| Dragon Scale | Scale Powder | Dragon Essence | Dragonheart |
| Fairy Wing | Wing Dust | Pixie Powder | Fey Sparkle |
| Basilisk Eye | Eye Fluid | Petrify Serum | Stone Gaze |
| Phoenix Feather | Ash Residue | Rebirth Powder | Eternal Ember |

**Elemental** (from magical sources)
| Raw | Processed | Refined | Enchanted |
|-----|-----------|---------|-----------|
| Raw Mana | Mana Drops | Pure Mana | Arcane Essence |
| Sunlight (captured) | Solar Extract | Radiance | Divine Light |
| Stormcloud | Lightning Bottle | Thunder Essence | Storm Core |
| Spring Water | Blessed Water | Holy Water | Sacred Tears |
| Void Fragment | Null Powder | Dark Matter | Oblivion Dust |

---

## Machines & Workshop

### Workshop Layout
Your shop has an expandable back room where machines are placed on a grid.

```
┌─────────────────────────────────────────┐
│              WORKSHOP FLOOR             │
├─────────────────────────────────────────┤
│  ┌─────┐   ┌─────┐   ┌─────┐           │
│  │GRIND│ → │STILL│ → │INFUS│           │
│  │ ER  │   │     │   │ ER  │           │
│  └─────┘   └─────┘   └─────┘           │
│     ↑                    ↓              │
│  ┌─────┐              ┌─────┐          │
│  │STORE│              │CAULD│ → [SHELF]│
│  │     │              │ RON │          │
│  └─────┘              └─────┘          │
│                                         │
│  [+] Add Machine     [Expand Floor]    │
└─────────────────────────────────────────┘
```

### Machine Categories

#### Tier 1: Extraction Machines
*Convert raw materials to processed*

| Machine | Input | Output | Time | Unlock |
|---------|-------|--------|------|--------|
| **Mortar & Pestle** | Any botanical | Powder/Extract | 30s | Start |
| **Herb Press** | Soft botanicals | Essence/Juice | 45s | 100g |
| **Grinder** | Minerals/Hard items | Dust/Powder | 1m | 250g |
| **Specimen Jar** | Creature parts | Preserved Extract | 2m | 500g |
| **Mana Tap** | Elemental sources | Liquid mana | 1m | 750g |

#### Tier 2: Processing Machines
*Convert processed materials to refined*

| Machine | Function | Time | Unlock |
|---------|----------|------|--------|
| **Alembic Still** | Distill liquids into concentrated form | 2m | 1,000g |
| **Crystallizer** | Convert liquids to solid crystals | 3m | 1,500g |
| **Calcinator** | Burn materials to pure ash/powder | 2m | 2,000g |
| **Centrifuge** | Separate mixtures into components | 1.5m | 2,500g |
| **Condenser** | Convert gases to liquids | 2m | 3,000g |

#### Tier 3: Refinement Machines
*Create enchanted-tier materials*

| Machine | Function | Time | Unlock |
|---------|----------|------|--------|
| **Mana Infuser** | Infuse refined materials with raw mana | 5m | 10,000g |
| **Enchanting Circle** | Apply magical properties | 8m | 15,000g |
| **Philosopher's Engine** | Transmute materials | 10m | 25,000g |
| **Lunar Attuner** | Moon-align materials (night bonus) | 6m | 20,000g |
| **Dragon Forge** | Extreme heat processing | 5m | 30,000g |

#### Tier 4: Specialty Machines
*Unique effects and combinations*

| Machine | Function | Special |
|---------|----------|---------|
| **Combiner** | Merge 2 materials of same tier | Creates hybrid ingredients |
| **Splitter** | Split 1 material into 2 lesser | Get components back |
| **Duplicator** | Slow copy of materials | 10% chance, consumes mana |
| **Aging Barrel** | Materials improve over real time | Hours/days for bonuses |
| **Weather Collector** | Passive resource from weather | Rain, sun, storm = different |
| **Greenhouse Dome** | Accelerated plant growth | 2x speed, needs sunlight |

#### Brewing Machines
*The final step - making potions*

| Machine | Capacity | Speed | Special |
|---------|----------|-------|---------|
| **Basic Cauldron** | 1 potion | 1x | Starting equipment |
| **Copper Cauldron** | 1 potion | 1.5x | Faster brewing |
| **Silver Cauldron** | 2 potions | 1.5x | Queue 2 at once |
| **Enchanted Cauldron** | 3 potions | 2x | Quality bonus |
| **Arcane Crucible** | 5 potions | 3x | Can brew Legendary potions |
| **Auto-Brewer** | 2 potions | 1x | Automatically repeats last recipe |

---

## Production Chains

### Example Chain: Health Potion (Basic)
```
Moonpetal → [Herb Press] → Lunar Essence → [Cauldron + Water] → Health Potion
```

### Example Chain: Greater Health Potion
```
Moonpetal → [Herb Press] → Lunar Essence
                               ↓
                          [Alembic Still]
                               ↓
                         Pure Moonlight
                               ↓
Raw Mana → [Mana Tap] → Mana Drops → [Combiner] → Mana-Infused Moonlight
                                          ↓
                                    [Enchanted Cauldron]
                                          ↓
                                  Greater Health Potion
```

### Example Chain: Legendary Fire Immunity
```
Firefern → [Calcinator] → Ember Ash → [Crystallizer] → Flame Crystal
                                                            ↓
Phoenix Feather → [Grinder] → Ash → [Mana Infuser] → Eternal Ember
                                                            ↓
Dragon Scale → [Grinder] → Scale Powder ────────────→ [Arcane Crucible]
                                                            ↓
                                                   Fire Immunity Elixir
```

### Chain Complexity by Tier

| Potion Tier | Steps | Materials | Example |
|-------------|-------|-----------|---------|
| Common | 1-2 | 1-2 | Health Potion |
| Uncommon | 2-3 | 2-3 | Fire Resistance |
| Rare | 3-4 | 3-4 | Invisibility |
| Epic | 4-5 | 4-5 | Flying Potion |
| Legendary | 5-7 | 5+ | Immortality Draught |

---

## Machine Upgrades

Each machine can be upgraded along three paths:

### Speed Track
- Level 1: Base speed
- Level 2: +25% speed (cost: 2x base)
- Level 3: +50% speed (cost: 5x base)
- Level 4: +100% speed (cost: 10x base)
- Level 5: +200% speed (cost: 25x base)

### Efficiency Track
- Level 1: 1 input → 1 output
- Level 2: 10% chance for bonus output
- Level 3: 20% chance for bonus output
- Level 4: 30% chance + rare material chance
- Level 5: 50% chance + rare materials

### Automation Track
- Level 1: Manual operation
- Level 2: Auto-start when input available
- Level 3: Auto-pull from connected storage
- Level 4: Auto-push to next machine in chain
- Level 5: Full autonomous chain operation

---

## Conveyor & Connection System

### Material Flow
Connect machines to automate material movement:

```
[Storage] ═══► [Grinder] ═══► [Alembic] ═══► [Cauldron] ═══► [Shop Shelf]
```

**Connection Types:**
| Type | Function | Unlock |
|------|----------|--------|
| Basic Pipe | Move items slowly | Start |
| Quick Pipe | 2x speed | 1,000g |
| Smart Pipe | Filter by material type | 2,500g |
| Splitter Pipe | Send to multiple destinations | 5,000g |
| Priority Pipe | Fill first machine, overflow to second | 7,500g |

### Storage Units
| Storage | Capacity | Special |
|---------|----------|---------|
| Crate | 50 items | Basic |
| Chest | 200 items | Organized by type |
| Vault | 500 items | Preserves freshness |
| Warehouse | 2000 items | Unlocks at Franchise |
| Pocket Dimension | 10000 items | End-game |

---

## Ingredient Sources

### 1. Garden (Botanicals)
- Unlock plots (4 → 8 → 16 → 32)
- Plant seeds, harvest when ready
- Soil upgrades affect growth speed
- Greenhouse for rare plants

### 2. Mine (Minerals)
- Unlock mine access at reputation tier 2
- Send expeditions (time-based)
- Upgrade pickaxes for better yields
- Deeper levels = rarer ores

### 3. Elemental Collection
- Weather Collector (passive)
- Mana Well (generates raw mana)
- Sunlight Prism (daytime only)
- Moonlight Basin (nighttime only)
- Elemental Shrines (build for specific types)

### 4. Trading
- Traveling merchants (random visits)
- Trade routes (unlock regions)
- Other players (if multiplayer)
- Black market (risky but rare items)

---

## Side Professions

Side professions are active mini-activities that provide ingredients, gold, and unique materials. Each has its own progression track and equipment upgrades.

### Fishing

**Overview**: Cast your line in various bodies of water to catch fish and aquatic ingredients.

**Locations** (unlock progressively)
| Location | Unlock | Fish Types | Special Catches |
|----------|--------|------------|-----------------|
| Village Pond | Start | Common fish | Old Boot (junk), Freshwater Pearl |
| Forest Stream | 500g | Trout, Salamander | Spirit Fish (night only) |
| River Delta | 2,000g | Catfish, Eel, Crab | River Serpent Scale |
| Ocean Pier | 5,000g | Sea Bass, Octopus, Shark | Mermaid's Tear, Kraken Ink |
| Underground Lake | 10,000g | Blind Cave Fish, Glowfin | Abyssal Pearl, Cave Coral |
| Elemental Springs | 25,000g | Magma Koi, Frost Trout | Elemental Fish Essence |

**Fishing Mechanics**
- **Cast**: Choose location, wait for bite (10-60 sec based on rarity)
- **Catch**: Simple timing mini-game (tap when indicator in zone)
- **Idle Option**: Auto-fish with reduced rare chance when unlocked

**Equipment Upgrades**
| Item | Effect | Cost |
|------|--------|------|
| Basic Rod | Starting equipment | Free |
| Bamboo Rod | -10% wait time | 200g |
| Ironwood Rod | -20% wait time, +rare chance | 1,000g |
| Enchanted Rod | -30% wait, +15% rare | 5,000g |
| Mythril Rod | -50% wait, +25% rare | 20,000g |
| Lure Set | +specific fish type chance | 500g each |
| Tackle Box | Store more bait types | 2,000g |
| Magic Bobber | Auto-catch common fish | 10,000g |

**Fish Uses**
| Fish Type | Use |
|-----------|-----|
| Common Fish | Sell for gold, or process into Fish Oil |
| Eel | Electric Essence for lightning potions |
| Octopus | Ink for invisibility potions |
| Glowfin | Bioluminescent Extract |
| Spirit Fish | Ghost Vapor ingredient |
| Elemental Fish | Rare elemental essences |

**Fishing Skill**
- Gain XP per catch
- Higher skill = faster catches, rarer fish, new locations
- Skill levels: Novice → Apprentice → Journeyman → Expert → Master → Legendary

---

### Hunting

**Overview**: Track and hunt creatures in the wilds for parts, pelts, and rare materials.

**Hunting Grounds** (unlock progressively)
| Location | Unlock | Creatures | Rare Spawns |
|----------|--------|-----------|-------------|
| Forest Edge | Start | Rabbits, Deer, Boar | Giant Stag |
| Deep Woods | 1,000g | Wolves, Bears, Owls | Dire Wolf, Forest Spirit |
| Swamplands | 3,000g | Frogs, Snakes, Gators | Hydra, Swamp Hag |
| Mountain Pass | 8,000g | Goats, Eagles, Mountain Lions | Griffin, Stone Golem |
| Dragon Foothills | 20,000g | Wyverns, Drakes, Fire Beetles | Young Dragon |
| Enchanted Forest | 15,000g | Unicorns*, Fairies*, Treants | Ancient Treant |
| Shadow Realm | 50,000g | Shadow Beasts, Wraiths | Nightmare, Shadow Dragon |

*Non-lethal collection (hair, shed wings, sap)

**Hunting Mechanics**
- **Track**: Spend time finding creature (1-5 min based on rarity)
- **Hunt**: Simple combat/timing game or auto-resolve based on gear
- **Harvest**: Collect parts from successful hunt

**Hunting Styles**
| Style | Pros | Cons |
|-------|------|------|
| **Trapping** | Passive income, safe | Slow, common creatures only |
| **Bow Hunting** | Ranged, stealthy | Skill-based mini-game |
| **Direct Combat** | Fast, any creature | Gear dependent, risky |
| **Taming** | Renewable resource | Very slow, limited creatures |

**Equipment**
| Item | Effect | Cost |
|------|--------|------|
| Hunting Knife | Basic harvesting | Free |
| Short Bow | Hunt small creatures | 300g |
| Longbow | Hunt medium creatures | 1,500g |
| Crossbow | Hunt large creatures, auto-aim | 5,000g |
| Hunting Traps (x5) | Passive catches | 500g |
| Camouflage Cloak | +rare creature chance | 3,000g |
| Beast Whistle | Attract specific types | 2,000g |
| Enchanted Quiver | Unlimited basic arrows | 8,000g |
| Dragon-bone Bow | Hunt legendary creatures | 50,000g |

**Creature Parts & Uses**
| Part | Source | Potion Use |
|------|--------|------------|
| Rabbit Foot | Rabbit | Luck potions |
| Wolf Fang | Wolf | Strength potions |
| Bear Claw | Bear | Fortitude potions |
| Owl Feather | Owl | Wisdom/Night Vision potions |
| Snake Venom | Snake | Poison, Antidotes |
| Griffin Feather | Griffin | Flying potions |
| Dragon Scale | Drake/Dragon | Fire immunity, legendary |
| Unicorn Hair | Unicorn | Purity, healing potions |
| Shadow Essence | Shadow Beast | Invisibility, Void potions |

**Hunting Skill**
- Gain XP per hunt
- Higher skill = faster tracking, better yields, rare spawns
- Unlocks: Taming at Expert, Legendary hunts at Master

---

### Foraging

**Overview**: Explore wilderness areas to gather wild herbs, mushrooms, and natural materials.

**Foraging Areas**
| Area | Unlock | Common Finds | Rare Finds |
|------|--------|--------------|------------|
| Meadow | Start | Wildflowers, Common Herbs | Four-leaf Clover |
| Forest Floor | 300g | Mushrooms, Moss, Bark | Fairy Ring Mushroom |
| Riverbank | 800g | Watercress, River Clay, Reeds | Water Lily (night) |
| Mountain Slopes | 2,500g | Alpine Flowers, Lichen, Minerals | Edelweiss, Ice Moss |
| Ancient Ruins | 5,000g | Ancient Seeds, Rune Stones | Arcane Herbs |
| Fey Glade | 12,000g | Enchanted Herbs, Pixie Dust | Moonflower, Starbloom |
| Volcanic Fields | 20,000g | Fire Bloom,Ite Crystals, Ash | Phoenix Flower |

**Foraging Mechanics**
- **Explore**: Area takes time to search (2-10 min)
- **Gather**: Tap discovered items to collect
- **Discover**: Random chance for rare/hidden items
- **Idle Option**: Send assistant to forage with reduced rare chance

**Foraging Tools**
| Tool | Effect | Cost |
|------|--------|------|
| Woven Basket | Carry 10 items | Free |
| Herbalist Satchel | Carry 25 items, preserves freshness | 800g |
| Forager's Pack | Carry 50 items | 3,000g |
| Dowsing Rod | Highlights hidden items | 2,000g |
| Fairy Lantern | Access night-only plants anytime | 5,000g |
| Enchanted Gloves | Harvest without damage | 4,000g |
| Infinite Basket | No carry limit | 25,000g |

**Foraging Skill**
- Gain XP per item gathered
- Higher skill = see rarer items, faster gathering, bonus yields
- Master foragers can find seeds of any wild plant

---

### Expeditions (Advanced)

**Overview**: Send parties on longer journeys to distant lands for exotic materials.

**Expedition Types**
| Type | Duration | Risk | Reward |
|------|----------|------|--------|
| **Gathering Trip** | 1-4 hours | Low | Bulk common materials |
| **Hunting Expedition** | 4-8 hours | Medium | Rare creature parts |
| **Dungeon Delve** | 8-24 hours | High | Monster parts, treasures |
| **Dragon Hunt** | 24-48 hours | Very High | Legendary materials |
| **Planar Journey** | 48-72 hours | Extreme | Enchanted-tier materials |

**Expedition Mechanics**
- Hire adventurers or send assistants
- Equip them with supplies (potions from YOUR shop!)
- Wait for return
- Risk of failure = partial/no rewards
- Your potions increase success rate

**Adventurer Types**
| Type | Cost | Specialty |
|------|------|-----------|
| Scout | 100g/trip | Fast gathering, low risk |
| Hunter | 200g/trip | Creature expeditions |
| Knight | 500g/trip | Dungeon delves |
| Wizard | 750g/trip | Magical materials |
| Dragon Slayer | 2,000g/trip | Dragon hunts |
| Planeswalker | 5,000g/trip | Planar journeys |

---

### Profession Synergies

The side professions connect back to your main shop:

```
┌─────────────┐     ┌─────────────────┐     ┌─────────────┐
│  FISHING    │────→│                 │────→│   POTIONS   │
└─────────────┘     │                 │     └─────────────┘
                    │    WORKSHOP     │
┌─────────────┐     │    MACHINES     │     ┌─────────────┐
│  HUNTING    │────→│                 │────→│   CUSTOMERS │
└─────────────┘     │                 │     └─────────────┘
                    │                 │
┌─────────────┐     │                 │     ┌─────────────┐
│  FORAGING   │────→│                 │────→│   GOLD      │
└─────────────┘     └─────────────────┘     └─────────────┘
```

**Example Synergies**:
- Catch electric eels → Process in Specimen Jar → Lightning Essence → Haste Potion
- Hunt wolves → Grind fangs → Combine with herbs → Strength Potion
- Forage mushrooms → Age in barrel → Rare fermented ingredient
- Use YOUR potions to boost expedition success → Get rare materials → Make better potions

---

### Profession Skill Summary

| Profession | Skill Levels | Max Level Perk |
|------------|--------------|----------------|
| Fishing | 1-50 | Catch legendary sea creatures |
| Hunting | 1-50 | Tame dragons as assistants |
| Foraging | 1-50 | Grow any wild plant in garden |
| Expeditions | Reputation-based | Access to other realms |

---

## Potion Catalog

### Common Potions (1-2 ingredients)
| Potion | Effect | Sell Price |
|--------|--------|------------|
| Health Potion | Restore HP | 15g |
| Mana Potion | Restore MP | 15g |
| Stamina Tonic | Restore energy | 12g |
| Antidote | Cure poison | 20g |
| Wakefulness Brew | Cure sleep | 18g |

### Uncommon Potions (2-3 ingredients)
| Potion | Effect | Sell Price |
|--------|--------|------------|
| Fire Resistance | Resist fire | 50g |
| Frost Shield | Resist cold | 50g |
| Night Vision | See in dark | 45g |
| Water Breathing | Breathe underwater | 60g |
| Featherfall | Slow falling | 55g |

### Rare Potions (3-4 ingredients, refined)
| Potion | Effect | Sell Price |
|--------|--------|------------|
| Invisibility | Turn invisible | 200g |
| Giant Strength | +10 STR | 180g |
| Haste | Double speed | 220g |
| Stone Skin | Armor bonus | 190g |
| True Sight | See invisible/illusions | 250g |

### Epic Potions (4-5 ingredients, enchanted)
| Potion | Effect | Sell Price |
|--------|--------|------------|
| Flying | Grants flight | 800g |
| Polymorph | Transform | 750g |
| Time Slow | Slow time | 900g |
| Regeneration | Heal over time | 850g |
| Elemental Form | Become element | 950g |

### Legendary Potions (5+ ingredients, multi-chain)
| Potion | Effect | Sell Price |
|--------|--------|------------|
| Immortality Draught | 1 extra life | 5,000g |
| Philosopher's Elixir | Transmute items | 4,500g |
| Dragon's Blood | Dragonkin powers | 6,000g |
| Void Walker | Phase through walls | 5,500g |
| Ambrosia | Divine blessing | 10,000g |

---

## Customer System

### Customer Types & Wants

| Customer | Typical Order | Pays | Patience | Frequency |
|----------|---------------|------|----------|-----------|
| Villager | Common potions | 1x | High | Very Common |
| Adventurer | Combat potions | 1.2x | Medium | Common |
| Merchant | Bulk common | 0.9x each | High | Uncommon |
| Knight | Rare combat | 1.5x | Low | Uncommon |
| Wizard | Exotic/rare | 2x | Very Low | Rare |
| Noble | Cosmetic/luxury | 3x | None | Rare |
| Royal Courier | Legendary | 5x | None | Very Rare |
| Dragon | Specific legendary | 10x | None | Extremely Rare |

### Special Orders
- Customers may request specific potions not on shelves
- Time limit to fulfill
- Bonus gold + reputation if completed
- Chain quests from recurring customers

### Bulk Contracts
- Guilds/kingdoms place standing orders
- "Deliver 50 Health Potions per day"
- Guaranteed income but must maintain supply
- Penalties for missed deliveries

---

## Workshop Expansion

### Floor Space
| Level | Grid Size | Cost |
|-------|-----------|------|
| 1 | 3x3 | Start |
| 2 | 4x4 | 2,000g |
| 3 | 5x5 | 5,000g |
| 4 | 6x6 | 10,000g |
| 5 | 7x7 | 25,000g |
| 6 | 8x8 | 50,000g |
| 7+ | 9x9+ | Prestige |

### Special Rooms (Unlockable)
| Room | Function | Unlock |
|------|----------|--------|
| **Cold Storage** | Preserve freshness longer | 5,000g |
| **Research Lab** | Discover recipes faster | 10,000g |
| **Greenhouse** | Grow rare plants | 15,000g |
| **Mine Shaft** | Direct mineral access | 20,000g |
| **Summoning Circle** | Call creature merchants | 25,000g |
| **Observatory** | Boost night/celestial crafting | 30,000g |
| **Dragon Lair** | House a dragon assistant | 100,000g |

---

## Progression & Prestige

### Reputation Tiers
| Tier | Title | Unlocks |
|------|-------|---------|
| 1 | Street Vendor | Basic shop |
| 2 | Apprentice Alchemist | Mine access, Tier 2 machines |
| 3 | Journeyman Alchemist | Expeditions, Tier 3 machines |
| 4 | Master Alchemist | Rare customers, Tier 4 machines |
| 5 | Arcane Chemist | Legendary recipes |
| 6 | Royal Purveyor | Kingdom contracts |
| 7 | Legendary Alchemist | Franchise system |

### Prestige: Franchise Expansion
Open new shops in different regions:

| Region | Specialty | Unique Resources |
|--------|-----------|------------------|
| Forest Village | Botanicals | Rare herbs, Fey materials |
| Port Town | Trading | Sea creatures, Imports |
| Mountain Keep | Minerals | Rare ores, Dwarven tech |
| Desert Oasis | Elemental | Sun/heat materials |
| Frozen North | Preservation | Ice/cold materials |
| Royal Capital | Customers | High-value sales |
| Wizard Academy | Research | Recipe discovery boost |
| Dragon Peaks | Legendary | Dragon materials |

Each franchise:
- Generates passive income
- Ships materials to main shop
- Has unique machines/recipes
- Can be visited and managed

---

## Assistants & Automation

### Hireable Assistants
| Assistant | Role | Cost | Upkeep |
|-----------|------|------|--------|
| Garden Sprite | Auto-plant, water, harvest | 500g | 10g/day |
| Mine Goblin | Auto-mine basic ores | 1,000g | 20g/day |
| Workshop Imp | Operate 1 machine chain | 2,000g | 30g/day |
| Brew Familiar | Queue basic potions | 3,000g | 40g/day |
| Shop Assistant | Restock shelves, greet customers | 4,000g | 50g/day |
| Accountant Owl | Optimize pricing | 5,000g | 60g/day |
| Master Alchemist | Operate complex chains | 20,000g | 200g/day |
| Dragon | Guard shop, scare thieves, fire processing | 100,000g | 500g/day |

### Automation Priority
Late-game goal: Fully automated shop
1. Auto-harvest ingredients
2. Auto-feed to processing chains
3. Auto-brew based on demand
4. Auto-stock shelves
5. Auto-price based on supply/demand
6. You just collect profits and expand

---

## Economy Balance

### Resource Values (approximate)
| Tier | Example | Value |
|------|---------|-------|
| Raw | Moonpetal | 2g |
| Processed | Lunar Essence | 8g |
| Refined | Pure Moonlight | 30g |
| Enchanted | Celestial Dew | 120g |

### Time vs Value
| Activity | Time | Gold/Minute |
|----------|------|-------------|
| Sell raw herbs | 1 min grow | 2g/min |
| Basic potions | 2 min total | 7g/min |
| Processed potions | 5 min total | 15g/min |
| Refined potions | 15 min total | 25g/min |
| Legendary potions | 60 min total | 80g/min |

Complex chains = more profit but more management

---

## UI/UX Design

### Main Tabs
```
┌─────────────────────────────────────┐
│  [Shop] [Workshop] [Garden] [Map]  │
└─────────────────────────────────────┘
```

### Workshop View
```
┌─────────────────────────────────────┐
│  Gold: 12,345g    Mana: 234        │
├─────────────────────────────────────┤
│                                     │
│   ┌───┐ ═══ ┌───┐ ═══ ┌───┐       │
│   │ G │     │ A │     │ C │       │
│   │80%│     │25%│     │ ✓ │       │
│   └───┘     └───┘     └───┘       │
│                                     │
│   ┌───┐     ┌───┐                  │
│   │ S │     │ I │                  │
│   │234│     │ ⏳ │                  │
│   └───┘     └───┘                  │
│                                     │
├─────────────────────────────────────┤
│ [+Add] [Connect] [Upgrade] [Move]  │
└─────────────────────────────────────┘

G = Grinder (80% complete)
A = Alembic (25% complete)
C = Cauldron (ready - checkmark)
S = Storage (234 items)
I = Infuser (waiting for input)
```

### Touch Interactions
- **Tap machine**: View details/collect output
- **Long press**: Quick actions menu
- **Drag between machines**: Create connection
- **Pinch**: Zoom in/out of workshop
- **Double tap empty space**: Quick-add machine

---

## Session Design

### Quick Check-in (1-2 min)
1. See offline earnings summary
2. Collect completed products
3. Clear machine outputs
4. Restock shop shelves
5. Done!

### Active Play (10-20 min)
- Optimize production chains
- Experiment with new recipes
- Rearrange workshop layout
- Handle special customer orders
- Plan expansion/upgrades
- Manage expeditions

### Deep Session (30+ min)
- Design new production chains
- Prestige planning
- Achievement hunting
- Franchise management
- Event participation

---

## MVP Phases

### Phase 1: Core Mechanics
- [ ] 4 raw ingredients (1 from each category)
- [ ] 3 extraction machines
- [ ] 2 processing machines
- [ ] 1 cauldron
- [ ] 5 basic potions
- [ ] 2 customer types
- [ ] Basic gold economy
- [ ] Simple storage

### Phase 2: Production Depth
- [ ] 12+ ingredients across tiers
- [ ] Full extraction machine set
- [ ] Processing & refinement machines
- [ ] Pipe/connection system
- [ ] 15+ potion recipes
- [ ] Recipe discovery

### Phase 3: Automation
- [ ] Machine upgrades (speed/efficiency/auto)
- [ ] Assistants system
- [ ] Auto-brewing
- [ ] Smart storage

### Phase 4: Expansion
- [ ] Full workshop grid
- [ ] Special rooms
- [ ] All customer types
- [ ] Reputation system

### Phase 5: Prestige
- [ ] Franchise system
- [ ] Multiple regions
- [ ] Legendary potions
- [ ] End-game content

---

## Open Questions

1. **Art Style**: Pixel art? Illustrated? Isometric?
2. **Workshop View**: Top-down grid? Isometric? Side-view?
3. **Complexity Balance**: How many machines is too many?
4. **Tutorial**: Guided start or exploratory?
5. **Monetization**: Cosmetics? Time skips? Ad-supported? Premium?
6. **Platform**: Mobile-only or also PC/web?

---

*Build your alchemical empire, one potion at a time!*
