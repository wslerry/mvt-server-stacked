-- Data processing based on openmaptiles.org schema
-- https://openmaptiles.org/schema/
-- Copyright (c) 2016, KlokanTech.com & OpenMapTiles contributors.
-- Used under CC-BY 4.0
--------
-- This lua script to process Borneo Island OSM dataset
--------
-- Alter these lines to control which languages are written for place/streetnames
preferred_language = nil
preferred_language_attribute = "name"
default_language_attribute = "name_int"
additional_languages = { "en", "ms", "id" }

--------
-- Enter/exit Tilemaker
function init_function() end

function exit_function() end

-- Implement Sets in tables
function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

-- Meters per pixel if tile is 256x256
ZRES5, ZRES6, ZRES7, ZRES8 = 4891.97, 2445.98, 1222.99, 611.5
ZRES9, ZRES10, ZRES11, ZRES12 = 305.7, 152.9, 76.4, 38.2
ZRES13, ZRES14 = 19.1, 9.55

BUILDING_FLOOR_HEIGHT = 4.8

-- Tags
aerodromeValues = Set { "international", "public", "regional", "military", "private" }
pavedValues = Set { "paved", "asphalt", "cobblestone", "concrete", "concrete:lanes", "concrete:plates", "metal", "paving_stones", "sett", "unhewn_cobblestone", "wood" }
unpavedValues = Set { "unpaved", "compacted", "dirt", "earth", "fine_gravel", "grass", "grass_paver", "gravel", "gravel_turf", "ground", "ice", "mud", "pebblestone", "salt", "sand", "snow", "woodchips" }

majorRoadValues = Set { "motorway", "trunk", "primary" }
mainRoadValues = Set { "secondary", "motorway_link", "trunk_link", "primary_link", "secondary_link" }
midRoadValues = Set { "tertiary", "tertiary_link" }
minorRoadValues = Set { "unclassified", "residential", "road", "living_street" }
trackValues = Set { "track" }
pathValues = Set { "footway", "cycleway", "bridleway", "path", "steps", "pedestrian" }
linkValues = Set { "motorway_link", "trunk_link", "primary_link", "secondary_link", "tertiary_link" }
constructionValues = Set { "primary", "secondary", "tertiary", "motorway", "service", "trunk", "track" }
aerowayBuildings = Set { "terminal", "gate", "tower" }

landuseKeys = Set { "school", "university", "kindergarten", "college", "library", "hospital",
    "railway", "cemetery", "military", "residential", "commercial", "industrial",
    "retail", "stadium", "pitch", "playground", "theme_park", "bus_station", "zoo" }

landcoverKeys = {
    wood = "wood",
    forest = "wood",
    wetland = "wetland",
    beach = "sand",
    sand = "sand",
    farmland = "farmland",
    farm = "farmland",
    orchard = "farmland",
    vineyard = "farmland",
    plant_nursery = "farmland",
    glacier = "ice",
    ice_shelf = "ice",
    grassland = "grass",
    grass = "grass",
    meadow = "grass",
    allotments = "grass",
    park = "grass",
    village_green = "grass",
    recreation_ground = "grass",
    garden = "grass",
    golf_course = "grass"
}

-- POI Tags
poiTags = {
    aerialway = Set { "station" },
    amenity = Set { "arts_centre", "bank", "bar", "bbq", "bicycle_parking", "bicycle_rental", "biergarten", "bus_station", "cafe", "cinema", "clinic", "college", "community_centre", "courthouse", "dentist", "doctors", "embassy", "fast_food", "ferry_terminal", "fire_station", "food_court", "fuel", "grave_yard", "hospital", "ice_cream", "kindergarten", "library", "marketplace", "motorcycle_parking", "nightclub", "nursing_home", "parking", "pharmacy", "place_of_worship", "police", "post_box", "post_office", "prison", "pub", "public_building", "recycling", "restaurant", "school", "shelter", "swimming_pool", "taxi", "telephone", "theatre", "toilets", "townhall", "university", "veterinary", "waste_basket" },
    barrier = Set { "bollard", "border_control", "cycle_barrier", "gate", "lift_gate", "sally_port", "stile", "toll_booth" },
    building = Set { "dormitory" },
    highway = Set { "bus_stop" },
    historic = Set { "monument", "castle", "ruins" },
    landuse = Set { "basin", "brownfield", "cemetery", "reservoir", "winter_sports" },
    leisure = Set { "dog_park", "escape_game", "garden", "golf_course", "ice_rink", "hackerspace", "marina", "miniature_golf", "park", "pitch", "playground", "sports_centre", "stadium", "swimming_area", "swimming_pool", "water_park" },
    railway = Set { "halt", "station", "subway_entrance", "train_station_entrance", "tram_stop" },
    shop = Set { "accessories", "alcohol", "antiques", "art", "bag", "bakery", "beauty", "bed", "beverages", "bicycle", "books", "boutique", "butcher", "camera", "car", "car_repair", "carpet", "charity", "chemist", "chocolate", "clothes", "coffee", "computer", "confectionery", "convenience", "copyshop", "cosmetics", "deli", "delicatessen", "department_store", "doityourself", "dry_cleaning", "electronics", "erotic", "fabric", "florist", "frozen_food", "furniture", "garden_centre", "general", "gift", "greengrocer", "hairdresser", "hardware", "hearing_aids", "hifi", "ice_cream", "interior_decoration", "jewelry", "kiosk", "lamps", "laundry", "mall", "massage", "mobile_phone", "motorcycle", "music", "musical_instrument", "newsagent", "optician", "outdoor", "perfume", "perfumery", "pet", "photo", "second_hand", "shoes", "sports", "stationery", "supermarket", "tailor", "tattoo", "ticket", "tobacco", "toys", "travel_agency", "video", "video_games", "watches", "weapons", "wholesale", "wine" },
    sport = Set { "american_football", "archery", "athletics", "australian_football", "badminton", "baseball", "basketball", "beachvolleyball", "billiards", "bmx", "boules", "bowls", "boxing", "canadian_football", "canoe", "chess", "climbing", "climbing_adventure", "cricket", "cricket_nets", "croquet", "curling", "cycling", "disc_golf", "diving", "dog_racing", "equestrian", "fatsal", "field_hockey", "free_flying", "gaelic_games", "golf", "gymnastics", "handball", "hockey", "horse_racing", "horseshoes", "ice_hockey", "ice_stock", "judo", "karting", "korfball", "long_jump", "model_aerodrome", "motocross", "motor", "multi", "netball", "orienteering", "paddle_tennis", "paintball", "paragliding", "pelota", "racquet", "rc_car", "rowing", "rugby", "rugby_league", "rugby_union", "running", "sailing", "scuba_diving", "shooting", "shooting_range", "skateboard", "skating", "skiing", "soccer", "surfing", "swimming", "table_soccer", "table_tennis", "team_handball", "tennis", "toboggan", "volleyball", "water_ski", "yoga" },
    tourism = Set { "alpine_hut", "aquarium", "artwork", "attraction", "bed_and_breakfast", "camp_site", "caravan_site", "chalet", "gallery", "guest_house", "hostel", "hotel", "information", "motel", "museum", "picnic_site", "theme_park", "viewpoint", "zoo" },
    waterway = Set { "dock" }
}

poiClasses = {
    townhall = "town_hall",
    public_building = "town_hall",
    courthouse = "town_hall",
    community_centre = "town_hall",
    golf = "golf",
    golf_course = "golf",
    miniature_golf = "golf",
    fast_food = "fast_food",
    food_court = "fast_food",
    park = "park",
    bbq = "park",
    bus_stop = "bus",
    bus_station = "bus",
    subway_entrance = "entrance",
    train_station_entrance = "entrance",
    camp_site = "campsite",
    caravan_site = "campsite",
    laundry = "laundry",
    dry_cleaning = "laundry",
    supermarket = "grocery",
    deli = "grocery",
    delicatessen = "grocery",
    department_store = "grocery",
    greengrocer = "grocery",
    marketplace = "grocery",
    books = "library",
    library = "library",
    university = "college",
    college = "college",
    hotel = "lodging",
    motel = "lodging",
    bed_and_breakfast = "lodging",
    guest_house = "lodging",
    hostel = "lodging",
    chalet = "lodging",
    alpine_hut = "lodging",
    dormitory = "lodging",
    chocolate = "ice_cream",
    confectionery = "ice_cream",
    post_box = "post",
    post_office = "post",
    cafe = "cafe",
    school = "school",
    kindergarten = "school",
    alcohol = "alcohol_shop",
    beverages = "alcohol_shop",
    wine = "alcohol_shop",
    bar = "bar",
    nightclub = "bar",
    marina = "harbor",
    dock = "harbor",
    car = "car",
    car_repair = "car",
    taxi = "car",
    hospital = "hospital",
    nursing_home = "hospital",
    clinic = "hospital",
    grave_yard = "cemetery",
    cemetery = "cemetery",
    attraction = "attraction",
    viewpoint = "attraction",
    biergarten = "beer",
    pub = "beer",
    music = "music",
    musical_instrument = "music",
    american_football = "stadium",
    stadium = "stadium",
    soccer = "stadium",
    art = "art_gallery",
    artwork = "art_gallery",
    gallery = "art_gallery",
    arts_centre = "art_gallery",
    bag = "clothing_store",
    clothes = "clothing_store",
    swimming_area = "swimming",
    swimming = "swimming",
    castle = "castle",
    ruins = "castle"
}

poiSubClasses = { information = "information", place_of_worship = "religion", pitch = "sport" }
poiClassRanks = { hospital = 1, railway = 2, bus = 3, attraction = 4, harbor = 5, college = 6, school = 7, stadium = 8, zoo = 9, town_hall = 10, campsite = 11, cemetery = 12, park = 13, library = 14, police = 15, post = 16, golf = 17, shop = 18, grocery = 19, fast_food = 20, clothing_store = 21, bar = 22 }

waterClasses = Set { "river", "riverbank", "stream", "canal", "drain", "ditch", "dock" }
waterwayClasses = Set { "stream", "river", "canal", "drain", "ditch" }

-- Scan relations
function relation_scan_function()
    local rel_type = Find("type")
    if rel_type ~= "boundary" and rel_type ~= "multipolygon" then return end

    local boundary = Find("boundary")
    local landuse = Find("landuse")
    local leisure = Find("leisure")

    if boundary == "administrative" or boundary == "national_park" or boundary == "protected_area" or boundary == "forest" or
        landuse == "forest" or leisure == "nature_reserve" then
        Accept()
    end
end

-- Write to transportation
function write_to_transportation_layer(minzoom, highway_class)
    Layer("transportation", false)
    MinZoom(minzoom)
    SetZOrder()
    Attribute("class", highway_class)
    SetBrunnelAttributes()
    if ramp then AttributeNumeric("ramp", 1) end
    if highway == "service" and service ~= "" then Attribute("service", service) end
    local oneway = Find("oneway")
    if oneway == "yes" or oneway == "1" then AttributeNumeric("oneway", 1) end
    local surface = Find("surface")
    if pavedValues[surface] then
        Attribute("surface", "paved", 12)
    elseif unpavedValues[surface] then
        Attribute("surface", "unpaved", 12)
    end
    if Holds("access") then Attribute("access", Find("access"), 9) end
    if Holds("bicycle") then Attribute("bicycle", Find("bicycle"), 9) end
    if Holds("foot") then Attribute("foot", Find("foot"), 9) end
    if Holds("horse") then Attribute("horse", Find("horse"), 9) end
    AttributeBoolean("toll", Find("toll") == "yes", 9)
    AttributeNumeric("layer", tonumber(Find("layer")) or 0, 9)
    AttributeBoolean("expressway", Find("expressway") == "yes", 7)
    Attribute("mtb_scale", Find("mtb:scale"), 10)
end

-- Process way
function way_function()
    local highway = Find("highway")
    local waterway = Find("waterway")
    local building = Find("building")
    local natural = Find("natural")
    local landuse = Find("landuse")
    local leisure = Find("leisure")
    local boundary = Find("boundary")
    local man_made = Find("man_made")
    local aeroway = Find("aeroway")
    local railway = Find("railway")
    local service = Find("service")
    local isClosed = IsClosed()
    local housenumber = Find("addr:housenumber")

    -- Relation state
    local admin_level = 11
    local is_admin = false
    local is_wood = false
    local is_park = false
    local park_class = ""
    local is_nature_reserve = false
    local rel_name = ""

    while true do
        local rel = NextRelation()
        if not rel then break end
        local rtype = FindInRelation("type")
        if rtype == "boundary" or rtype == "multipolygon" then
            local rb = FindInRelation("boundary")
            local rl = FindInRelation("landuse")
            local rle = FindInRelation("leisure")
            if rb == "administrative" then
                is_admin = true
                admin_level = math.min(admin_level, tonumber(FindInRelation("admin_level")) or 11)
            end
            if rl == "forest" or rb == "forest" then is_wood = true end
            if rb == "national_park" or rb == "protected_area" then
                is_park = true; park_class = rb
            end
            if rle == "nature_reserve" then is_nature_reserve = true end
            if rel_name == "" then rel_name = FindInRelation("name") end
        end
    end

    if boundary == "administrative" then
        is_admin = true
        admin_level = math.min(admin_level, tonumber(Find("admin_level")) or 11)
    end

    -- Admin boundaries
    if is_admin and Find("maritime") ~= "yes" then
        local mz = admin_level >= 8 and 12 or admin_level >= 5 and 8 or admin_level >= 3 and 4 or 0
        if admin_level == 7 then mz = 10 end
        Layer("boundary", false)
        AttributeNumeric("admin_level", admin_level)
        MinZoom(mz)
        AttributeNumeric("disputed", Find("disputed") == "yes" and 1 or 0)
    end

    -- Skip invalid
    if Find("disused") == "yes" or highway == "proposed" then return end
    if boundary ~= "" and Find("protection_title") == "National Forest" and Find("operator") == "United States Forest Service" then return end
    if aerowayBuildings[aeroway] then
        building = "yes"; aeroway = ""
    end
    if landuse == "field" then landuse = "farmland" end
    if landuse == "meadow" and Find("meadow") == "agricultural" then landuse = "farmland" end

    -- Forest (landcover)
    if is_wood or boundary == "forest" then
        Layer("landcover", true)
        SetMinZoomByArea()
        Attribute("class", "wood")
        Attribute("subclass", "forest")
    end

    -- Roads
    if highway ~= "" then
        local h = highway
        local minzoom = 99
        if majorRoadValues[highway] then
            minzoom = 4
        elseif highway == "trunk" then
            minzoom = 5
        elseif highway == "primary" then
            minzoom = 7
        elseif mainRoadValues[highway] then
            minzoom = 9
        elseif midRoadValues[highway] then
            minzoom = 11
        elseif minorRoadValues[highway] then
            h = "minor"; minzoom = 12
        elseif trackValues[highway] then
            h = "track"; minzoom = 14
        elseif pathValues[highway] then
            h = "path"; minzoom = 14
        elseif h == "service" then
            minzoom = 12
        end

        local ramp = linkValues[highway]
        if ramp then
            local parts = split(highway, "_")
            highway = parts[1]; h = highway; minzoom = 11
        end

        local construction = Find("construction")
        if highway == "construction" and constructionValues[construction] then
            h = construction .. "_construction"
            minzoom = construction ~= "service" and construction ~= "track" and 11 or 12
        end

        if minzoom <= 14 then
            write_to_transportation_layer(minzoom, h)
            local name_mz = math.max(minzoom, 8)
            local name_layer = (highway == "motorway" or highway == "trunk") and "transportation_name" or
                (h == "minor" or h == "track" or h == "path" or h == "service") and "transportation_name_detail" or
                "transportation_name_mid"
            Layer(name_layer, false); MinZoom(name_mz); SetNameAttributes()
            Attribute("class", h)
            if h ~= highway then Attribute("subclass", highway) end
            local ref = Find("ref")
            if ref ~= "" then
                Attribute("ref", ref); AttributeNumeric("ref_length", #ref)
            end
        end
    end

    -- Railways
    if railway ~= "" then
        Layer("transportation", false); Attribute("class", railway); SetZOrder(); SetBrunnelAttributes()
        MinZoom(service ~= "" and 12 or 9)
        Layer("transportation_name", false); SetNameAttributes(); MinZoom(14); Attribute("class", "rail")
    end

    -- Pier, Ferry, Aeroway
    if man_made == "pier" then
        Layer("transportation", isClosed); SetZOrder(); Attribute("class", "pier"); SetMinZoomByArea()
    end
    if Find("route") == "ferry" then
        Layer("transportation", false); Attribute("class", "ferry"); SetZOrder(); MinZoom(9); SetBrunnelAttributes()
        Layer("transportation_name", false); SetNameAttributes(); MinZoom(12); Attribute("class", "ferry")
    end
    if aeroway ~= "" then
        Layer("aeroway", isClosed); Attribute("class", aeroway); Attribute("ref", Find("ref"))
    end
    if aeroway == "aerodrome" then
        LayerAsCentroid("aerodrome_label"); SetNameAttributes(); Attribute("iata", Find("iata")); SetEleAttributes(); Attribute(
            "icao", Find("icao"))
        local c = aerodromeValues[Find("aerodrome")] and Find("aerodrome") or "other"
        Attribute("class", c)
    end

    -- Waterways
    if waterwayClasses[waterway] and not isClosed then
        local layer = waterway == "river" and Holds("name") and "waterway" or "waterway_detail"
        Layer(layer, false); Attribute("class", waterway); SetNameAttributes(); SetBrunnelAttributes()
        AttributeNumeric("intermittent", Find("intermittent") == "yes" and 1 or 0)
    elseif waterway == "boatyard" then
        Layer("landuse", true); Attribute("class", "industrial"); MinZoom(12)
    elseif waterway == "dam" then
        Layer("building", true)
    elseif waterway == "fuel" then
        Layer("landuse", true); Attribute("class", "industrial"); MinZoom(14)
    end

    if waterwayClasses[waterway] and not isClosed then
        local layer = waterway == "river" and Holds("name") and "water_name" or "water_name_detail"
        Layer(layer, false); Attribute("class", waterway); SetNameAttributes()
        if layer == "water_name_detail" then MinZoom(14) end
    end

    -- Building
    if building ~= "" then
        Layer("building", true); SetBuildingHeightAttributes(); SetMinZoomByArea()
    end
    if housenumber ~= "" then
        LayerAsCentroid("housenumber"); Attribute("housenumber", housenumber)
    end

    -- Water
    if natural == "water" or leisure == "swimming_pool" or landuse == "reservoir" or landuse == "basin" or waterClasses[waterway] then
        if Find("covered") == "yes" or not isClosed then return end
        local class = waterway ~= "" and "river" or "lake"
        if class == "lake" and Find("wikidata") == "Q192770" then return end
        Layer("water", true); SetMinZoomByArea(); Attribute("class", class)
        if Find("intermittent") == "yes" then Attribute("intermittent", 1) end
        if Holds("name") and natural == "water" and Find("water") ~= "basin" and Find("water") ~= "wastewater" then
            LayerAsCentroid("water_name_detail"); SetNameAttributes(); SetMinZoomByArea(); Attribute("class", class)
        end
        return
    end

    -- Landcover / Landuse
    local l = landuse ~= "" and landuse or natural ~= "" and natural or leisure
    if landcoverKeys[l] then
        Layer("landcover", true); SetMinZoomByArea(); Attribute("class", landcoverKeys[l])
        Attribute("subclass", l == "wetland" and Find("wetland") or l)
    else
        l = l == "" and Find("amenity") or l == "" and Find("tourism") or l
        if landuseKeys[l] then
            Layer("landuse", true); Attribute("class", l)
            MinZoom(l == "residential" and (Area() < ZRES8 ^ 2 and 8 or nil) or 11)
            if l == "residential" and Area() >= ZRES8 ^ 2 then SetMinZoomByArea() end
        end
    end

    -- PARKS: national_park, protected_area, nature_reserve
    local name_to_use = Find("name") ~= "" and Find("name") or rel_name
    if is_park or boundary == "national_park" or boundary == "protected_area" then
        Layer("park", true)
        Attribute("class", is_park and park_class or boundary)
        if name_to_use ~= "" then SetNameAttributes(name_to_use) end
    elseif is_nature_reserve or leisure == "nature_reserve" then
        Layer("park", true)
        Attribute("class", "nature_reserve")
        if name_to_use ~= "" then SetNameAttributes(name_to_use) end
    end

    -- POI
    local rank, class, subclass = GetPOIRank()
    if rank then
        WritePOI(class, subclass, rank); return
    end

    -- Catch-all name
    if (building ~= "" or is_wood or is_park or is_nature_reserve) and name_to_use ~= "" then
        LayerAsCentroid("poi_detail")
        SetNameAttributes(name_to_use)
        AttributeNumeric("rank", 25)
    end
end

-- Common functions
function WritePOI(class, subclass, rank)
    local layer = rank > 4 and "poi_detail" or "poi"
    LayerAsCentroid(layer); SetNameAttributes(); AttributeNumeric("rank", rank)
    Attribute("class", class); Attribute("subclass", subclass)
    AttributeNumeric("layer", tonumber(Find("layer")) or 0)
    AttributeBoolean("indoor", Find("indoor") == "yes")
    local level = tonumber(Find("level"))
    if level then AttributeNumeric("level", level) end
end

function SetNameAttributes(name_override)
    local name = name_override or Find("name")
    local main = name
    if preferred_language and Holds("name:" .. preferred_language) then
        local pl = Find("name:" .. preferred_language)
        Attribute(preferred_language_attribute, pl)
        if pl ~= name and default_language_attribute then Attribute(default_language_attribute, name) end
        main = pl
    else
        Attribute(preferred_language_attribute, name)
    end
    for _, lang in ipairs(additional_languages) do
        local ln = Find("name:" .. lang)
        if ln == "" then ln = name end
        if ln ~= main then Attribute("name:" .. lang, ln) end
    end
end

function SetEleAttributes()
    local ele = Find("ele")
    if ele ~= "" then
        local m = math.floor(tonumber(ele) or 0)
        AttributeNumeric("ele", m); AttributeNumeric("ele_ft", math.floor(m * 3.2808399))
    end
end

function SetBrunnelAttributes()
    local b = Find("bridge")
    local t = Find("tunnel")
    local f = Find("ford")
    if b == "yes" then
        Attribute("brunnel", "bridge")
    elseif t == "yes" then
        Attribute("brunnel", "tunnel")
    elseif f == "yes" then
        Attribute("brunnel", "ford")
    end
end

function SetMinZoomByArea()
    local a = Area()
    MinZoom(a > ZRES5 ^ 2 and 6 or a > ZRES6 ^ 2 and 7 or a > ZRES7 ^ 2 and 8 or a > ZRES8 ^ 2 and 9 or
        a > ZRES9 ^ 2 and 10 or a > ZRES10 ^ 2 and 11 or a > ZRES11 ^ 2 and 12 or a > ZRES12 ^ 2 and 13 or 14)
end

function GetPOIRank()
    for k, list in pairs(poiTags) do
        if list[Find(k)] then
            local v = Find(k)
            local class = poiClasses[v] or k
            local rank = poiClassRanks[class] or 25
            local sub = poiSubClasses[v]
            if sub then
                class = v; v = Find(sub)
            end
            return rank, class, v
        end
    end
    local shop = Find("shop")
    if shop ~= "" then return poiClassRanks.shop or 18, "shop", shop end
    return nil, nil, nil
end

function SetBuildingHeightAttributes()
    local h = tonumber(Find("height"))
    local mh = tonumber(Find("min_height"))
    local l = tonumber(Find("building:levels"))
    local ml = tonumber(Find("building:min_level"))
    local rh = h or (l and l * BUILDING_FLOOR_HEIGHT) or BUILDING_FLOOR_HEIGHT
    local rmh = mh or (ml and ml * BUILDING_FLOOR_HEIGHT) or 0
    if rh < rmh then rh = rh + rmh end
    AttributeNumeric("render_height", rh)
    AttributeNumeric("render_min_height", rmh)
end

function SetZOrder()
    local h = Find("highway")
    local l = tonumber(Find("layer")) or 0
    local b = Find("bridge")
    local t = Find("tunnel")
    local z = 0
    if b ~= "" and b ~= "no" then
        z = z + 10
    elseif t ~= "" and t ~= "no" then
        z = z - 10
    end
    if l > 7 then l = 7 elseif l < -7 then l = -7 end
    z = z + l * 10
    local hc = h == "motorway" and 9 or h == "trunk" and 8 or h == "primary" and 6 or h == "secondary" and 5 or
        h == "tertiary" and 4 or 3
    z = z + hc
    ZOrder(z)
end

function split(str, sep)
    local t, i = {}, 1
    for s in string.gmatch(str, "([^" .. (sep or "%s") .. "]+)") do
        t[i] = s; i = i + 1
    end
    return t
end
