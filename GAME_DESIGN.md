# Potion Shop Tycoon - Game Design Document

## Overview
A cozy fantasy idle game where you run a potion shop. Grow ingredients, brew potions, serve customers, and expand your magical business.

## Core Loop
```
Grow Ingredients → Brew Potions → Sell to Customers → Earn Gold → Upgrade/Expand → Repeat
```

---

## Core Systems

### 1. Ingredient Garden
Your shop has a garden where magical ingredients grow over real time.

**Basic Ingredients** (unlock at start)
| Ingredient | Grow Time | Used In |
|------------|-----------|---------|
| Moonpetal | 1 min | Health potions |
| Firefern | 2 min | Fire resistance |
| Whisperroot | 3 min | Mana potions |
| Coldcap Mushroom | 5 min | Frost potions |

**Progression**
- Unlock garden plots (start with 4, expand to 20+)
- Discover rare seeds from customers, quests, or breeding
- Upgrade soil quality → faster growth
- Hire garden sprites → auto-replant harvested plots

**Idle Mechanic**: Plants grow while offline. Return to harvest.

---

### 2. Brewing System
Combine ingredients to create potions. Brewing takes time.

**Brewing Stations**
- Start with 1 cauldron
- Unlock more stations, faster cauldrons, auto-brewers
- Each station can queue 1-3 potions (upgradeable)

**Recipe Discovery**
- Some recipes known at start (Health Potion, Mana Potion)
- Discover new recipes by:
  - Experimenting (combine ingredients, chance of discovery)
  - Buying recipe scrolls from traveling merchants
  - Customer requests ("Can you make something that...?")
  - Achievements/milestones

**Sample Recipes**
| Potion | Ingredients | Brew Time | Sell Price |
|--------|-------------|-----------|------------|
| Health Potion | 2x Moonpetal | 30 sec | 10g |
| Mana Potion | 2x Whisperroot | 45 sec | 15g |
| Fire Resistance | 1x Firefern, 1x Coldcap | 1 min | 25g |
| Invisibility | 2x Whisperroot, 1x Shadowbloom | 3 min | 100g |
| Love Potion | 1x Moonpetal, 1x Heartberry, 1x Rare Dew | 5 min | 200g |

**Quality System**
- Potions have quality: Common → Fine → Superior → Masterwork
- Quality affected by: ingredient freshness, cauldron level, your skill
- Higher quality = better price, happier customers

**Idle Mechanic**: Brewing queues continue offline.

---

### 3. Shop & Customers
Customers arrive automatically seeking potions.

**Customer Types**
| Type | Wants | Pays | Patience |
|------|-------|------|----------|
| Villager | Basic potions | Low | High |
| Adventurer | Combat potions | Medium | Medium |
| Knight | Bulk orders | High | Low |
| Wizard | Rare/exotic | Very High | Very Low |
| Noble | Cosmetic/luxury | Premium | None (leaves if not instant) |

**Shop Mechanics**
- Display shelves hold potions for sale
- Customers browse and buy what's available
- Out of stock = customer leaves (lost sale)
- Keep popular potions stocked!

**Reputation System**
- Fulfill orders → gain reputation
- Higher reputation → better customers, bulk orders, special requests
- Reputation tiers unlock new features

**Idle Mechanic**: Sales happen automatically from stocked shelves.

---

### 4. Assistants & Automation
Hire helpers to automate tasks.

| Assistant | Role | Cost |
|-----------|------|------|
| Garden Sprite | Auto-replants, waters | 500g |
| Brew Imp | Queues common potions | 1000g |
| Shop Fairy | Restocks shelves from storage | 2000g |
| Merchant Cat | Attracts more customers | 5000g |

Each assistant can be leveled up for efficiency.

---

### 5. Progression & Expansion

**Shop Upgrades**
- Larger garden (more plots)
- More brewing stations
- Bigger storage
- Fancier shop front (attracts better customers)
- Backroom laboratory (experiment with recipes)

**Player Progression**
- Brewing Skill: Affects quality and brew speed
- Herbalism: Affects plant yield and rare seed chance
- Charisma: Affects prices and customer frequency

**Prestige System: "Franchise"**
- Once you've mastered your shop, open a new branch in a different region
- Each region has unique ingredients, customers, and challenges
- Previous shop generates passive income
- Regions: Forest Village → Port Town → Mountain Keep → Royal Capital → Wizard Academy

---

## Economy Balance

### Currency
- **Gold**: Main currency for upgrades, seeds, assistants
- **Gems** (optional): Premium currency for cosmetics only (no pay-to-win)
- **Reputation Stars**: Unlock tiers and special content

### Offline Earnings Cap
- Max 8 hours of offline progress stored
- Encourages daily check-ins without punishment for missing days
- "Welcome back!" bonus for returning after absence

### Time Scaling (early game example)
| Action | Active Time | Passive Equivalent |
|--------|-------------|-------------------|
| Grow basic herb | 1 min | 1 min |
| Brew health potion | 30 sec | 30 sec |
| Sell to customer | 5 sec | 5 sec |
| Net income/min | ~20g active | ~15g passive |

---

## UI/UX Concept

### Main Screen (Portrait Mode)
```
┌─────────────────────────┐
│      POTION SHOP        │
│    [Gold: 1,234g]       │
├─────────────────────────┤
│                         │
│   ┌───┐ ┌───┐ ┌───┐    │
│   │ 🧪│ │ 🧪│ │ 🧪│    │  ← Shop Shelves
│   └───┘ └───┘ └───┘    │
│                         │
│   👤 → 🚶 → 👥          │  ← Customers
│                         │
├─────────────────────────┤
│  🌱 Garden    🔥 Brew   │  ← Tab Navigation
│  📦 Storage   ⭐ Upgrades│
└─────────────────────────┘
```

### Key Interactions
- **Tap** plant to harvest
- **Drag** ingredients to cauldron
- **Tap** potion to stock shelf
- **Swipe** between tabs

### Satisfying Feedback
- Sparkle effects on harvest
- Bubble animations while brewing
- Coin sounds on sales
- Level-up celebrations

---

## Session Design

### Quick Session (1-2 min)
1. Collect offline earnings
2. Harvest ready plants, replant
3. Check brew queues
4. Restock shelves
5. Done!

### Active Session (10-15 min)
- Experiment with new recipes
- Fulfill special customer orders
- Make upgrade decisions
- Optimize shop layout
- Progress story/quests

---

## Future Features (Post-MVP)

- **Seasonal Events**: Holiday ingredients, limited recipes
- **Customer Stories**: Recurring characters with mini-narratives
- **Competitions**: Weekly brewing contests
- **Visiting Merchants**: Rare ingredients, recipe trades
- **Shop Customization**: Decorations, themes
- **Alchemy Mastery**: Enchanting, potion combinations

---

## Technical Considerations

### Platform
- Mobile-first (iOS/Android)
- Portrait orientation
- Offline calculation on app resume

### Tech Stack Options
- **React Native** + TypeScript (cross-platform, web preview)
- **Flutter** (performant, single codebase)
- **Godot** (if more game-engine features needed)

### Save System
- Local save with cloud backup option
- Save on every significant action
- Offline time calculated on resume

---

## MVP Scope

### Phase 1: Core Loop
- [ ] Basic garden (4 plots, 4 ingredient types)
- [ ] Simple brewing (1 cauldron, 5 recipes)
- [ ] Customer sales (2 customer types)
- [ ] Gold economy
- [ ] Basic upgrades

### Phase 2: Depth
- [ ] More ingredients and recipes
- [ ] Quality system
- [ ] Assistants
- [ ] Recipe discovery

### Phase 3: Progression
- [ ] Reputation system
- [ ] Shop expansion
- [ ] Prestige/Franchise system

---

## Open Questions

1. **Art Style**: Pixel art? Illustrated? Minimalist?
2. **Narrative**: Pure sandbox or light story?
3. **Monetization**: Ads? Cosmetics? One-time purchase? Completely free?
4. **Multiplayer**: Any social features? Leaderboards? Trading?

---

*Let's brew something magical!* 🧪
