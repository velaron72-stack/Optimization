--[[
    RATMAN4080 v4080
    Client-Side FPS & Graphics Optimizer
    Target: Roblox injector / executor context
    NOT for Roblox Studio plugins.
    
    Usage: paste into injector, execute.
    All changes are client-local and reversible via Restore All.
]]

-- ============================================================
-- SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")
local Stats            = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local CollectionService= game:GetService("CollectionService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local GuiService       = game:GetService("GuiService")

local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    Version = "4080",

    -- Core
    Enabled = true,
    DebugMode = false,
    Logging = true,
    SafeMode = true,
    AggressiveMode = false,
    HeavyScriptCompat = false,

    -- Scan
    ScanInterval = 2.0,           -- seconds between incremental scans
    ScanBudgetPerFrame = 50,      -- max instances processed per scan tick
    OptimizationBudgetPerFrame = 30,

    -- Target
    TargetFPS = 60,
    MinFPSThreshold = 30,
    RecoveryThreshold = 55,
    RecoveryDelay = 5.0,
    AdaptiveSensitivity = 0.7,
    AdaptiveCooldown = 8.0,
    HysteresisBand = 5.0,

    -- Textures
    TexturesEnabled = false,
    TextureMode = "VeryLow",       -- "Off" | "VeryLow" | "Low" | "UltraPotato"
    TextureNeutralColor = Color3.fromRGB(128, 128, 128),
    TextureWhitelist = {},
    TextureBlacklist = {},
    ProcessCharacterTextures = true,
    ProcessWorldTextures = true,

    -- Accessories
    AccessoriesEnabled = false,
    AccessoryGrey = true,
    AccessoryCheapMaterial = true,
    AccessoryHideVisuals = false,
    AccessoryExcludeLocalCharacter = true,
    AccessoryWhitelist = {},

    -- Mesh
    MeshEnabled = false,
    MeshRenderFidelity = "Performance",
    MeshDistanceThreshold = 150,
    MeshAggressive = false,

    -- Lighting
    LightingEnabled = false,
    LightingProfile = "Low",       -- "Low" | "Medium" | "Aggressive"
    DisableShadows = true,
    DisableBloom = true,
    DisableColorCorrection = true,
    DisableDepthOfField = true,
    DisableSunRays = true,
    DisableBlur = true,
    DisableAtmosphere = true,
    MaxLightDistance = 80,
    DisablePointLights = true,
    DisableSpotLights = true,

    -- Particles
    ParticlesEnabled = false,
    MaxParticleRate = 30,
    ParticleDistanceCull = 100,
    DisableTrails = false,
    DisableBeams = false,
    DisableSparkles = true,
    DisableFire = false,
    DisableSmoke = false,
    ParticleAdaptive = true,

    -- Transparency
    TransparencyEnabled = false,
    TransparencyAggressive = false,
    TransparencyThreshold = 0.6,
    GlassToPlastic = false,

    -- Terrain
    TerrainEnabled = false,
    TerrainWaterEnabled = true,
    WaterWaveSize = 0,
    WaterWaveSpeed = 0,
    WaterReflectance = 0,
    WaterTransparency = 1,
    TerrainDecoReduce = false,

    -- Characters
    CharacterEnabled = false,
    CharacterLocalSimplify = false,
    CharacterOthersSimplify = true,
    CharacterLayeredClothing = false,
    CharacterLowGraphics = false,

    -- Culling
    CullingEnabled = false,
    CullingDistance = 500,
    CullingNearThreshold = 50,
    CullingUpdateInterval = 0.5,
    CullingExcludeLocalCharacter = true,
    CullingExcludeUI = true,

    -- Cache
    CacheCleanInterval = 30,
    CacheMaxSize = 5000,

    -- Overlay
    OverlayEnabled = true,
    OverlaySize = 14,
    OverlayPosition = UDim2.new(0, 10, 0, 10),
    OverlayShowFPS = true,
    OverlayShowFrameTime = true,
    OverlayShowTarget = true,
    OverlayShowPreset = true,
    OverlayShowState = true,

    -- UI
    UIMinimized = false,
    UIScale = 1.0,
    UICompactMode = false,
}

-- ============================================================
-- PRESETS
-- ============================================================
local Presets = {
    Default = {
        TexturesEnabled = false, AccessoriesEnabled = false,
        MeshEnabled = false, LightingEnabled = false,
        ParticlesEnabled = false, TransparencyEnabled = false,
        TerrainEnabled = false, CharacterEnabled = false,
        CullingEnabled = false,
    },
    Balanced = {
        TexturesEnabled = false, AccessoriesEnabled = false,
        MeshEnabled = false, LightingEnabled = true,
        ParticlesEnabled = true, TransparencyEnabled = false,
        TerrainEnabled = false, CharacterEnabled = false,
        CullingEnabled = true, CullingDistance = 800,
        MaxParticleRate = 50, DisableShadows = true,
        DisableBloom = true, DisableSunRays = true,
    },
    Performance = {
        TexturesEnabled = false, AccessoriesEnabled = true,
        MeshEnabled = true, LightingEnabled = true,
        ParticlesEnabled = true, TransparencyEnabled = false,
        TerrainEnabled = false, CharacterEnabled = false,
        CullingEnabled = true, CullingDistance = 600,
        MaxParticleRate = 30, DisableShadows = true,
        DisableBloom = true, DisableSunRays = true,
        DisableDepthOfField = true, DisableAtmosphere = true,
        MeshRenderFidelity = "Performance",
    },
    Low = {
        TexturesEnabled = true, TextureMode = "Low",
        AccessoriesEnabled = true, AccessoryGrey = true,
        MeshEnabled = true, MeshRenderFidelity = "Performance",
        LightingEnabled = true, DisableShadows = true,
        DisableBloom = true, DisableSunRays = true,
        DisableDepthOfField = true, DisableAtmosphere = true,
        ParticlesEnabled = true, MaxParticleRate = 20,
        TransparencyEnabled = false, TerrainEnabled = true,
        CharacterEnabled = false, CullingEnabled = true,
        CullingDistance = 500,
    },
    VeryLow = {
        TexturesEnabled = true, TextureMode = "VeryLow",
        AccessoriesEnabled = true, AccessoryGrey = true,
        AccessoryHideVisuals = true,
        MeshEnabled = true, MeshRenderFidelity = "Performance",
        MeshAggressive = true,
        LightingEnabled = true, DisableShadows = true,
        DisableBloom = true, DisableSunRays = true,
        DisableDepthOfField = true, DisableAtmosphere = true,
        DisablePointLights = true, DisableSpotLights = true,
        ParticlesEnabled = true, MaxParticleRate = 10,
        DisableTrails = true, DisableSparkles = true,
        TransparencyEnabled = true,
        TerrainEnabled = true, WaterWaveSize = 0,
        CharacterEnabled = true, CharacterOthersSimplify = true,
        CullingEnabled = true, CullingDistance = 400,
    },
    Potato = {
        TexturesEnabled = true, TextureMode = "VeryLow",
        AccessoriesEnabled = true, AccessoryGrey = true,
        AccessoryHideVisuals = true, AccessoryCheapMaterial = true,
        MeshEnabled = true, MeshRenderFidelity = "Performance",
        MeshAggressive = true, MeshDistanceThreshold = 80,
        LightingEnabled = true, DisableShadows = true,
        DisableBloom = true, DisableSunRays = true,
        DisableDepthOfField = true, DisableAtmosphere = true,
        DisablePointLights = true, DisableSpotLights = true,
        ParticlesEnabled = true, MaxParticleRate = 5,
        DisableTrails = true, DisableBeams = true,
        DisableSparkles = true, DisableFire = true,
        TransparencyEnabled = true, TransparencyAggressive = true,
        TerrainEnabled = true, TerrainWaterEnabled = false,
        CharacterEnabled = true, CharacterLowGraphics = true,
        CharacterOthersSimplify = true,
        CullingEnabled = true, CullingDistance = 300,
    },
    UltraPotato = {
        TexturesEnabled = true, TextureMode = "Off",
        AccessoriesEnabled = true, AccessoryGrey = true,
        AccessoryHideVisuals = true, AccessoryCheapMaterial = true,
        MeshEnabled = true, MeshRenderFidelity = "Performance",
        MeshAggressive = true, MeshDistanceThreshold = 50,
        LightingEnabled = true, DisableShadows = true,
        DisableBloom = true, DisableSunRays = true,
        DisableDepthOfField = true, DisableAtmosphere = true,
        DisablePointLights = true, DisableSpotLights = true,
        ParticlesEnabled = true, MaxParticleRate = 1,
        DisableTrails = true, DisableBeams = true,
        DisableSparkles = true, DisableFire = true,
        DisableSmoke = true,
        TransparencyEnabled = true, TransparencyAggressive = true,
        TerrainEnabled = true, TerrainWaterEnabled = false,
        CharacterEnabled = true, CharacterLowGraphics = true,
        CharacterOthersSimplify = true, CharacterLayeredClothing = true,
        CullingEnabled = true, CullingDistance = 200,
    },
    Custom = {},
}

-- ============================================================
-- LOGGER
-- ============================================================
local Logger = {}
Logger._buffer = {}
Logger._lastFlush = 0
Logger._rateLimit = 0.5

function Logger.log(level, ...)
    if not Config.Logging then return end
    local now = tick()
    if now - Logger._lastFlush < Logger._rateLimit then
        table.insert(Logger._buffer, {level = level, msg = table.concat({...}, " ")})
        return
    end
    Logger._lastFlush = now
    local msg = string.format("[RATMAN4080][%s] %s", level, table.concat({...}, " "))
    if Config.DebugMode then
        warn(msg)
    end
    -- flush buffer
    for _, entry in ipairs(Logger._buffer) do
        if Config.DebugMode then
            warn(string.format("[RATMAN4080][%s] %s", entry.level, entry.msg))
        end
    end
    Logger._buffer = {}
end

-- ============================================================
-- UTIL — safe operations
-- ============================================================
local Util = {}

function Util.safeSet(instance, property, value)
    if not instance or not instance.Parent then return false end
    local ok, err = pcall(function()
        instance[property] = value
    end)
    if not ok then
        Logger.log("WARN", "safeSet fail:", property, tostring(err))
    end
    return ok
end

function Util.safeGet(instance, property)
    if not instance then return nil end
    local ok, val = pcall(function()
        return instance[property]
    end)
    if not ok then return nil end
    return val
end

function Util.isAlive(instance)
    return instance ~= nil and instance.Parent ~= nil
end

function Util.clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

-- ============================================================
-- CACHE MANAGER
-- ============================================================
local CacheManager = {}
CacheManager._cache = {}        -- [instance] = { property = originalValue }
CacheManager._processed = {}    -- [instance] = true
CacheManager._categories = {}   -- [category] = { instances }
CacheManager._hits = 0
CacheManager._misses = 0
CacheManager._lastClean = 0

function CacheManager:saveOriginal(instance, property)
    if not instance then return end
    if not self._cache[instance] then
        self._cache[instance] = {}
    end
    if self._cache[instance][property] == nil then
        local val = Util.safeGet(instance, property)
        self._cache[instance][property] = { value = val, exists = val ~= nil }
    end
end

function CacheManager:getOriginal(instance, property)
    if not instance or not self._cache[instance] then return nil end
    local entry = self._cache[instance][property]
    if entry then
        self._hits = self._hits + 1
        return entry.value
    end
    self._misses = self._misses + 1
    return nil
end

function CacheManager:markProcessed(instance)
    self._processed[instance] = true
end

function CacheManager:isProcessed(instance)
    return self._processed[instance] == true
end

function CacheManager:addToCategory(category, instance)
    if not self._categories[category] then
        self._categories[category] = {}
    end
    table.insert(self._categories[category], instance)
end

function CacheManager:getCategory(category)
    return self._categories[category] or {}
end

function CacheManager:getStats()
    local count = 0
    for _ in pairs(self._cache) do count = count + 1 end
    return {
        cachedInstances = count,
        hits = self._hits,
        misses = self._misses,
    }
end

function CacheManager:clean()
    local now = tick()
    if now - self._lastClean < Config.CacheCleanInterval then return end
    self._lastClean = now

    -- remove dead instances from cache
    local dead = {}
    for inst, _ in pairs(self._cache) do
        if not Util.isAlive(inst) then
            table.insert(dead, inst)
        end
    end
    for _, inst in ipairs(dead) do
        self._cache[inst] = nil
        self._processed[inst] = nil
    end

    -- trim processed table if too large
    local pCount = 0
    for _ in pairs(self._processed) do pCount = pCount + 1 end
    if pCount > Config.CacheMaxSize then
        local toRemove = {}
        for inst, _ in pairs(self._processed) do
            if not Util.isAlive(inst) then
                table.insert(toRemove, inst)
            end
        end
        for _, inst in ipairs(toRemove) do
            self._processed[inst] = nil
        end
    end
end

function CacheManager:clearAll()
    self._cache = {}
    self._processed = {}
    self._categories = {}
end

-- ============================================================
-- RESTORE MANAGER
-- ============================================================
local RestoreManager = {}
RestoreManager._pendingRestores = {}

function RestoreManager:restoreAll()
    local restored = 0
    for instance, props in pairs(CacheManager._cache) do
        if Util.isAlive(instance) then
            for property, entry in pairs(props) do
                if entry.exists then
                    Util.safeSet(instance, property, entry.value)
                    restored = restored + 1
                end
            end
        end
    end
    CacheManager:clearAll()
    Logger.log("INFO", "Restored", restored, "properties")
    return restored
end

-- ============================================================
-- SMART SCANNER
-- ============================================================
local SmartScanner = {}
SmartScanner._counts = {}
SmartScanner._estimatedCost = 0
SmartScanner._lastScan = 0
SmartScanner._scanQueue = {}
SmartScanner._scanIndex = 1

local SCAN_CATEGORIES = {
    BasePart = true, MeshPart = true, Texture = true, Decal = true,
    SurfaceAppearance = true, ParticleEmitter = true, Trail = true,
    Beam = true, Light = true, Accessory = true, PointLight = true,
    SpotLight = true, SurfaceLight = true, Fire = true, Smoke = true,
    Sparkles = true, Atmosphere = true, BloomEffect = true,
    ColorCorrectionEffect = true, DepthOfFieldEffect = true,
    SunRaysEffect = true, BlurEffect = true,
}

function SmartScanner:reset()
    self._counts = {}
    self._estimatedCost = 0
    self._scanQueue = {}
    self._scanIndex = 1
    self._lastScan = tick()
end

function SmartScanner:scan()
    local now = tick()
    if now - self._lastScan < Config.ScanInterval then return end
    self._lastScan = now

    -- Rebuild queue only if empty
    if #self._scanQueue == 0 then
        local ok, descendants = pcall(function()
            return Workspace:GetDescendants()
        end)
        if ok then
            self._scanQueue = descendants
            self._scanIndex = 1
        end
    end

    local processed = 0
    while self._scanIndex <= #self._scanQueue and processed < Config.ScanBudgetPerFrame do
        local inst = self._scanQueue[self._scanIndex]
        self._scanIndex = self._scanIndex + 1
        processed = processed + 1

        if Util.isAlive(inst) then
            local className = inst.ClassName
            if SCAN_CATEGORIES[className] then
                self._counts[className] = (self._counts[className] or 0) + 1
            end
        end
    end

    -- When done, compute estimated cost
    if self._scanIndex > #self._scanQueue then
        self._computeEstimatedCost()
    end
end

function SmartScanner:_computeEstimatedCost()
    -- Heuristic only. NOT real GPU cost.
    local cost = 0
    cost = cost + (self._counts.MeshPart or 0) * 3
    cost = cost + (self._counts.BasePart or 0) * 1
    cost = cost + (self._counts.Texture or 0) * 2
    cost = cost + (self._counts.Decal or 0) * 1
    cost = cost + (self._counts.SurfaceAppearance or 0) * 4
    cost = cost + (self._counts.ParticleEmitter or 0) * 5
    cost = cost + (self._counts.Trail or 0) * 3
    cost = cost + (self._counts.Beam or 0) * 3
    cost = cost + (self._counts.Light or 0) * 4
    cost = cost + (self._counts.Accessory or 0) * 2
    self._estimatedCost = cost
end

function SmartScanner:getCount(category)
    return self._counts[category] or 0
end

function SmartScanner:getEstimatedCost()
    return self._estimatedCost
end

function SmartScanner:getHeaviestCategories()
    local sorted = {}
    for cat, count in pairs(self._counts) do
        table.insert(sorted, {category = cat, count = count, cost = count * (SCAN_CATEGORIES[cat] or 1)})
    end
    table.sort(sorted, function(a, b) return a.cost > b.cost end)
    return sorted
end

-- ============================================================
-- OPTIMIZERS
-- ============================================================

-- ---------- TEXTURE OPTIMIZER ----------
local TextureOptimizer = {}

function TextureOptimizer:process(instance)
    if not Config.TexturesEnabled then return end
    if not Util.isAlive(instance) then return end

    local className = instance.ClassName
    if className ~= "Texture" and className ~= "Decal" then return end

    -- check whitelist/blacklist by name
    if table.find(Config.TextureWhitelist, instance.Name) then return end
    if table.find(Config.TextureBlacklist, instance.Name) then
        Util.safeSet(instance, "Transparency", 1)
        CacheManager:saveOriginal(instance, "Transparency")
        return
    end

    -- check character
    local isCharacter = instance:IsDescendantOf(LocalPlayer.Character or game)
    if isCharacter and not Config.ProcessCharacterTextures then return end

    CacheManager:saveOriginal(instance, "Texture")
    CacheManager:saveOriginal(instance, "Transparency")
    CacheManager:markProcessed(instance)

    local mode = Config.TextureMode
    if mode == "Off" then
        Util.safeSet(instance, "Transparency", 1)
    elseif mode == "UltraPotato" then
        Util.safeSet(instance, "Texture", "")
        Util.safeSet(instance, "Transparency", 1)
    elseif mode == "VeryLow" then
        Util.safeSet(instance, "Transparency", 0.95)
    elseif mode == "Low" then
        Util.safeSet(instance, "Transparency", 0.8)
    end
end

-- ---------- ACCESSORY OPTIMIZER ----------
local AccessoryOptimizer = {}

function AccessoryOptimizer:process(character)
    if not Config.AccessoriesEnabled then return end
    if not character then return end

    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") then
            if Config.AccessoryExcludeLocalCharacter and character == LocalPlayer.Character then
                continue
            end

            if table.find(Config.AccessoryWhitelist, child.Name) then continue end

            CacheManager:saveOriginal(child, "Handle")
            CacheManager:markProcessed(child)

            local handle = child:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                CacheManager:saveOriginal(handle, "Transparency")
                CacheManager:saveOriginal(handle, "Material")
                CacheManager:saveOriginal(handle, "Color")
                CacheManager:saveOriginal(handle, "CastShadow")

                if Config.AccessoryHideVisuals then
                    Util.safeSet(handle, "Transparency", 1)
                end
                if Config.AccessoryGrey then
                    Util.safeSet(handle, "Color", Color3.fromRGB(128, 128, 128))
                end
                if Config.AccessoryCheapMaterial then
                    Util.safeSet(handle, "Material", Enum.Material.Plastic)
                end
                Util.safeSet(handle, "CastShadow", false)
            end
        end
    end
end

-- ---------- MESH OPTIMIZER ----------
local MeshOptimizer = {}

function MeshOptimizer:process(instance)
    if not Config.MeshEnabled then return end
    if not Util.isAlive(instance) then return end
    if not instance:IsA("MeshPart") then return end

    CacheManager:saveOriginal(instance, "RenderFidelity")
    CacheManager:markProcessed(instance)

    local fidelity = Config.MeshRenderFidelity
    if fidelity == "Performance" then
        Util.safeSet(instance, "RenderFidelity", Enum.RenderFidelity.Performance)
    elseif fidelity == "Automatic" then
        Util.safeSet(instance, "RenderFidelity", Enum.RenderFidelity.Automatic)
    end

    if Config.MeshAggressive then
        CacheManager:saveOriginal(instance, "TextureID")
        Util.safeSet(instance, "TextureID", "")
    end
end

-- ---------- LIGHTING OPTIMIZER ----------
local LightingOptimizer = {}
LightingOptimizer._postEffects = {}

function LightingOptimizer:apply()
    if not Config.LightingEnabled then return end

    -- GlobalShadows
    CacheManager:saveOriginal(Lighting, "GlobalShadows")
    if Config.DisableShadows then
        Util.safeSet(Lighting, "GlobalShadows", false)
    end

    -- EnvironmentDiffuseScale
    CacheManager:saveOriginal(Lighting, "EnvironmentDiffuseScale")
    if Config.LightingProfile == "Aggressive" then
        Util.safeSet(Lighting, "EnvironmentDiffuseScale", 0)
    end

    -- Post-processing effects
    local effects = Lighting:GetChildren()
    for _, effect in ipairs(effects) do
        local className = effect.ClassName
        local shouldDisable = false

        if className == "BloomEffect" and Config.DisableBloom then shouldDisable = true
        elseif className == "ColorCorrectionEffect" and Config.DisableColorCorrection then shouldDisable = true
        elseif className == "DepthOfFieldEffect" and Config.DisableDepthOfField then shouldDisable = true
        elseif className == "SunRaysEffect" and Config.DisableSunRays then shouldDisable = true
        elseif className == "BlurEffect" and Config.DisableBlur then shouldDisable = true
        elseif className == "Atmosphere" and Config.DisableAtmosphere then shouldDisable = true
        end

        if shouldDisable then
            CacheManager:saveOriginal(effect, "Enabled")
            Util.safeSet(effect, "Enabled", false)
            CacheManager:markProcessed(effect)
        end
    end

    -- Ambient / Brightness
    CacheManager:saveOriginal(Lighting, "Ambient")
    CacheManager:saveOriginal(Lighting, "OutdoorAmbient")
    CacheManager:saveOriginal(Lighting, "Brightness")
    if Config.LightingProfile == "Aggressive" then
        Util.safeSet(Lighting, "Ambient", Color3.fromRGB(100, 100, 100))
        Util.safeSet(Lighting, "OutdoorAmbient", Color3.fromRGB(100, 100, 100))
        Util.safeSet(Lighting, "Brightness", 1)
    end

    -- Fog
    CacheManager:saveOriginal(Lighting, "FogEnd")
    CacheManager:saveOriginal(Lighting, "FogStart")
    if Config.LightingProfile == "Aggressive" then
        Util.safeSet(Lighting, "FogEnd", 500)
        Util.safeSet(Lighting, "FogStart", 0)
    end
end

function LightingOptimizer:processLight(light)
    if not Config.LightingEnabled then return end
    if not Util.isAlive(light) then return end
    if not (light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight")) then return end

    if light:IsA("PointLight") and not Config.DisablePointLights then return end
    if light:IsA("SpotLight") and not Config.DisableSpotLights then return end

    CacheManager:saveOriginal(light, "Enabled")
    CacheManager:saveOriginal(light, "Shadows")
    CacheManager:markProcessed(light)

    -- distance culling
    local parent = light.Parent
    if parent and parent:IsA("BasePart") then
        local distance = (parent.Position - Camera.CFrame.Position).Magnitude
        if distance > Config.MaxLightDistance then
            Util.safeSet(light, "Enabled", false)
        else
            Util.safeSet(light, "Enabled", true)
        end
    end

    if Config.DisableShadows then
        Util.safeSet(light, "Shadows", false)
    end
end

-- ---------- PARTICLE OPTIMIZER ----------
local ParticleOptimizer = {}

function ParticleOptimizer:process(instance)
    if not Config.ParticlesEnabled then return end
    if not Util.isAlive(instance) then return end

    local className = instance.ClassName

    if className == "ParticleEmitter" then
        CacheManager:saveOriginal(instance, "Rate")
        CacheManager:saveOriginal(instance, "Enabled")
        CacheManager:markProcessed(instance)

        local origRate = CacheManager:getOriginal(instance, "Rate")
        if origRate then
            local newRate = math.min(origRate, Config.MaxParticleRate)
            Util.safeSet(instance, "Rate", newRate)
        end

    elseif className == "Trail" and Config.DisableTrails then
        CacheManager:saveOriginal(instance, "Enabled")
        CacheManager:markProcessed(instance)
        Util.safeSet(instance, "Enabled", false)

    elseif className == "Beam" and Config.DisableBeams then
        CacheManager:saveOriginal(instance, "Enabled")
        CacheManager:markProcessed(instance)
        Util.safeSet(instance, "Enabled", false)

    elseif className == "Sparkles" and Config.DisableSparkles then
        CacheManager:saveOriginal(instance, "Enabled")
        CacheManager:markProcessed(instance)
        Util.safeSet(instance, "Enabled", false)

    elseif className == "Fire" and Config.DisableFire then
        CacheManager:saveOriginal(instance, "Enabled")
        CacheManager:markProcessed(instance)
        Util.safeSet(instance, "Enabled", false)

    elseif className == "Smoke" and Config.DisableSmoke then
        CacheManager:saveOriginal(instance, "Enabled")
        CacheManager:markProcessed(instance)
        Util.safeSet(instance, "Enabled", false)
    end
end

-- ---------- TRANSPARENCY OPTIMIZER ----------
local TransparencyOptimizer = {}

function TransparencyOptimizer:process(instance)
    if not Config.TransparencyEnabled then return end
    if not Util.isAlive(instance) then return end
    if not instance:IsA("BasePart") then return end

    local transparency = Util.safeGet(instance, "Transparency")
    if transparency and transparency > 0 and transparency < 1 then
        CacheManager:saveOriginal(instance, "Transparency")
        CacheManager:markProcessed(instance)

        if Config.TransparencyAggressive then
            Util.safeSet(instance, "Transparency", 1)
        elseif transparency > Config.TransparencyThreshold then
            Util.safeSet(instance, "Transparency", 1)
        end
    end

    -- Glass material
    if Config.GlassToPlastic then
        local material = Util.safeGet(instance, "Material")
        if material == Enum.Material.Glass then
            CacheManager:saveOriginal(instance, "Material")
            CacheManager:markProcessed(instance)
            Util.safeSet(instance, "Material", Enum.Material.Plastic)
        end
    end
end

-- ---------- TERRAIN OPTIMIZER ----------
local TerrainOptimizer = {}

function TerrainOptimizer:apply()
    if not Config.TerrainEnabled then return end

    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if not terrain then return end

    CacheManager:saveOriginal(terrain, "WaterWaveSize")
    CacheManager:saveOriginal(terrain, "WaterWaveSpeed")
    CacheManager:saveOriginal(terrain, "WaterReflectance")
    CacheManager:saveOriginal(terrain, "WaterTransparency")

    if Config.TerrainWaterEnabled then
        Util.safeSet(terrain, "WaterWaveSize", Config.WaterWaveSize)
        Util.safeSet(terrain, "WaterWaveSpeed", Config.WaterWaveSpeed)
        Util.safeSet(terrain, "WaterReflectance", Config.WaterReflectance)
        Util.safeSet(terrain, "WaterTransparency", Config.WaterTransparency)
    end

    CacheManager:markProcessed(terrain)
end

-- ---------- CHARACTER OPTIMIZER ----------
local CharacterOptimizer = {}

function CharacterOptimizer:process(character)
    if not Config.CharacterEnabled then return end
    if not character then return end

    local isLocal = character == LocalPlayer.Character

    if isLocal and not Config.CharacterLocalSimplify then
        -- still process accessories if enabled
        AccessoryOptimizer:process(character)
        return
    end

    if not isLocal and not Config.CharacterOthersSimplify then return end

    for _, child in ipairs(character:GetDescendants()) do
        if child:IsA("Accessory") then
            if Config.CharacterLayeredClothing then
                local handle = child:FindFirstChild("Handle")
                if handle then
                    CacheManager:saveOriginal(handle, "Transparency")
                    Util.safeSet(handle, "Transparency", 1)
                end
            end
        end

        if child:IsA("BasePart") then
            CacheManager:saveOriginal(child, "CastShadow")
            if Config.CharacterLowGraphics then
                Util.safeSet(child, "CastShadow", false)
            end
        end

        if child:IsA("MeshPart") and Config.CharacterLowGraphics then
            CacheManager:saveOriginal(child, "RenderFidelity")
            Util.safeSet(child, "RenderFidelity", Enum.RenderFidelity.Performance)
        end
    end

    AccessoryOptimizer:process(character)
end

-- ============================================================
-- CULLING MANAGER
-- ============================================================
local CullingManager = {}
CullingManager._culledInstances = {}
CullingManager._lastCullUpdate = 0
CullingManager._cullQueue = {}
CullingManager._cullIndex = 1

function CullingManager:update()
    if not Config.CullingEnabled then return end
    local now = tick()
    if now - self._lastCullUpdate < Config.CullingUpdateInterval then return end
    self._lastCullUpdate = now

    local cameraPos = Camera.CFrame.Position

    -- rebuild queue if needed
    if #self._cullQueue == 0 then
        local ok, descendants = pcall(function()
            return Workspace:GetDescendants()
        end)
        if ok then
            for _, inst in ipairs(descendants) do
                if inst:IsA("BasePart") and not inst:IsDescendantOf(LocalPlayer.Character or game) then
                    table.insert(self._cullQueue, inst)
                end
            end
        end
    end

    local processed = 0
    while self._cullIndex <= #self._cullQueue and processed < Config.ScanBudgetPerFrame do
        local inst = self._cullQueue[self._cullIndex]
        self._cullIndex = self._cullIndex + 1
        processed = processed + 1

        if Util.isAlive(inst) then
            local distance = (inst.Position - cameraPos).Magnitude
            local shouldHide = distance > Config.CullingDistance

            if shouldHide then
                if not self._culledInstances[inst] then
                    CacheManager:saveOriginal(inst, "Transparency")
                    CacheManager:saveOriginal(inst, "CastShadow")
                    Util.safeSet(inst, "Transparency", 1)
                    Util.safeSet(inst, "CastShadow", false)
                    self._culledInstances[inst] = true
                end
            else
                if self._culledInstances[inst] then
                    local origTrans = CacheManager:getOriginal(inst, "Transparency")
                    local origShadow = CacheManager:getOriginal(inst, "CastShadow")
                    Util.safeSet(inst, "Transparency", origTrans or 0)
                    Util.safeSet(inst, "CastShadow", origShadow ~= false)
                    self._culledInstances[inst] = nil
                end
            end
        end
    end

    if self._cullIndex > #self._cullQueue then
        self._cullQueue = {}
        self._cullIndex = 1
    end
end

-- ============================================================
-- PERFORMANCE MONITOR
-- ============================================================
local PerformanceMonitor = {}
PerformanceMonitor.fps = 0
PerformanceMonitor.frameTime = 0
PerformanceMonitor.avgFPS = 0
PerformanceMonitor._fpsHistory = {}
PerformanceMonitor._historySize = 60
PerformanceMonitor._lastUpdate = 0
PerformanceMonitor._updateInterval = 0.5
PerformanceMonitor.bottleneck = "unknown"

function PerformanceMonitor:update()
    local now = tick()
    self.frameTime = RunService.RenderStepped:Wait() -- approximate
    if self.frameTime > 0 then
        self.fps = 1 / self.frameTime
    end

    if now - self._lastUpdate < self._updateInterval then return end
    self._lastUpdate = now

    table.insert(self._fpsHistory, self.fps)
    if #self._fpsHistory > self._historySize then
        table.remove(self._fpsHistory, 1)
    end

    local sum = 0
    for _, f in ipairs(self._fpsHistory) do sum = sum + f end
    self.avgFPS = sum / #self._fpsHistory

    self:_detectBottleneck()
end

function PerformanceMonitor:_detectBottleneck()
    local cpuTime = Stats.RenderCPUFrameTime
    local gpuTime = Stats.RenderGPUFrameTime

    if cpuTime and gpuTime then
        if cpuTime > gpuTime * 1.5 then
            self.bottleneck = "CPU/script suspected"
        elseif gpuTime > cpuTime * 1.5 then
            self.bottleneck = "GPU/render suspected"
        else
            self.bottleneck = "Mixed"
        end
    else
        self.bottleneck = "unknown"
    end
end

function PerformanceMonitor:getFPS()
    return self.fps
end

function PerformanceMonitor:getAvgFPS()
    return self.avgFPS
end

function PerformanceMonitor:getFrameTime()
    return self.frameTime
end

function PerformanceMonitor:getMemoryMB()
    local ok, mem = pcall(function()
        return Stats:GetTotalMemoryUsageMb()
    end)
    return ok and mem or 0
end

function PerformanceMonitor:get1PercentLow()
    if #self._fpsHistory < 10 then return self.avgFPS end
    local sorted = {}
    for _, f in ipairs(self._fpsHistory) do table.insert(sorted, f) end
    table.sort(sorted)
    local idx = math.max(1, math.floor(#sorted * 0.01))
    return sorted[idx]
end

-- ============================================================
-- ADAPTIVE OPTIMIZER
-- ============================================================
local AdaptiveOptimizer = {}
AdaptiveOptimizer.currentLevel = 1  -- 1 = min opt, 5 = max opt
AdaptiveOptimizer._lastChange = 0
AdaptiveOptimizer._stableSince = 0
AdaptiveOptimizer._levels = {
    { -- Level 1: minimal
        ParticleOptimizer = false, LightingOptimizer = false,
        MeshOptimizer = false, CullingManager = false,
    },
    { -- Level 2
        ParticleOptimizer = true, LightingOptimizer = true,
        MeshOptimizer = false, CullingManager = false,
    },
    { -- Level 3
        ParticleOptimizer = true, LightingOptimizer = true,
        MeshOptimizer = true, CullingManager = true,
        CullingDistance = 600,
    },
    { -- Level 4
        ParticleOptimizer = true, LightingOptimizer = true,
        MeshOptimizer = true, CullingManager = true,
        CullingDistance = 400,
        Accessories = true,
    },
    { -- Level 5: max
        ParticleOptimizer = true, LightingOptimizer = true,
        MeshOptimizer = true, CullingManager = true,
        CullingDistance = 200,
        Accessories = true, Textures = true,
    },
}

function AdaptiveOptimizer:update()
    if not Config.Enabled then return end

    local now = tick()
    local fps = PerformanceMonitor.avgFPS
    local target = Config.TargetFPS
    local hysteresis = Config.HysteresisBand

    if now - self._lastChange < Config.AdaptiveCooldown then return end

    -- Low FPS → increase optimization
    if fps < target - hysteresis and fps < Config.MinFPSThreshold + 10 then
        if self.currentLevel < #self._levels then
            self.currentLevel = self.currentLevel + 1
            self:_applyLevel()
            self._lastChange = now
            self._stableSince = 0
            Logger.log("ADAPTIVE", "Escalated to level", self.currentLevel)
        end
    end

    -- Stable FPS → try decreasing
    if fps >= target - hysteresis and fps > Config.RecoveryThreshold then
        if self._stableSince == 0 then
            self._stableSince = now
        elseif now - self._stableSince > Config.RecoveryDelay then
            if self.currentLevel > 1 then
                self.currentLevel = self.currentLevel - 1
                self:_applyLevel()
                self._lastChange = now
                self._stableSince = 0
                Logger.log("ADAPTIVE", "De-escalated to level", self.currentLevel)
            end
        end
    else
        self._stableSince = 0
    end
end

function AdaptiveOptimizer:_applyLevel()
    local level = self._levels[self.currentLevel]
    if not level then return end

    -- Apply based on level
    Config.ParticlesEnabled = level.ParticleOptimizer or Config.ParticlesEnabled
    Config.LightingEnabled = level.LightingOptimizer or Config.LightingEnabled
    Config.MeshEnabled = level.MeshOptimizer or Config.MeshEnabled
    Config.CullingEnabled = level.CullingManager or Config.CullingEnabled
    if level.CullingDistance then
        Config.CullingDistance = level.CullingDistance
    end
end

-- ============================================================
-- PROFILE MANAGER
-- ============================================================
local ProfileManager = {}
ProfileManager.customProfiles = {}
ProfileManager.activePreset = "Default"

function ProfileManager:applyPreset(name)
    local preset = Presets[name]
    if not preset then
        Logger.log("WARN", "Preset not found:", name)
        return false
    end

    for k, v in pairs(preset) do
        if type(v) == "table" then
            Config[k] = table.clone(v)
        else
            Config[k] = v
        end
    end

    self.activePreset = name
    Logger.log("INFO", "Applied preset:", name)
    return true
end

function ProfileManager:saveCustom(name)
    local snapshot = {}
    for k, v in pairs(Config) do
        if type(v) ~= "function" then
            if type(v) == "table" then
                snapshot[k] = table.clone(v)
            else
                snapshot[k] = v
            end
        end
    end
    self.customProfiles[name] = snapshot
    Logger.log("INFO", "Saved custom profile:", name)
end

function ProfileManager:loadCustom(name)
    local profile = self.customProfiles[name]
    if not profile then return false end
    for k, v in pairs(profile) do
        Config[k] = v
    end
    Logger.log("INFO", "Loaded custom profile:", name)
    return true
end

function ProfileManager:deleteCustom(name)
    self.customProfiles[name] = nil
end

function ProfileManager:export()
    local parts = {}
    for k, v in pairs(Config) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            if type(v) == "table" then
                local sub = {}
                for sk, sv in pairs(v) do
                    table.insert(sub, sk .. "=" .. tostring(sv))
                end
                table.insert(parts, k .. "={" .. table.concat(sub, ",") .. "}")
            else
                table.insert(parts, k .. "=" .. tostring(v))
            end
        end
    end
    return table.concat(parts, "|")
end

function ProfileManager:import(str)
    if not str or str == "" then return false end
    local ok, err = pcall(function()
        for pair in string.gmatch(str, "([^|]+)") do
            local key, val = string.match(pair, "^([^=]+)=(.*)$")
            if key and val then
                -- basic type inference
                if val == "true" then Config[key] = true
                elseif val == "false" then Config[key] = false
                elseif tonumber(val) then Config[key] = tonumber(val)
                elseif string.sub(val, 1, 1) == "{" then
                    -- table, parse simple
                    local tbl = {}
                    for subpair in string.gmatch(string.sub(val, 2, -2), "([^,]+)") do
                        local sk, sv = string.match(subpair, "^([^=]+)=(.*)$")
                        if sk and sv then tbl[sk] = sv end
                    end
                    Config[key] = tbl
                else
                    Config[key] = val
                end
            end
        end
    end)
    return ok
end

-- ============================================================
-- MAIN OPTIMIZATION LOOP
-- ============================================================
local Optimizer = {}
Optimizer._running = false
Optimizer._connection = nil
Optimizer._lightConnection = nil
Optimizer._charConnection = nil
Optimizer._newInstConnection = nil

function Optimizer:processInstance(inst)
    if not Config.Enabled then return end
    if not Util.isAlive(inst) then return end
    if CacheManager:isProcessed(inst) then return end

    local className = inst.ClassName

    if className == "Texture" or className == "Decal" then
        TextureOptimizer:process(inst)
    elseif className == "MeshPart" then
        MeshOptimizer:process(inst)
    elseif className == "ParticleEmitter" or className == "Trail"
        or className == "Beam" or className == "Sparkles"
        or className == "Fire" or className == "Smoke" then
        ParticleOptimizer:process(inst)
    elseif className == "PointLight" or className == "SpotLight"
        or className == "SurfaceLight" then
        LightingOptimizer:processLight(inst)
    elseif className == "BasePart" then
        TransparencyOptimizer:process(inst)
    end
end

function Optimizer:optimizeNow()
    -- Bulk apply all enabled optimizers
    LightingOptimizer:apply()
    TerrainOptimizer:apply()

    -- Process existing instances
    local ok, descendants = pcall(function()
        return Workspace:GetDescendants()
    end)
    if ok then
        for _, inst in ipairs(descendants) do
            self:processInstance(inst)
        end
    end

    -- Process characters
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            CharacterOptimizer:process(plr.Character)
        end
    end

    Logger.log("INFO", "Optimize Now completed")
end

function Optimizer:restoreAll()
    RestoreManager:restoreAll()

    -- Restore characters
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            AccessoryOptimizer:restore(plr.Character)
        end
    end

    Logger.log("INFO", "Restore All completed")
end

function Optimizer:start()
    if self._running then return end
    self._running = true

    -- Main heartbeat
    self._connection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end

        -- Incremental scan
        SmartScanner:scan()

        -- Cache cleanup
        CacheManager:clean()

        -- Performance monitor
        PerformanceMonitor:update()

        -- Adaptive
        AdaptiveOptimizer:update()

        -- Culling
        CullingManager:update()
    end)

    -- Character added
    self._charConnection = Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function(char)
            task.wait(1)
            CharacterOptimizer:process(char)
        end)
    end)

    -- Also handle local player character
    if LocalPlayer.Character then
        task.wait(1)
        CharacterOptimizer:process(LocalPlayer.Character)
    end
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        CharacterOptimizer:process(char)
    end)

    -- New instance detection via DescendantAdded (throttled)
    local pendingNew = {}
    self._newInstConnection = Workspace.DescendantAdded:Connect(function(inst)
        table.insert(pendingNew, inst)
    end)

    -- Process new instances periodically
    task.spawn(function()
        while self._running do
            task.wait(1)
            if #pendingNew > 0 then
                local batch = pendingNew
                pendingNew = {}
                for _, inst in ipairs(batch) do
                    if Util.isAlive(inst) then
                        self:processInstance(inst)
                    end
                end
            end
        end
    end)

    Logger.log("INFO", "Optimizer started")
end

function Optimizer:stop()
    self._running = false
    if self._connection then self._connection:Disconnect() end
    if self._charConnection then self._charConnection:Disconnect() end
    if self._newInstConnection then self._newInstConnection:Disconnect() end
    Logger.log("INFO", "Optimizer stopped")
end

-- ============================================================
-- MOBILE-FIRST UI
-- ============================================================
local UI = {}
UI._gui = nil
UI._frame = nil
UI._currentTab = "HOME"
UI._tabs = {}
UI._controls = {}
UI._minimized = false
UI._dragging = false
UI._dragStart = nil
UI._startPos = nil
UI._scale = 1.0

local COLORS = {
    bg = Color3.fromRGB(20, 20, 25),
    panel = Color3.fromRGB(30, 30, 38),
    accent = Color3.fromRGB(0, 200, 150),
    accentDim = Color3.fromRGB(0, 120, 90),
    text = Color3.fromRGB(240, 240, 240),
    textDim = Color3.fromRGB(160, 160, 170),
    red = Color3.fromRGB(220, 60, 60),
    yellow = Color3.fromRGB(220, 180, 60),
    green = Color3.fromRGB(60, 200, 100),
}

local TABS = {
    "HOME", "GRAPHICS", "TEXTURES", "ACCESSORIES", "LIGHTING",
    "PARTICLES", "MESHES", "CHARACTERS", "CULLING", "CACHE",
    "ADAPTIVE", "PERFORMANCE", "PROFILES", "FILTERS", "ADVANCED", "LOGS",
}

-- Helper: create rounded button
local function makeButton(parent, text, size, pos, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = color or COLORS.panel
    btn.TextColor3 = COLORS.text
    btn.Text = text
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

-- Helper: toggle switch
local function makeToggle(parent, label, initial, callback, pos, size)
    local container = Instance.new("Frame")
    container.Size = size or UDim2.new(1, -20, 0, 36)
    container.Position = pos or UDim2.new(0, 10, 0, 0)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.65, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label
    textLabel.TextColor3 = COLORS.text
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = container

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 26)
    toggle.Position = UDim2.new(1, -50, 0.5, -13)
    toggle.BackgroundColor3 = initial and COLORS.accent or COLORS.panel
    toggle.Text = initial and "ON" or "OFF"
    toggle.TextColor3 = COLORS.text
    toggle.TextSize = 12
    toggle.Font = Enum.Font.GothamBold
    toggle.BorderSizePixel = 0
    toggle.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggle

    toggle.MouseButton1Click:Connect(function()
        local newState = not initial
        initial = newState
        toggle.BackgroundColor3 = newState and COLORS.accent or COLORS.panel
        toggle.Text = newState and "ON" or "OFF"
        if callback then callback(newState) end
    end)

    return container, toggle
end

-- Helper: slider
local function makeSlider(parent, label, min, max, initial, callback, pos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 52)
    container.Position = pos or UDim2.new(0, 10, 0, 0)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0, 20)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label .. ": " .. tostring(initial)
    textLabel.TextColor3 = COLORS.text
    textLabel.TextSize = 13
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = container

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -10, 0, 6)
    bar.Position = UDim2.new(0, 0, 0, 28)
    bar.BackgroundColor3 = COLORS.panel
    bar.BorderSizePixel = 0
    bar.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((initial - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = COLORS.accent
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local dragging = false

    local function updateFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = min + rel * (max - min)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        textLabel.Text = label .. ": " .. string.format("%.0f", val)
        if callback then callback(val) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)

    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)

    return container
end

-- Build UI
function UI:build()
    if self._gui then self._gui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "RATMAN4080_UI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true

    -- Try CoreGui first, fallback to PlayerGui
    local ok = pcall(function() gui.Parent = CoreGui end)
    if not ok then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    self._gui = gui

    -- Main frame
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 380, 0, 520)
    frame.Position = UDim2.new(0.5, -190, 0.5, -260)
    frame.BackgroundColor3 = COLORS.bg
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = false
    frame.Parent = gui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = frame

    self._frame = frame

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = COLORS.panel
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "RATMAN4080"
    title.TextColor3 = COLORS.accent
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Minimize button
    local minBtn = makeButton(titleBar, "—", UDim2.new(0, 30, 0, 30),
        UDim2.new(1, -70, 0.5, -15), function()
            self:minimize()
        end, COLORS.red)

    -- Close button
    local closeBtn = makeButton(titleBar, "✕", UDim2.new(0, 30, 0, 30),
        UDim2.new(1, -36, 0.5, -15), function()
            self:hide()
        end, COLORS.red)

    -- Drag support
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            self._dragging = true
            self._dragStart = input.Position
            self._startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if self._dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - self._dragStart
            frame.Position = UDim2.new(
                self._startPos.X.Scale, self._startPos.X.Offset + delta.X,
                self._startPos.Y.Scale, self._startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            self._dragging = false
        end
    end)

    -- Tab bar
    local tabBar = Instance.new("ScrollingFrame")
    tabBar.Size = UDim2.new(1, -20, 0, 36)
    tabBar.Position = UDim2.new(0, 10, 0, 46)
    tabBar.BackgroundTransparency = 1
    tabBar.BorderSizePixel = 0
    tabBar.ScrollBarThickness = 0
    tabBar.ScrollingDirection = Enum.ScrollingDirection.X
    tabBar.CanvasSize = UDim2.new(0, #TABS * 80, 0, 0)
    tabBar.Parent = frame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabBar

    for _, tabName in ipairs(TABS) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0, 76, 0, 32)
        tabBtn.BackgroundColor3 = tabName == "HOME" and COLORS.accent or COLORS.panel
        tabBtn.Text = tabName
        tabBtn.TextColor3 = COLORS.text
        tabBtn.TextSize = 10
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.BorderSizePixel = 0
        tabBtn.Parent = tabBar

        local tc = Instance.new("UICorner")
        tc.CornerRadius = UDim.new(0, 6)
        tc.Parent = tabBtn

        tabBtn.MouseButton1Click:Connect(function()
            self:switchTab(tabName)
        end)

        self._tabs[tabName] = { button = tabBtn }
    end

    -- Content area
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -120)
    content.Position = UDim2.new(0, 10, 0, 88)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = COLORS.accentDim
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = frame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content

    self._content = content

    -- Bottom bar
    local bottomBar = Instance.new("Frame")
    bottomBar.Size = UDim2.new(1, -20, 0, 40)
    bottomBar.Position = UDim2.new(0, 10, 1, -46)
    bottomBar.BackgroundTransparency = 1
    bottomBar.Parent = frame

    makeButton(bottomBar, "OPTIMIZE NOW", UDim2.new(0.48, 0, 1, 0),
        UDim2.new(0, 0, 0, 0), function()
            Optimizer:optimizeNow()
        end, COLORS.accent)

    makeButton(bottomBar, "RESTORE ALL", UDim2.new(0.48, 0, 1, 0),
        UDim2.new(0.52, 0, 0, 0), function()
            Optimizer:restoreAll()
        end, COLORS.red)

    self:buildTab("HOME")
end

function UI:switchTab(tabName)
    for name, data in pairs(self._tabs) do
        data.button.BackgroundColor3 = name == tabName and COLORS.accent or COLORS.panel
    end
    self._currentTab = tabName
    self:buildTab(tabName)
end

function UI:buildTab(tabName)
    -- Clear content
    for _, child in ipairs(self._content:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end

    local y = 0
    local function addControl(ctrl)
        ctrl.LayoutOrder = y
        ctrl.Parent = self._content
        y = y + 1
    end

    if tabName == "HOME" then
        self:buildHome(addControl)
    elseif tabName == "GRAPHICS" then
        self:buildGraphics(addControl)
    elseif tabName == "TEXTURES" then
        self:buildTextures(addControl)
    elseif tabName == "ACCESSORIES" then
        self:buildAccessories(addControl)
    elseif tabName == "LIGHTING" then
        self:buildLighting(addControl)
    elseif tabName == "PARTICLES" then
        self:buildParticles(addControl)
    elseif tabName == "MESHES" then
        self:buildMeshes(addControl)
    elseif tabName == "CHARACTERS" then
        self:buildCharacters(addControl)
    elseif tabName == "CULLING" then
        self:buildCulling(addControl)
    elseif tabName == "CACHE" then
        self:buildCache(addControl)
    elseif tabName == "ADAPTIVE" then
        self:buildAdaptive(addControl)
    elseif tabName == "PERFORMANCE" then
        self:buildPerformance(addControl)
    elseif tabName == "PROFILES" then
        self:buildProfiles(addControl)
    elseif tabName == "FILTERS" then
        self:buildFilters(addControl)
    elseif tabName == "ADVANCED" then
        self:buildAdvanced(addControl)
    elseif tabName == "LOGS" then
        self:buildLogs(addControl)
    end
end

function UI:buildHome(add)
    -- FPS display
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, 0, 0, 60)
    fpsLabel.BackgroundColor3 = COLORS.panel
    fpsLabel.TextColor3 = COLORS.accent
    fpsLabel.TextSize = 36
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.Text = "FPS: --"
    fpsLabel.Parent = self._content
    fpsLabel.LayoutOrder = 0
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 8)
    fc.Parent = fpsLabel

    -- Update loop
    task.spawn(function()
        while fpsLabel.Parent do
            task.wait(0.5)
            local fps = PerformanceMonitor.avgFPS
            local ft = PerformanceMonitor.frameTime * 1000
            fpsLabel.Text = string.format("FPS: %.0f  |  FT: %.1fms", fps, ft)
            fpsLabel.TextColor3 = fps >= Config.TargetFPS - 5 and COLORS.green
                or fps >= Config.MinFPSThreshold and COLORS.yellow
                or COLORS.red
        end
    end)

    -- Stats panel
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(1, 0, 0, 120)
    statsLabel.BackgroundColor3 = COLORS.panel
    statsLabel.TextColor3 = COLORS.textDim
    statsLabel.TextSize = 12
    statsLabel.Font = Enum.Font.Code
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.TextYAlignment = Enum.TextYAlignment.Top
    statsLabel.Text = "Loading stats..."
    statsLabel.Parent = self._content
    statsLabel.LayoutOrder = 1
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 8)
    sc.Parent = statsLabel

    task.spawn(function()
        while statsLabel.Parent do
            task.wait(1)
            local cacheStats = CacheManager:getStats()
            local mem = PerformanceMonitor:getMemoryMB()
            statsLabel.Text = string.format(
                "Target: %d FPS | Preset: %s\n" ..
                "Estimated Load: %d\n" ..
                "Cache: %d inst | H:%d M:%d\n" ..
                "Memory: %.0f MB | Bottleneck: %s\n" ..
                "Particles: %d | MeshPart: %d\n" ..
                "Textures: %d | Accessories: %d",
                Config.TargetFPS, ProfileManager.activePreset,
                SmartScanner:getEstimatedCost(),
                cacheStats.cachedInstances, cacheStats.hits, cacheStats.misses,
                mem, PerformanceMonitor.bottleneck,
                SmartScanner:getCount("ParticleEmitter"),
                SmartScanner:getCount("MeshPart"),
                SmartScanner:getCount("Texture") + SmartScanner:getCount("Decal"),
                SmartScanner:getCount("Accessory")
            )
        end
    end)

    -- Mode display
    local modeLabel = Instance.new("TextLabel")
    modeLabel.Size = UDim2.new(1, 0, 0, 36)
    modeLabel.BackgroundColor3 = COLORS.panel
    modeLabel.TextColor3 = COLORS.text
    modeLabel.TextSize = 13
    modeLabel.Font = Enum.Font.Gotham
    modeLabel.Text = "Mode: " .. (Config.Enabled and "ACTIVE" or "IDLE")
    modeLabel.Parent = self._content
    modeLabel.LayoutOrder = 2
    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 8)
    mc.Parent = modeLabel

    -- Quick toggles
    add(makeToggle(self._content, "Optimizer Enabled", Config.Enabled, function(v)
        Config.Enabled = v
        if v then Optimizer:start() else Optimizer:stop() end
    end, UDim2.new(0, 10, 0, 0)))

    add(makeToggle(self._content, "Debug Mode", Config.DebugMode, function(v)
        Config.DebugMode = v
    end))
end

function UI:buildGraphics(add)
    add(makeToggle(self._content, "Master Graphics Optimization", Config.Enabled, function(v)
        Config.Enabled = v
    end))

    add(makeToggle(self._content, "Aggressive Mode", Config.AggressiveMode, function(v)
        Config.AggressiveMode = v
        if v then
            Config.LightingProfile = "Aggressive"
            Config.TransparencyAggressive = true
            Config.ParticlesEnabled = true
            Config.MaxParticleRate = 5
        end
    end))

    add(makeToggle(self._content, "Heavy Script Compatibility", Config.HeavyScriptCompat, function(v)
        Config.HeavyScriptCompat = v
        if v then
            Config.ScanInterval = 5.0
            Config.AdaptiveCooldown = 15.0
            Config.OptimizationBudgetPerFrame = 15
        else
            Config.ScanInterval = 2.0
            Config.AdaptiveCooldown = 8.0
            Config.OptimizationBudgetPerFrame = 30
        end
    end))

    add(makeToggle(self._content, "Safe Mode", Config.SafeMode, function(v)
        Config.SafeMode = v
    end))
end

function UI:buildTextures(add)
    add(makeToggle(self._content, "Enable Texture Optimization", Config.TexturesEnabled, function(v)
        Config.TexturesEnabled = v
    end))

    -- Mode selector
    local modeContainer = Instance.new("Frame")
    modeContainer.Size = UDim2.new(1, -20, 0, 80)
    modeContainer.BackgroundTransparency = 1
    modeContainer.Parent = self._content
    modeContainer.LayoutOrder = 100
    add(modeContainer)

    local modeLabel = Instance.new("TextLabel")
    modeLabel.Size = UDim2.new(1, 0, 0, 20)
    modeLabel.BackgroundTransparency = 1
    modeLabel.Text = "Texture Mode"
    modeLabel.TextColor3 = COLORS.text
    modeLabel.TextSize = 13
    modeLabel.Font = Enum.Font.Gotham
    modeLabel.Parent = modeContainer

    local modes = {"Low", "VeryLow", "UltraPotato", "Off"}
    for i, mode in ipairs(modes) do
        local btn = makeButton(modeContainer, mode, UDim2.new(0, 80, 0, 28),
            UDim2.new(0, (i-1) * 85, 0, 28), function()
                Config.TextureMode = mode
            end, Config.TextureMode == mode and COLORS.accent or COLORS.panel)
        btn.TextSize = 11
    end

    add(makeToggle(self._content, "Process Character Textures", Config.ProcessCharacterTextures, function(v)
        Config.ProcessCharacterTextures = v
    end))

    add(makeToggle(self._content, "Process World Textures", Config.ProcessWorldTextures, function(v)
        Config.ProcessWorldTextures = v
    end))
end

function UI:buildAccessories(add)
    add(makeToggle(self._content, "Enable Accessory Optimization", Config.AccessoriesEnabled, function(v)
        Config.AccessoriesEnabled = v
    end))

    add(makeToggle(self._content, "Grey Accessories", Config.AccessoryGrey, function(v)
        Config.AccessoryGrey = v
    end))

    add(makeToggle(self._content, "Cheap Material (Plastic)", Config.AccessoryCheapMaterial, function(v)
        Config.AccessoryCheapMaterial = v
    end))

    add(makeToggle(self._content, "Hide Accessory Visuals", Config.AccessoryHideVisuals, function(v)
        Config.AccessoryHideVisuals = v
    end))

    add(makeToggle(self._content, "Exclude Local Character", Config.AccessoryExcludeLocalCharacter, function(v)
        Config.AccessoryExcludeLocalCharacter = v
    end))
end

function UI:buildLighting(add)
    add(makeToggle(self._content, "Enable Lighting Optimization", Config.LightingEnabled, function(v)
        Config.LightingEnabled = v
        if v then LightingOptimizer:apply() end
    end))

    local profiles = {"Low", "Medium", "Aggressive"}
    for i, p in ipairs(profiles) do
        local btn = makeButton(self._content, p, UDim2.new(0, 110, 0, 32),
            UDim2.new(0, (i-1) * 115, 0, 0), function()
                Config.LightingProfile = p
                LightingOptimizer:apply()
            end, Config.LightingProfile == p and COLORS.accent or COLORS.panel)
        btn.TextSize = 12
    end

    add(makeToggle(self._content, "Disable Global Shadows", Config.DisableShadows, function(v)
        Config.DisableShadows = v
        if v then Util.safeSet(Lighting, "GlobalShadows", false) end
    end))

    add(makeToggle(self._content, "Disable Bloom", Config.DisableBloom, function(v) Config.DisableBloom = v end))
    add(makeToggle(self._content, "Disable ColorCorrection", Config.DisableColorCorrection, function(v) Config.DisableColorCorrection = v end))
    add(makeToggle(self._content, "Disable DepthOfField", Config.DisableDepthOfField, function(v) Config.DisableDepthOfField = v end))
    add(makeToggle(self._content, "Disable SunRays", Config.DisableSunRays, function(v) Config.DisableSunRays = v end))
    add(makeToggle(self._content, "Disable Blur", Config.DisableBlur, function(v) Config.DisableBlur = v end))
    add(makeToggle(self._content, "Disable Atmosphere", Config.DisableAtmosphere, function(v) Config.DisableAtmosphere = v end))
    add(makeToggle(self._content, "Disable PointLights", Config.DisablePointLights, function(v) Config.DisablePointLights = v end))
    add(makeToggle(self._content, "Disable SpotLights", Config.DisableSpotLights, function(v) Config.DisableSpotLights = v end))

    add(makeSlider(self._content, "Max Light Distance", 20, 200, Config.MaxLightDistance, function(v)
        Config.MaxLightDistance = v
    end))
end

function UI:buildParticles(add)
    add(makeToggle(self._content, "Enable Particle Optimization", Config.ParticlesEnabled, function(v)
        Config.ParticlesEnabled = v
    end))

    add(makeSlider(self._content, "Max Particle Rate", 1, 100, Config.MaxParticleRate, function(v)
        Config.MaxParticleRate = v
    end))

    add(makeSlider(self._content, "Particle Distance Cull", 20, 300, Config.ParticleDistanceCull, function(v)
        Config.ParticleDistanceCull = v
    end))

    add(makeToggle(self._content, "Disable Trails", Config.DisableTrails, function(v) Config.DisableTrails = v end))
    add(makeToggle(self._content, "Disable Beams", Config.DisableBeams, function(v) Config.DisableBeams = v end))
    add(makeToggle(self._content, "Disable Sparkles", Config.DisableSparkles, function(v) Config.DisableSparkles = v end))
    add(makeToggle(self._content, "Disable Fire", Config.DisableFire, function(v) Config.DisableFire = v end))
    add(makeToggle(self._content, "Disable Smoke", Config.DisableSmoke, function(v) Config.DisableSmoke = v end))
    add(makeToggle(self._content, "Adaptive Particle Scaling", Config.ParticleAdaptive, function(v) Config.ParticleAdaptive = v end))
end

function UI:buildMeshes(add)
    add(makeToggle(self._content, "Enable Mesh Optimization", Config.MeshEnabled, function(v)
        Config.MeshEnabled = v
    end))

    add(makeToggle(self._content, "Aggressive Mesh Mode", Config.MeshAggressive, function(v)
        Config.MeshAggressive = v
    end))

    add(makeSlider(self._content, "Mesh Distance Threshold", 50, 500, Config.MeshDistanceThreshold, function(v)
        Config.MeshDistanceThreshold = v
    end))

    local infos = {"Performance", "Automatic"}
    for i, p in ipairs(infos) do
        local btn = makeButton(self._content, p, UDim2.new(0, 130, 0, 32),
            UDim2.new(0, (i-1) * 135, 0, 0), function()
                Config.MeshRenderFidelity = p
            end, Config.MeshRenderFidelity == p and COLORS.accent or COLORS.panel)
        btn.TextSize = 12
    end
end

function UI:buildCharacters(add)
    add(makeToggle(self._content, "Enable Character Optimization", Config.CharacterEnabled, function(v)
        Config.CharacterEnabled = v
    end))

    add(makeToggle(self._content, "Simplify Local Character", Config.CharacterLocalSimplify, function(v)
        Config.CharacterLocalSimplify = v
    end))

    add(makeToggle(self._content, "Simplify Other Characters", Config.CharacterOthersSimplify, function(v)
        Config.CharacterOthersSimplify = v
    end))

    add(makeToggle(self._content, "Disable Layered Clothing", Config.CharacterLayeredClothing, function(v)
        Config.CharacterLayeredClothing = v
    end))

    add(makeToggle(self._content, "Low Character Graphics", Config.CharacterLowGraphics, function(v)
        Config.CharacterLowGraphics = v
    end))
end

function UI:buildCulling(add)
    add(makeToggle(self._content, "Enable Culling", Config.CullingEnabled, function(v)
        Config.CullingEnabled = v
    end))

    add(makeSlider(self._content, "Culling Distance", 100, 2000, Config.CullingDistance, function(v)
        Config.CullingDistance = v
    end))

    add(makeSlider(self._content, "Culling Update Interval", 0.1, 2.0, Config.CullingUpdateInterval, function(v)
        Config.CullingUpdateInterval = v
    end))

    add(makeToggle(self._content, "Exclude Local Character", Config.CullingExcludeLocalCharacter, function(v)
        Config.CullingExcludeLocalCharacter = v
    end))
end

function UI:buildCache(add)
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(1, 0, 0, 80)
    statsLabel.BackgroundColor3 = COLORS.panel
    statsLabel.TextColor3 = COLORS.textDim
    statsLabel.TextSize = 13
    statsLabel.Font = Enum.Font.Code
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Text = "Loading cache stats..."
    statsLabel.Parent = self._content
    statsLabel.LayoutOrder = 0
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = statsLabel

    task.spawn(function()
        while statsLabel.Parent do
            task.wait(1)
            local s = CacheManager:getStats()
            statsLabel.Text = string.format(
                "Cached: %d instances\nHits: %d | Misses: %d\nHit rate: %.1f%%",
                s.cachedInstances, s.hits, s.misses,
                s.hits + s.misses > 0 and (s.hits / (s.hits + s.misses) * 100) or 0
            )
        end
    end)

    add(makeButton(self._content, "Clear Cache", UDim2.new(1, 0, 0, 36), UDim2.new(0, 0, 0, 0), function()
        CacheManager:clearAll()
    end, COLORS.red))
end

function UI:buildAdaptive(add)
    add(makeToggle(self._content, "Enable Adaptive Optimizer", Config.Enabled, function(v)
        Config.Enabled = v
    end))

    add(makeSlider(self._content, "Target FPS", 15, 120, Config.TargetFPS, function(v)
        Config.TargetFPS = v
    end))

    add(makeSlider(self._content, "Min FPS Threshold", 10, 60, Config.MinFPSThreshold, function(v)
        Config.MinFPSThreshold = v
    end))

    add(makeSlider(self._content, "Recovery Threshold", 30, 120, Config.RecoveryThreshold, function(v)
        Config.RecoveryThreshold = v
    end))

    add(makeSlider(self._content, "Recovery Delay (sec)", 1, 30, Config.RecoveryDelay, function(v)
        Config.RecoveryDelay = v
    end))

    add(makeSlider(self._content, "Adaptive Cooldown (sec)", 2, 60, Config.AdaptiveCooldown, function(v)
        Config.AdaptiveCooldown = v
    end))

    add(makeSlider(self._content, "Hysteresis Band", 1, 20, Config.HysteresisBand, function(v)
        Config.HysteresisBand = v
    end))
end

function UI:buildPerformance(add)
    local perfLabel = Instance.new("TextLabel")
    perfLabel.Size = UDim2.new(1, 0, 0, 140)
    perfLabel.BackgroundColor3 = COLORS.panel
    perfLabel.TextColor3 = COLORS.textDim
    perfLabel.TextSize = 12
    perfLabel.Font = Enum.Font.Code
    perfLabel.TextXAlignment = Enum.TextXAlignment.Left
    perfLabel.TextYAlignment = Enum.TextYAlignment.Top
    perfLabel.Text = "Loading performance data..."
    perfLabel.Parent = self._content
    perfLabel.LayoutOrder = 0
    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 8)
    pc.Parent = perfLabel

    task.spawn(function()
        while perfLabel.Parent do
            task.wait(1)
            local fps = PerformanceMonitor.avgFPS
            local ft = PerformanceMonitor.frameTime * 1000
            local low1 = PerformanceMonitor:get1PercentLow()
            local mem = PerformanceMonitor:getMemoryMB()
            perfLabel.Text = string.format(
                "FPS: %.0f | Avg: %.0f | 1%% Low: %.0f\n" ..
                "Frame Time: %.1f ms\n" ..
                "Memory: %.0f MB\n" ..
                "Bottleneck: %s\n" ..
                "CPU Frame: %.1f ms | GPU Frame: %.1f ms\n" ..
                "Primitives: %d | Drawcalls: %d",
                PerformanceMonitor.fps, fps, low1,
                ft, mem,
                PerformanceMonitor.bottleneck,
                Stats.RenderCPUFrameTime * 1000, Stats.RenderGPUFrameTime * 1000,
                Stats.PrimitivesCount, Stats.SceneDrawcallCount
            )
        end
    end)
end

function UI:buildProfiles(add)
    local presets = {"Default", "Balanced", "Performance", "Low", "VeryLow", "Potato", "UltraPotato"}
    for _, p in ipairs(presets) do
        add(makeButton(self._content, "Apply: " .. p, UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 0), function()
            ProfileManager:applyPreset(p)
        end, p == ProfileManager.activePreset and COLORS.accent or COLORS.panel))
    end

    add(makeButton(self._content, "Save Custom Profile", UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 0), function()
        ProfileManager:saveCustom("Custom_" .. tostring(os.time()))
    end, COLORS.accentDim))

    add(makeButton(self._content, "Export Settings", UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 0), function()
        local str = ProfileManager:export()
        if setclipboard then setclipboard(str) end
    end, COLORS.panel))

    add(makeButton(self._content, "Import Settings", UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 0), function()
        if getclipboard then
            local str = getclipboard()
            ProfileManager:import(str)
        end
    end, COLORS.panel))
end

function UI:buildFilters(add)
    add(makeButton(self._content, "Add to Texture Whitelist", UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 0), function()
        -- Simple: add currently selected object name
    end, COLORS.panel))

    add(makeButton(self._content, "Clear All Filters", UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 0), function()
        Config.TextureWhitelist = {}
        Config.TextureBlacklist = {}
        Config.AccessoryWhitelist = {}
    end, COLORS.red))
end

function UI:buildAdvanced(add)
    add(makeSlider(self._content, "Scan Interval (sec)", 0.5, 10, Config.ScanInterval, function(v) Config.ScanInterval = v end))
    add(makeSlider(self._content, "Optimization Budget/Frame", 5, 100, Config.OptimizationBudgetPerFrame, function(v) Config.OptimizationBudgetPerFrame = v end))
    add(makeSlider(self._content, "Scan Budget/Frame", 10, 200, Config.ScanBudgetPerFrame, function(v) Config.ScanBudgetPerFrame = v end))
    add(makeSlider(self._content, "Cache Clean Interval", 5, 120, Config.CacheCleanInterval, function(v) Config.CacheCleanInterval = v end))
    add(makeSlider(self._content, "Cache Max Size", 100, 20000, Config.CacheMaxSize, function(v) Config.CacheMaxSize = v end))

    add(makeToggle(self._content, "Auto Restore", Config.SafeMode, function(v) Config.SafeMode = v end))
    add(makeToggle(self._content, "Optimize Newly Spawned Objects", true, function(v)
        Config.OptimizeNew = v
    end))
    add(makeToggle(self._content, "Optimize Character Respawn", true, function(v)
        Config.OptimizeRespawn = v
    end))
end

function UI:buildLogs(add)
    local logLabel = Instance.new("TextLabel")
    logLabel.Size = UDim2.new(1, 0, 0, 200)
    logLabel.BackgroundColor3 = COLORS.panel
    logLabel.TextColor3 = COLORS.textDim
    logLabel.TextSize = 11
    logLabel.Font = Enum.Font.Code
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.TextYAlignment = Enum.TextYAlignment.Top
    logLabel.Text = "Log output appears here (Debug Mode)."
    logLabel.Parent = self._content
    logLabel.LayoutOrder = 0
    local lc = Instance.new("UICorner")
    lc.CornerRadius = UDim.new(0, 8)
    lc.Parent = logLabel
end

function UI:minimize()
    self._minimized = not self._minimized
    if self._frame then
        self._frame.Visible = not self._minimized
    end
end

function UI:hide()
    if self._gui then self._gui.Enabled = false end
end

function UI:show()
    if self._gui then self._gui.Enabled = true end
end

function UI:createFloatingButton()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0, 20, 0.5, -25)
    btn.BackgroundColor3 = COLORS.accent
    btn.Text = "R"
    btn.TextColor3 = COLORS.bg
    btn.TextSize = 20
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = self._gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local dragging = false
    local startPos, startMouse

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = btn.Position
            startMouse = input.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startMouse
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if not dragging then
                self:minimize()
            end
            dragging = false
        end
    end)
end

-- ============================================================
-- OVERLAY
-- ============================================================
local Overlay = {}

function Overlay:create()
    if not Config.OverlayEnabled then return end

    local gui = self._gui or UI._gui
    if not gui then return end

    local overlay = Instance.new("TextLabel")
    overlay.Name = "PerfOverlay"
    overlay.Size = UDim2.new(0, 220, 0, 90)
    overlay.Position = Config.OverlayPosition
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    overlay.TextColor3 = COLORS.accent
    overlay.TextSize = Config.OverlaySize
    overlay.Font = Enum.Font.Code
    overlay.TextXAlignment = Enum.TextXAlignment.Left
    overlay.TextYAlignment = Enum.TextYAlignment.Top
    overlay.Text = "RATMAN4080"
    overlay.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = overlay

    self._overlay = overlay

    task.spawn(function()
        while overlay.Parent do
            task.wait(0.25)
            local fps = PerformanceMonitor.avgFPS
            local ft = PerformanceMonitor.frameTime * 1000
            local lines = {}
            if Config.OverlayShowFPS then
                table.insert(lines, string.format("FPS: %.0f", fps))
            end
            if Config.OverlayShowFrameTime then
                table.insert(lines, string.format("FT: %.1fms", ft))
            end
            if Config.OverlayShowTarget then
                table.insert(lines, string.format("Target: %d", Config.TargetFPS))
            end
            if Config.OverlayShowPreset then
                table.insert(lines, string.format("Preset: %s", ProfileManager.activePreset))
            end
            if Config.OverlayShowState then
                table.insert(lines, string.format("State: %s", Config.Enabled and "ON" or "OFF"))
            end
            overlay.Text = table.concat(lines, "\n")
            overlay.TextColor3 = fps >= Config.TargetFPS - 5 and COLORS.green
                or fps >= Config.MinFPSThreshold and COLORS.yellow
                or COLORS.red
        end
    end)
end

-- ============================================================
-- ENTRY POINT
-- ============================================================
local function main()
    Logger.log("INFO", "RATMAN4080 v" .. Config.Version .. " initializing...")

    -- Detect device class
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    if isMobile then
        Logger.log("INFO", "Mobile device detected")
        Config.ScanBudgetPerFrame = 30
        Config.OptimizationBudgetPerFrame = 20
        Config.AdaptiveCooldown = 10.0
    end

    -- Auto-select initial profile
    if isMobile then
        ProfileManager:applyPreset("Performance")
    else
        ProfileManager:applyPreset("Balanced")
    end

    -- Build UI
    UI:build()
    UI:createFloatingButton()
    Overlay:create()

    -- Start optimizer
    Optimizer:start()

    -- Initial optimization
    task.wait(2)
    Optimizer:optimizeNow()

    Logger.log("INFO", "RATMAN4080 ready. Target:", Config.TargetFPS, "FPS")
end

-- Run
task.spawn(function()
    local ok, err = pcall(main)
    if not ok then
        warn("[RATMAN4080] FATAL: " .. tostring(err))
    end
end)
