local Settings = {
    Debug = false,
}
--[[
    ! Skills:
        ? Categories:
            ? Personal Skills
            ?     Strength
            ?     Dexterity
            ?     Charisma
            ?     Stress Resistance
            ?     Driving
            ?     Weapong Handling
            ?     Hacking
            ? Crafting
            ?     Fabrication
            ?     Electrical Engineering
            ?     Carpentry
            ? Gathering
            ?     Farming
            ?     Fishing
            ?     Mining
            ?     Prospecting
            ? Crime
            ?     Weed
            ?     Coke
            ?     Meth
            ?     Chop Shop
            ?     Boosting
]]
local Categories = {
    ['Personal Skills'] = {
        name = 'Personal Skills',
        icon = 'fas fa-user',
        description = 'Personal development skills',
        hidden = false
    },
    ['Crafting'] = {
        name = 'Crafting',
        icon = 'fa-solid fa-screwdriver-wrench',
        description = 'Skills related to crafting',
        hidden = false
    },
    ['Gathering'] = {
        name = 'Gathering',
        icon = 'fas fa-hand-holding',
        description = 'Skills related to resource gathering',
        hidden = false
    },
    ['Crime'] = {
        name = 'Crime',
        icon = 'fa-solid fa-people-robbery',
        description = 'Illegal skills and reputation',
        hidden = true
    }
}

local Skills = {}
Skills['Strength'] = {name = 'Strength', maxLevel = 5, icon = 'fas fa-dumbbell', category = 'Personal Skills', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Wimp'},
                                [2] = { name = 'Thug'},
                                [3] = { name = 'Heavy Hitter'},
                                [4] = { name = 'Enforcer'},
                                [5] = { name = 'Street Tough'},
                            }
                        }
Skills['Dexterity'] = {name = 'Dexterity', maxLevel = 10, icon = 'fas fa-hands', category = 'Personal Skills', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Clumsy'},
                                [2] = { name = 'Nimble'},
                                [3] = { name = 'Quick Handed'},
                                [4] = { name = 'Graceful'},
                                [5] = { name = 'Agile'},
                                [6] = { name = 'Deft Hands'},
                                [7] = { name = 'Dexterous'},
                                [8] = { name = 'Stealthy'},
                                [9] = { name = 'Sleight of Hand'},
                                [10] = { name = 'Evasive'},
                            }
}
Skills['Charisma'] = {name = 'Charisma', maxLevel = 5, icon = 'fas fa-people-arrows', category = 'Personal Skills', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Charming Rookie'},
                                [2] = { name = 'Smooth Talker'},
                                [3] = { name = 'Influential'},
                                [4] = { name = 'Silver-Tongued'},
                                [5] = { name = 'Master Manipulator'},
                            }
                        }
Skills['Stress Resistance'] = {name = 'Stress Resistance', maxLevel = 20, icon = 'fas fa-brain', category = 'Personal Skills', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Fragile'},
                                [2] = { name = 'Nervous'},
                                [3] = { name = 'Timid'},
                                [4] = { name = 'Anxious'},
                                [5] = { name = 'Apprehensive'},
                                [6] = { name = 'Wary'},
                                [7] = { name = 'Steady'},
                                [8] = { name = 'Composed'},
                                [9] = { name = 'Resolute'},
                                [10] = { name = 'Unperturbed'},
                                [11] = { name = 'Cool Headed'},
                                [12] = { name = 'Confident'},
                                [13] = { name = 'Fearless'},
                                [14] = { name = 'Indomitable'},
                                [15] = { name = 'Iron Willed'},
                                [16] = { name = 'Unshakable'},
                                [17] = { name = 'Imperturbable'},
                                [18] = { name = 'Titanium'},
                                [19] = { name = 'Legendary Resolver'},
                                [20] = { name = 'Zen Master'},
                            }
                        }
Skills['Driving'] = {name = 'Driving', maxLevel = 20, icon = 'fas fa-car', category = 'Personal Skills', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Crash Test Dummy'},
                                [2] = { name = 'Student Driver'},
                                [3] = { name = 'Speed Bump Slayer'},
                                [4] = { name = 'Sidewalk Surfer'},
                                [5] = { name = 'Lane Changer'},
                                [6] = { name = 'Freeway Floater'},
                                [7] = { name = 'Drift King (or Queen)'},
                                [8] = { name = 'Road Rage Renegade'},
                                [9] = { name = 'Pavement Picasso'},
                                [10] = { name = 'Highway Hooligan'},
                                [11] = { name = 'Professional Wheelman'},
                                [12] = { name = 'Experienced Driver'},
                                [13] = { name = 'Veteran Driver'},
                                [14] = { name = 'Master Driver'},
                                [15] = { name = 'Gearshift Guru'},
                                [16] = { name = 'Lane Changer'},
                                [17] = { name = 'Winding Road Wizard'},
                                [18] = { name = 'Turbo Tyrant'},
                                [19] = { name = 'Asphalt Assassin'},
                                [20] = { name = 'Driving Legend'},
                            }
                        }
Skills['Weapon Handling'] = {name = 'Weapon Handling', maxLevel = 20, icon = 'fas fa-gun', category = 'Personal Skills', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Spray and Pray'},
                                [2] = { name = 'Wobble Warrior'},
                                [3] = { name = 'Shaky Shot'},
                                [4] = { name = 'Recoil Rookie'},
                                [5] = { name = 'Steady Shooter'},
                                [6] = { name = 'Precision Practitioner'},
                                [7] = { name = 'City Slicker'},
                                [8] = { name = 'Smooth Shooter'},
                                [9] = { name = 'Kickback Crusher'},
                                [10] = { name = 'Balanced Blaster'},
                                [11] = { name = 'Recoil Whisperer'},
                                [12] = { name = 'Sharpshooter'},
                                [13] = { name = 'Steady Hand'},
                                [14] = { name = 'Kickback King (or Queen)'},
                                [15] = { name = 'Glock Guru'},
                                [16] = { name = 'Recoil Wrangler'},
                                [17] = { name = 'Recoil Virtuoso'},
                                [18] = { name = 'Recoil Terminator'},
                                [19] = { name = 'Master of the Trigger'},
                                [20] = { name = 'Legend of the Trigger'},
                            }
                        }
Skills['Hacking'] = {name = 'Hacking', maxLevel = 20, icon = {'fab','hackerrank'}, category = 'Personal Skills', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Binary Beginner'},
                                [2] = { name = 'Packet Prowler'},
                                [3] = { name = 'Phishing Phanatic'},
                                [4] = { name = 'Packet Peeker'},
                                [5] = { name = 'Code Clown'},
                                [6] = { name = 'Script Kiddo'},
                                [7] = { name = 'Digital Dabbler'},
                                [8] = { name = 'Firewall Fumbler'},
                                [9] = { name = 'Proxy Plevelster'},
                                [10] = { name = 'Malware Monkey'},
                                [11] = { name = 'Encryption Enthusiast'},
                                [12] = { name = 'Data Digger'},
                                [13] = { name = 'Cyber Sleuth'},
                                [14] = { name = 'Virus King (or Queen)'},
                                [15] = { name = 'Trojan Tactician'},
                                [16] = { name = 'Phreaker'},
                                [17] = { name = 'Cyber Mastermind'},
                                [18] = { name = 'Cyber Kingpin'},
                                [19] = { name = 'Master of the Mainframe'},
                                [20] = { name = 'Legend of the Mainframe'},
                            }
                        }
--? Begin Crafting
Skills['Fabrication'] = {name = 'Fabrication', maxLevel = 20, icon = 'fas fa-industry', category = 'Crafting', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Sparky Starter'},
                                [2] = { name = 'Component Tinkerer'},
                                [3] = { name = 'Wiring Apprentice'},
                                [4] = { name = 'Junction Jockey'},
                                [5] = { name = 'Capacitor Clown'},
                                [6] = { name = 'Resistor Wrangler'},
                                [7] = { name = 'Resistor Riddler'},
                                [8] = { name = 'Transistor Tinkerer'},
                                [9] = { name = 'Electrician'},
                                [10] = { name = 'Circuit Wizard'},
                                [11] = { name = 'Voltage Vandal'},
                                [12] = { name = 'Component Commander'},
                                [13] = { name = 'Ohm Orator'},
                                [14] = { name = 'Tech King (or Queen)'},
                                [15] = { name = 'Trojan Tactician'},
                                [16] = { name = 'Resistor Renegade'},
                                [17] = { name = 'Capacitor Connoisseur'},
                                [18] = { name = 'Tech Tamer'},
                                [19] = { name = 'Master of Electromagnetism'},
                                [20] = { name = 'Legend of Electromagnetism'},
                            }
                        }
Skills['Electrical Engineering'] = {name = 'Electrical Engineering', maxLevel = 20, icon = 'fas fa-bolt', category = 'Crafting', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Sparky Starter'},
                                [2] = { name = 'Component Tinkerer'},
                                [3] = { name = 'Wiring Apprentice'},
                                [4] = { name = 'Junction Jockey'},
                                [5] = { name = 'Capacitor Clown'},
                                [6] = { name = 'Resistor Wrangler'},
                                [7] = { name = 'Resistor Riddler'},
                                [8] = { name = 'Transistor Tinkerer'},
                                [9] = { name = 'Electrician'},
                                [10] = { name = 'Circuit Wizard'},
                                [11] = { name = 'Voltage Vandal'},
                                [12] = { name = 'Component Commander'},
                                [13] = { name = 'Ohm Orator'},
                                [14] = { name = 'Tech King (or Queen)'},
                                [15] = { name = 'Trojan Tactician'},
                                [16] = { name = 'Resistor Renegade'},
                                [17] = { name = 'Capacitor Connoisseur'},
                                [18] = { name = 'Tech Tamer'},
                                [19] = { name = 'Master of Electromagnetism'},
                                [20] = { name = 'Legend of Electromagnetism'},
                            }
                        }
Skills['Carpentry'] = {name = 'Carpentry', maxLevel = 20, icon = 'fas fa-tree', category = 'Crafting', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Splinter Specialist'},
                                [2] = { name = 'Board Basher'},
                                [3] = { name = 'Nail Nudger'},
                                [4] = { name = 'Plank Pummeler'},
                                [5] = { name = 'Sawdust Slinger'},
                                [6] = { name = 'Timber Tinkerer'},
                                [7] = { name = 'Cabinet Clown'},
                                [8] = { name = 'Lumber Laggard'},
                                [9] = { name = 'Joinery Jester'},
                                [10] = { name = 'Crafty Carpenter'},
                                [11] = { name = 'Wood Whittler'},
                                [12] = { name = 'Sawing Savant'},
                                [13] = { name = 'Master of Miter'},
                                [14] = { name = 'Hammer King (or Queen)'},
                                [15] = { name = 'Artisan Artificer'},
                                [16] = { name = 'Carpentry Captain'},
                                [17] = { name = 'Timber Tycoon'},
                                [18] = { name = 'Wood Whisperer'},
                                [19] = { name = 'Carpentry Champion'},
                                [20] = { name = 'Legendary Craftsman'},
                            }
                        }
--? Begin Gathering
Skills['Farming'] = {name = 'Farming', maxLevel = 20, icon = 'fas fa-wheat-awn', category = 'Gathering', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Green Thumb'},
                                [2] = { name = 'Farm Hand'},
                                [3] = { name = 'Gardener'},
                                [4] = { name = 'Crop Tender'},
                                [5] = { name = 'Harvester'},
                                [6] = { name = 'Field Worker'},
                                [7] = { name = 'Crop Cultivator'},
                                [8] = { name = 'Orchard Keeper'},
                                [9] = { name = 'Livestock Handler'},
                                [10] = { name = 'Agronomist'},
                                [11] = { name = 'Farm Manager'},
                                [12] = { name = 'Rancher'},
                                [13] = { name = 'Horticulturist'},
                                [14] = { name = 'Crop King (or Queen)'},
                                [15] = { name = 'Crop Specialist'},
                                [16] = { name = 'Agribusiness Expert'},
                                [17] = { name = 'Master Farmer'},
                                [18] = { name = 'Farming Fanatic'},
                                [19] = { name = 'Master of the Farmland'},
                                [20] = { name = 'Legend of the Farmland'},
                            }
                        }
Skills['Fishing'] = {name = 'Fishing', maxLevel = 20, icon = 'fas fa-fish', category = 'Gathering', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Novice Angler'},
                                [2] = { name = 'Beginner Fisher'},
                                [3] = { name = 'Recreational Reeler'},
                                [4] = { name = 'Casting Cadet'},
                                [5] = { name = 'Pond Paddler'},
                                [6] = { name = 'Lake Lurker'},
                                [7] = { name = 'River Rookie'},
                                [8] = { name = 'Stream Stalker'},
                                [9] = { name = 'Tackle Technician'},
                                [10] = { name = 'Bait Boss'},
                                [11] = { name = 'Hook Hero'},
                                [12] = { name = 'Lure Legend'},
                                [13] = { name = 'Master of the Minnows'},
                                [14] = { name = 'Fish King (or Queen)'},
                                [15] = { name = 'Trophy Tracker'},
                                [16] = { name = 'Bass Boss'},
                                [17] = { name = 'Water Whisperer'},
                                [18] = { name = 'Trophy Tracker'},
                                [19] = { name = 'Angling Ace'},
                                [20] = { name = 'Legendary Fisherman'},
                            }
                        }
Skills['Mining'] = {name = 'Mining', maxLevel = 20, icon = 'fas fa-helmet-safety', category = 'Gathering', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Greenhorn'},
                                [2] = { name = 'Digging Novice'},
                                [3] = { name = 'Ore Seeker'},
                                [4] = { name = 'Coal Collector'},
                                [5] = { name = 'Rock Rumbler'},
                                [6] = { name = 'Copper Chiseler'},
                                [7] = { name = 'Tin Tapper'},
                                [8] = { name = 'Iron Digger'},
                                [9] = { name = 'Silver Spelunker'},
                                [10] = { name = 'Gold Getter'},
                                [11] = { name = 'Gem Gatherer'},
                                [12] = { name = 'Mineral Miner'},
                                [13] = { name = 'Rare Resource Raker'},
                                [14] = { name = 'Diamond King (or Queen)'},
                                [15] = { name = 'Platinum Prospector'},
                                [16] = { name = 'Mithril Miner'},
                                [17] = { name = 'Titanium Tunneler'},
                                [18] = { name = 'Obsidian Overlord'},
                                [19] = { name = 'Master Miner'},
                                [20] = { name = 'Legendary Miner'},
                            }
                        }
Skills['Prospecting'] = {name = 'Prospecting', maxLevel = 20, icon = 'fas fa-coins', category = 'Gathering', hidden = false,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Fuckin Nerd'},
                                [2] = { name = 'Digging Novice'},
                                [3] = { name = 'Ore Seeker'},
                                [4] = { name = 'Coal Collector'},
                                [5] = { name = 'Rock Rumbler'},
                                [6] = { name = 'Copper Chiseler'},
                                [7] = { name = 'Tin Tapper'},
                                [8] = { name = 'Iron Digger'},
                                [9] = { name = 'Silver Spelunker'},
                                [10] = { name = 'Gold Getter'},
                                [11] = { name = 'Gem Gatherer'},
                                [12] = { name = 'Mineral Miner'},
                                [13] = { name = 'Rare Resource Raker'},
                                [14] = { name = 'Diamond King (or Queen)'},
                                [15] = { name = 'Platinum Prospector'},
                                [16] = { name = 'Mithril Miner'},
                                [17] = { name = 'Titanium Tunneler'},
                                [18] = { name = 'Obsidian Overlord'},
                                [19] = { name = 'Master Miner'},
                                [20] = { name = 'Legendary Prospector'},
                            }
                        }
--? Begin Crime
--? Begin Crime
Skills['Weed'] = {name = 'Weed', maxLevel = 20, icon = 'fas fa-cannabis', category = 'Crime', hidden = true,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Seed Sower'},
                                [2] = { name = 'Sprout Grower'},
                                [3] = { name = 'Green Thumb'},
                                [4] = { name = 'Bud Tender'},
                                [5] = { name = 'Herbalist'},
                                [6] = { name = 'Crop Cultivator'},
                                [7] = { name = 'Cannabis Farmer'},
                                [8] = { name = 'Weed Harvester'},
                                [9] = { name = 'Corner Dealer'},
                                [10] = { name = 'Local Distributor'},
                                [11] = { name = 'Neighborhood Supplier'},
                                [12] = { name = 'Block Merchant'},
                                [13] = { name = 'Area Pusher'},
                                [14] = { name = 'Trap King (or Queen)'},
                                [15] = { name = 'Regional Distributor'},
                                [16] = { name = 'City Dealer'},
                                [17] = { name = 'State Dealer'},
                                [18] = { name = 'Global Distributor'},
                                [19] = { name = 'Weed Mogul'},
                                [20] = { name = 'Legendary Weed Trafficker'},
                            }
                        }
Skills['Coke'] = {name = 'Coke', maxLevel = 20, icon = 'fas fa-box-tissue', category = 'Crime', hidden = true,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Street Pusher'},
                                [2] = { name = 'Corner Dealer'},
                                [3] = { name = 'Local Supplier'},
                                [4] = { name = 'Neighborhood Pusher'},
                                [5] = { name = 'Block Distributor'},
                                [6] = { name = 'Area Smuggler'},
                                [7] = { name = 'District Trader'},
                                [8] = { name = 'Urban Trafficker'},
                                [9] = { name = 'Suburban Smuggler'},
                                [10] = { name = 'Regional Distributor'},
                                [11] = { name = 'State Supplier'},
                                [12] = { name = 'National Trafficker'},
                                [13] = { name = 'International Smuggler'},
                                [14] = { name = 'Empire Builder'},
                                [15] = { name = 'Syndicate Leader'},
                                [16] = { name = 'Professional Sniffer'},
                                [17] = { name = 'Drug Lord'},
                                [18] = { name = 'Global Kingpin'},
                                [19] = { name = 'Cocaine Mogul'},
                                [20] = { name = 'Legendary Cocaine Trafficker'},
                            }
                        }
Skills['Meth'] = {name = 'Meth', maxLevel = 20, icon = 'fas fa-flask', category = 'Crime', hidden = true,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Chemistry Student'},
                                [2] = { name = 'Street Pusher'},
                                [3] = { name = 'Corner Dealer'},
                                [4] = { name = 'Local Supplier'},
                                [5] = { name = 'Neighborhood Pusher'},
                                [6] = { name = 'Block Distributor'},
                                [7] = { name = 'Area Smuggler'},
                                [8] = { name = 'District Trader'},
                                [9] = { name = 'Urban Trafficker'},
                                [10] = { name = 'Suburban Smuggler'},
                                [11] = { name = 'Regional Distributor'},
                                [12] = { name = 'State Supplier'},
                                [13] = { name = 'National Trafficker'},
                                [14] = { name = 'International Smuggler'},
                                [16] = {name = 'Drug Lord'},
                                [17] = {name = 'Heisenberg'},
                                [18] = {name = 'Global Kingpin'},
                                [19] = {name = 'Meth Mogul'},
                                [20] = {name = 'Legendary Meth Trafficker'},
                            }
                        }
Skills['Chop Shop'] = {name = 'Chop Shop', maxLevel = 5, icon = 'fa-solid fa-wrench', category = 'Crime', hidden = true,
                            levels = {
                                -- Indexes are our level value
                                [1] = { name = 'Tire Thief'},
                                [2] = { name = 'Radio Ripper'},
                                [3] = { name = 'Part Puller'},
                                [4] = { name = 'Hood Hacker'},
                                [5] = { name = 'Wire Stripper'},
                                [6] = { name = 'Engine Extractor'},
                                [7] = { name = 'Frame Flayer'},
                                [8] = { name = 'Bumper Bandit'},
                                [9] = { name = 'Transmission Tracker'},
                                [10] = { name = 'Chassis Chopper'},
                                [11] = { name = 'Body Breaker'},
                                [12] = { name = 'Shop Supervisor'},
                                [13] = { name = 'Garage Gangster'},
                                [14] = { name = 'Scrapyard Surgeon'},
                                [15] = { name = 'Chop Shop Chief'},
                                [16] = { name = 'Auto Assassin'},
                                [17] = { name = 'Vehicle Vulture'},
                                [18] = { name = 'Chop Shop Kingpin'},
                                [19] = { name = 'Master Dismantler'},
                                [20] = { name = 'Legendary Car Killer'},

                            }
                        }
Skills['Recycling'] = {name = 'Recycling', maxLevel = 20, icon = 'fas fa-recycle', category = 'Gathering', hidden = false,
                        levels = {
                            -- Indexes are our level value
                            [1] = { name = 'Trash Sorter'},
                            [2] = { name = 'Can Crusher'},
                            [3] = { name = 'Bottle Breaker'},
                            [4] = { name = 'Scrap Seeker'},
                            [5] = { name = 'Metal Muncher'},
                            [6] = { name = 'Component Collector'},
                            [7] = { name = 'Part Picker'},
                            [8] = { name = 'Material Miner'},
                            [9] = { name = 'Resource Ripper'},
                            [10] = { name = 'Salvage Specialist'},
                            [11] = { name = 'Reclaim Ranger'},
                            [12] = { name = 'Breakdown Boss'},
                            [13] = { name = 'Scrapyard Surgeon'},
                            [14] = { name = 'Waste Wizard'},
                            [15] = { name = 'Junk Juggernaut'},
                            [16] = { name = 'Recycling Royalty'},
                            [17] = { name = 'Salvage Sovereign'},
                            [18] = { name = 'Scrap Lord'},
                            [19] = { name = 'Master Recycler'},
                            [20] = { name = 'Legendary Salvager'},
                        }
                    }
Skills['Boosting'] = {name = 'Boosting', maxLevel = 20, icon = 'fas fa-car-side', category = 'Crime', hidden = true,
                        levels = {
                            -- Indexes are our level value
                            [1] = { name = 'Joyrider'},
                            [2] = { name = 'Key Fumbler'},
                            [3] = { name = 'Hotwire Hustler'},
                            [4] = { name = 'Ignition Infiltrator'},
                            [5] = { name = 'Street Snatcher'},
                            [6] = { name = 'Ride Ripper'},
                            [7] = { name = 'Getaway Grabber'},
                            [8] = { name = 'Boost Runner'},
                            [9] = { name = 'Contract Cruiser'},
                            [10] = { name = 'Tracker Dodger'},
                            [11] = { name = 'Heat Evader'},
                            [12] = { name = 'Pursuit Phantom'},
                            [13] = { name = 'Boost Boss'},
                            [14] = { name = 'Grand Theft Artist'},
                            [15] = { name = 'Vehicle Virtuoso'},
                            [16] = { name = 'Boost Kingpin'},
                            [17] = { name = 'Auto Overlord'},
                            [18] = { name = 'Phantom Driver'},
                            [19] = { name = 'Master Booster'},
                            [20] = { name = 'Legendary Car Thief'},
                        }
                    }

return {
    Settings = Settings,
    Categories = Categories,
    Skills = Skills
}