--[[
    Roblox Injector FPS/Graphics Optimizer
    Single File Edition for Mobile
    
    Features:
    - Adaptive FPS Optimization
    - Texture/Decal Optimization
    - Mesh/LOD Optimization
    - Lighting Optimization
    - Particle Optimization
    - Character Optimization
    - Safe Restore System
    - Mobile UI
    - Performance Monitoring
]]

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

--// Main Table
local Optimizer = {}

--// Configuration
Optimizer.Config = {
    -- Target FPS
    TargetFPS = 60,
    MinFPS = 30,
    
    -- Scan Settings
    ScanInterval = 2, -- Seconds
    OptimizationBudget = 50, -- Objects per scan
    
    -- Modes
    AggressiveMode = false,
    SafeMode = true,
    DebugMode = false,
    
    -- Presets
    CurrentPreset = "Balanced",
    AutoOptimize = true,
    
    -- UI Settings
    UIEnabled = true,
    UICompact = false,
    UIPosition = Vector2.new(0.85, 0.1),
    
    -- Cache
    CacheEnabled = true,
    CacheLimit = 500,
    
    -- Performance
    FrameHistory = {},
    HistorySize = 60,
    LastOptimize = 0,
    OptimizeCooldown = 3,
}

--// Presets
Optimizer.Presets = {
    Default = {
        TextureQuality = 0.5,
        MeshLOD = 1,
        ParticleRate = 0.5,
        LightingQuality = 0.5,
        ShadowQuality = 0.5,
        PostEffects = false,
        CharacterOptimization = false,
        AccessoryOptimization = false,
    },
    Balanced = {
        TextureQuality = 0.3,
        MeshLOD = 1,
        ParticleRate = 0.3,
        LightingQuality = 0.3,
        ShadowQuality = 0.3,
        PostEffects = false,
        CharacterOptimization = true,
        AccessoryOptimization = true,
    },
    Performance = {
        TextureQuality = 0.1,
        MeshLOD = 0,
        ParticleRate = 0.1,
        LightingQuality = 0.1,
        ShadowQuality = 0.1,
        PostEffects = false,
        CharacterOptimization = true,
        AccessoryOptimization = true,
    },
    Low = {
        TextureQuality = 0,
        MeshLOD = 0,
        ParticleRate = 0,
        LightingQuality = 0,
        ShadowQuality = 0,
        PostEffects = false,
        CharacterOptimization = true,
        AccessoryOptimization = true,
    },
    UltraPotato = {
        TextureQuality = 0,
        MeshLOD = 0,
        ParticleRate = 0,
        LightingQuality = 0,
        ShadowQuality = 0,
        PostEffects = false,
        CharacterOptimization = true,
        AccessoryOptimization = true,
        RemoveDecals = true,
        RemoveTextures = true,
    }
}

--// Cache System
Optimizer.Cache = {
    Objects = {}, -- Instance -> {original, optimized}
    Stats = {Hits = 0, Misses = 0, Processed = 0}
}

function Optimizer:CacheGet(instance)
    if self.CacheEnabled then
        local cached = self.Cache.Objects[instance]
        if cached then
            self.Cache.Stats.Hits = self.Cache.Stats.Hits + 1
            return cached
        else
            self.Cache.Stats.Misses = self.Cache.Stats.Misses + 1
        end
    end
    return nil
end

function Optimizer:CacheSet(instance, original, optimized)
    if self.CacheEnabled then
        -- Limit cache size
        local count = 0
        for _ in pairs(self.Cache.Objects) do
            count = count + 1
        end
        
        if count >= self.CacheLimit then
            -- Remove oldest entry
            local oldest = nil
            local oldestTime = math.huge
            for inst, data in pairs(self.Cache.Objects) do
                if data.timestamp < oldestTime then
                    oldestTime = data.timestamp
                    oldest = inst
                end
            end
            if oldest then
                self.Cache.Objects[oldest] = nil
            end
        end
        
        self.Cache.Objects[instance] = {
            original = original,
            optimized = optimized,
            timestamp = tick()
        }
        self.Cache.Stats.Processed = self.Cache.Stats.Processed + 1
    end
end

function Optimizer:CacheClear()
    self.Cache.Objects = {}
    self.Cache.Stats = {Hits = 0, Misses = 0, Processed = 0}
end

--// Performance Monitor
Optimizer.Performance = {
    FPS = 60,
    FrameTime = 16.67,
    Memory = 0,
    AverageFPS = 60,
    LowFPS = 60,
    HighFPS = 60,
    Bottleneck = "Unknown"
}

function Optimizer:MonitorPerformance()
    RunService.Heartbeat:Connect(function()
        local startTime = tick()
        
        -- Calculate frame time
        local frameTime = tick() - self.Performance.LastTime or 0.016
        self.Performance.LastTime = startTime
        
        -- Update FPS
        self.Performance.FPS = 1 / math.max(frameTime, 0.0001)
        self.Performance.FrameTime = frameTime * 1000
        
        -- Update averages
        table.insert(self.Config.FrameHistory, self.Performance.FPS)
        if #self.Config.FrameHistory > self.Config.HistorySize then
            table.remove(self.Config.FrameHistory, 1)
        end
        
        local sum = 0
        for _, fps in ipairs(self.Config.FrameHistory) do
            sum = sum + fps
        end
        self.Performance.AverageFPS = sum / #self.Config.FrameHistory
        
        -- Update high/low
        if self.Performance.FPS > self.Performance.HighFPS then
            self.Performance.HighFPS = self.Performance.FPS
        end
        if self.Performance.FPS < self.Performance.LowFPS then
            self.Performance.LowFPS = self.Performance.FPS
        end
        
        -- Memory usage
        pcall(function()
            self.Performance.Memory = Stats:GetTotalMemoryUsageMiB()
        end)
        
        -- Bottleneck detection
        self:DetectBottleneck()
    end)
end

function Optimizer:DetectBottleneck()
    local fps = self.Performance.AverageFPS
    local frameTime = self.Performance.FrameTime
    
    if fps < self.Config.TargetFPS * 0.8 then
        if frameTime > 16.67 then -- High frame time indicates CPU bottleneck
            self.Performance.Bottleneck = "CPU/Script"
        else
            self.Performance.Bottleneck = "GPU/Render"
        end
    elseif self.Performance.Memory > 500 then
        self.Performance.Bottleneck = "Memory"
    else
        self.Performance.Bottleneck = "Unknown"
    end
end

--// Scanner System
Optimizer.Scanner = {
    Categories = {
        BasePart = {},
        MeshPart = {},
        Texture = {},
        Decal = {},
        SurfaceAppearance = {},
        ParticleEmitter = {},
        Trail = {},
        Beam = {},
        Light = {},
        Accessory = {},
        Character = {}
    },
    LastScan = 0
}

function Optimizer:ScanWorkspace()
    local startTime = tick()
    
    -- Clear categories
    for category, _ in pairs(self.Scanner.Categories) do
        self.Scanner.Categories[category] = {}
    end
    
    -- Get all descendants
    local descendants = workspace:GetDescendants()
    
    for _, instance in ipairs(descendants) do
        self:ProcessInstance(instance)
    end
    
    self.Scanner.LastScan = tick()
    
    if self.Config.DebugMode then
        print(string.format("[Optimizer] Scan completed in %.2f ms, found %d instances", 
            (tick() - startTime) * 1000, #descendants))
    end
    
    return self.Scanner.Categories
end

function Optimizer:ProcessInstance(instance)
    local className = instance.ClassName
    
    -- BasePart
    if instance:IsA("BasePart") then
        table.insert(self.Scanner.Categories.BasePart, instance)
    end
    
    -- MeshPart
    if instance:IsA("MeshPart") then
        table.insert(self.Scanner.Categories.MeshPart, instance)
    end
    
    -- Texture/Decal
    if instance:IsA("Texture") or instance:IsA("Decal") then
        table.insert(self.Scanner.Categories.Texture, instance)
    end
    
    -- SurfaceAppearance
    if instance:IsA("SurfaceAppearance") then
        table.insert(self.Scanner.Categories.SurfaceAppearance, instance)
    end
    
    -- ParticleEmitter
    if instance:IsA("ParticleEmitter") then
        table.insert(self.Scanner.Categories.ParticleEmitter, instance)
    end
    
    -- Trail
    if instance:IsA("Trail") then
        table.insert(self.Scanner.Categories.Trail, instance)
    end
    
    -- Beam
    if instance:IsA("Beam") then
        table.insert(self.Scanner.Categories.Beam, instance)
    end
    
    -- Light
    if instance:IsA("Light") then
        table.insert(self.Scanner.Categories.Light, instance)
    end
    
    -- Accessory
    if instance:IsA("Accessory") then
        table.insert(self.Scanner.Categories.Accessory, instance)
    end
    
    -- Character
    if instance:IsA("Model") and instance:FindFirstChildOfClass("Humanoid") then
        table.insert(self.Scanner.Categories.Character, instance)
    end
end

--// Optimizer: Texture
function Optimizer:OptimizeTextures(level)
    local preset = self.Presets[self.Config.CurrentPreset]
    if not preset or not preset.TextureQuality then return end
    
    local textureInstances = self.Scanner.Categories.Texture
    local decalInstances = self.Scanner.Categories.Decal or {}
    
    -- Combine textures and decals
    local allTextures = {}
    for _, inst in ipairs(textureInstances) do
        table.insert(allTextures, inst)
    end
    for _, inst in ipairs(decalInstances) do
        table.insert(allTextures, inst)
    end
    
    for _, texture in ipairs(allTextures) do
        -- Check cache
        local cached = self:CacheGet(texture)
        if cached then
            -- Already processed
            if cached.optimized.transparency == 1 and preset.TextureQuality > 0 then
                -- Restore if needed
                texture.Transparency = cached.original.transparency
            end
        else
            -- Save original
            local original = {
                Texture = texture.Texture,
                Transparency = texture.Transparency,
                Visible = texture.Visible
            }
            
            -- Apply optimization
            if preset.TextureQuality <= 0.1 then
                -- Very low: hide
                texture.Transparency = 1
                texture.Visible = false
            elseif preset.TextureQuality <= 0.3 then
                -- Low: reduce transparency
                texture.Transparency = math.max(texture.Transparency, 0.7)
            elseif preset.TextureQuality <= 0.5 then
                -- Medium: slight reduction
                texture.Transparency = math.max(texture.Transparency, 0.3)
            end
            
            -- Ultra Potato: remove textures completely
            if preset.RemoveTextures then
                texture.Texture = "rbxassetid://0"
            end
            
            -- Cache
            self:CacheSet(texture, original, {
                Texture = texture.Texture,
                Transparency = texture.Transparency,
                Visible = texture.Visible
            })
        end
    end
    
    return #allTextures
end

--// Optimizer: Mesh
function Optimizer:OptimizeMeshes()
    local preset = self.Presets[self.Config.CurrentPreset]
    if not preset or not preset.MeshLOD then return end
    
    local meshParts = self.Scanner.Categories.MeshPart
    
    for _, meshPart in ipairs(meshParts) do
        -- Check cache
        local cached = self:CacheGet(meshPart)
        if not cached then
            -- Save original
            local original = {
                RenderFidelity = meshPart.RenderFidelity,
                LevelOfDetail = meshPart.LevelOfDetail
            }
            
            -- Apply optimization
            if preset.MeshLOD <= 0 then
                -- Performance mode
                meshPart.RenderFidelity = Enum.RenderFidelity.Performance
                if meshPart:IsA("MeshPart") then
                    meshPart.LevelOfDetail = Enum.MeshDetailLevel.Maximum
                end
            elseif preset.MeshLOD == 1 then
                -- Automatic
                meshPart.RenderFidelity = Enum.RenderFidelity.Automatic
                if meshPart:IsA("MeshPart") then
                    meshPart.LevelOfDetail = Enum.MeshDetailLevel.Medium
                end
            end
            
            -- Cache
            self:CacheSet(meshPart, original, {
                RenderFidelity = meshPart.RenderFidelity,
                LevelOfDetail = meshPart.LevelOfDetail
            })
        end
    end
    
    return #meshParts
end

--// Optimizer: Lighting
function Optimizer:OptimizeLighting()
    local preset = self.Presets[self.Config.CurrentPreset]
    if not preset then return end
    
    -- Save original lighting settings
    local original = {
        Brightness = Lighting.Brightness,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        Technology = Lighting.Technology
    }
    
    -- Apply optimization based on preset
    if preset.LightingQuality <= 0.1 then
        -- Ultra low
        Lighting.Brightness = 1
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 500
        Lighting.FogStart = 0
        Lighting.Technology = Enum.Technology.Compatibility
    elseif preset.LightingQuality <= 0.3 then
        -- Low
        Lighting.Brightness = 1
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
        Lighting.Technology = Enum.Technology.Compatibility
    elseif preset.LightingQuality <= 0.5 then
        -- Medium
        Lighting.Brightness = 1.5
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 2000
        Lighting.FogStart = 0
        Lighting.Technology = Enum.Technology.Voxel
    end
    
    -- Disable post-processing effects
    if not preset.PostEffects then
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("PostEffect") then
                child.Enabled = false
            end
        end
    end
    
    -- Cache lighting
    self:CacheSet(Lighting, original, {})
    
    return true
end

--// Optimizer: Particles
function Optimizer:OptimizeParticles()
    local preset = self.Presets[self.Config.CurrentPreset]
    if not preset or not preset.ParticleRate then return end
    
    local emitters = self.Scanner.Categories.ParticleEmitter
    
    for _, emitter in ipairs(emitters) do
        -- Check cache
        local cached = self:CacheGet(emitter)
        if not cached then
            -- Save original
            local original = {
                Rate = emitter.Rate,
                Lifetime = emitter.Lifetime,
                Speed = emitter.Speed,
                Enabled = emitter.Enabled
            }
            
            -- Apply optimization
            if preset.ParticleRate <= 0.1 then
                -- Very low: disable
                emitter.Enabled = false
            elseif preset.ParticleRate <= 0.3 then
                -- Low: reduce rate
                emitter.Rate = math.floor(emitter.Rate * 0.1)
                emitter.Lifetime = NumberRange.new(0.1, 0.3)
            elseif preset.ParticleRate <= 0.5 then
                -- Medium: reduce rate
                emitter.Rate = math.floor(emitter.Rate * 0.3)
                emitter.Lifetime = NumberRange.new(0.3, 0.5)
            end
            
            -- Cache
            self:CacheSet(emitter, original, {
                Rate = emitter.Rate,
                Lifetime = emitter.Lifetime,
                Speed = emitter.Speed,
                Enabled = emitter.Enabled
            })
        end
    end
    
    return #emitters
end

--// Optimizer: Characters
function Optimizer:OptimizeCharacters()
    local preset = self.Presets[self.Config.CurrentPreset]
    if not preset or not preset.CharacterOptimization then return end
    
    local characters = self.Scanner.Categories.Character
    
    for _, character in ipairs(characters) do
        -- Skip own character if not aggressive
        local player = Players:GetPlayerFromCharacter(character)
        if player == Players.LocalPlayer and not self.Config.AggressiveMode then
            continue
        end
        
        -- Optimize parts
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Check cache
                local cached = self:CacheGet(part)
                if not cached then
                    -- Save original
                    local original = {
                        Material = part.Material,
                        Transparency = part.Transparency
                    }
                    
                    -- Apply optimization
                    if preset.CharacterOptimization then
                        part.Material = Enum.Material.Plastic
                        if self.Config.AggressiveMode then
                            part.Transparency = 1
                        end
                    end
                    
                    -- Cache
                    self:CacheSet(part, original, {
                        Material = part.Material,
                        Transparency = part.Transparency
                    })
                end
            end
        end
    end
    
    return #characters
end

--// Optimizer: Accessories
function Optimizer:OptimizeAccessories()
    local preset = self.Presets[self.Config.CurrentPreset]
    if not preset or not preset.AccessoryOptimization then return end
    
    local accessories = self.Scanner.Categories.Accessory
    
    for _, accessory in ipairs(accessories) do
        local handle = accessory:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            -- Check cache
            local cached = self:CacheGet(handle)
            if not cached then
                -- Save original
                local original = {
                    Material = handle.Material,
                    Transparency = handle.Transparency
                }
                
                -- Apply optimization
                if preset.AccessoryOptimization then
                    handle.Material = Enum.Material.Plastic
                    if self.Config.AggressiveMode then
                        handle.Transparency = 1
                    end
                end
                
                -- Cache
                self:CacheSet(handle, original, {
                    Material = handle.Material,
                    Transparency = handle.Transparency
                })
            end
        end
    end
    
    return #accessories
end

--// Adaptive Optimizer
Optimizer.Adaptive = {
    Level = 0, -- 0: None, 1: Light, 2: Medium, 3: Heavy, 4: Aggressive
    LastChange = 0,
    Cooldown = 5 -- Seconds
}

function Optimizer:UpdateAdaptive()
    local currentTime = tick()
    local fps = self.Performance.AverageFPS
    
    -- Add to history
    table.insert(self.Config.FrameHistory, fps)
    if #self.Config.FrameHistory > self.Config.HistorySize then
        table.remove(self.Config.FrameHistory, 1)
    end
    
    -- Check if we should adjust
    if currentTime - self.Adaptive.LastChange > self.Adaptive.Cooldown then
        if fps < self.Config.TargetFPS - 5 then
            -- FPS is low, increase optimization
            if self.Adaptive.Level < 4 then
                self.Adaptive.Level = self.Adaptive.Level + 1
                self:ApplyAdaptiveLevel(self.Adaptive.Level)
                self.Adaptive.LastChange = currentTime
                if self.Config.DebugMode then
                    print(string.format("[Optimizer] Adaptive: Increased to level %d (Avg FPS: %.1f)", 
                        self.Adaptive.Level, fps))
                end
            end
        elseif fps > self.Config.TargetFPS + 5 then
            -- FPS is high, decrease optimization
            if self.Adaptive.Level > 0 then
                self.Adaptive.Level = self.Adaptive.Level - 1
                self:ApplyAdaptiveLevel(self.Adaptive.Level)
                self.Adaptive.LastChange = currentTime
                if self.Config.DebugMode then
                    print(string.format("[Optimizer] Adaptive: Decreased to level %d (Avg FPS: %.1f)", 
                        self.Adaptive.Level, fps))
                end
            end
        end
    end
end

function Optimizer:ApplyAdaptiveLevel(level)
    -- Save current preset
    local currentPreset = self.Config.CurrentPreset
    
    -- Apply based on level
    if level == 0 then
        self.Config.CurrentPreset = "Default"
    elseif level == 1 then
        self.Config.CurrentPreset = "Balanced"
    elseif level == 2 then
        self.Config.CurrentPreset = "Performance"
    elseif level == 3 then
        self.Config.CurrentPreset = "Low"
    elseif level == 4 then
        self.Config.CurrentPreset = "UltraPotato"
    end
    
    -- Reapply optimizations
    if self.Config.AutoOptimize then
        self:OptimizeAll()
    end
end

--// Main Optimize Function
function Optimizer:OptimizeAll()
    local startTime = tick()
    local results = {}
    
    -- Apply all optimizations
    results.textures = self:OptimizeTextures()
    results.meshes = self:OptimizeMeshes()
    results.lighting = self:OptimizeLighting()
    results.particles = self:OptimizeParticles()
    results.characters = self:OptimizeCharacters()
    results.accessories = self:OptimizeAccessories()
    
    local endTime = tick()
    local totalTime = (endTime - startTime) * 1000
    
    if self.Config.DebugMode then
        print(string.format("[Optimizer] Optimization completed in %.2f ms", totalTime))
        for category, count in pairs(results) do
            print(string.format("  - %s: %d instances", category, count))
        end
    end
    
    return results
end

--// Restore System
function Optimizer:RestoreAll()
    local startTime = tick()
    local count = 0
    
    for instance, cacheData in pairs(self.Cache.Objects) do
        if instance and instance.Parent then
            -- Restore original properties
            for prop, value in pairs(cacheData.original) do
                pcall(function()
                    instance[prop] = value
                end)
            end
            count = count + 1
        end
    end
    
    -- Clear cache
    self:CacheClear()
    
    local restoreTime = (tick() - startTime) * 1000
    
    if self.Config.DebugMode then
        print(string.format("[Optimizer] Restored %d instances in %.2f ms", count, restoreTime))
    end
    
    return count
end

--// UI System
Optimizer.UI = {}

function Optimizer:CreateUI()
    if not self.Config.UIEnabled then return end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OptimizerUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.25, 0, 0.4, 0)
    mainFrame.Position = UDim2.new(self.Config.UIPosition.X, 0, self.Config.UIPosition.Y, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.3
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.15, 0)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    title.Text = "⚡ Roblox Optimizer"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Parent = mainFrame
    
    -- FPS Display
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
    fpsLabel.Position = UDim2.new(0, 0, 0.2, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 60"
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    fpsLabel.TextSize = 12
    fpsLabel.Parent = mainFrame
    
    -- Frame Time Display
    local frameTimeLabel = Instance.new("TextLabel")
    frameTimeLabel.Name = "FrameTimeLabel"
    frameTimeLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
    frameTimeLabel.Position = UDim2.new(0.5, 0, 0.2, 0)
    frameTimeLabel.BackgroundTransparency = 1
    frameTimeLabel.Text = "FT: 16.67ms"
    frameTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    frameTimeLabel.TextSize = 12
    frameTimeLabel.Parent = mainFrame
    
    -- Preset Dropdown
    local presetLabel = Instance.new("TextLabel")
    presetLabel.Name = "PresetLabel"
    presetLabel.Size = UDim2.new(1, 0, 0.1, 0)
    presetLabel.Position = UDim2.new(0, 0, 0.35, 0)
    presetLabel.BackgroundTransparency = 1
    presetLabel.Text = "Preset: Balanced"
    presetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    presetLabel.TextSize = 12
    presetLabel.Parent = mainFrame
    
    -- Buttons
    local optimizeButton = Instance.new("TextButton")
    optimizeButton.Name = "OptimizeButton"
    optimizeButton.Size = UDim2.new(0.48, 0, 0.15, 0)
    optimizeButton.Position = UDim2.new(0, 0, 0.5, 0)
    optimizeButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    optimizeButton.Text = "⚡ Optimize"
    optimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    optimizeButton.TextSize = 12
    optimizeButton.Parent = mainFrame
    
    local restoreButton = Instance.new("TextButton")
    restoreButton.Name = "RestoreButton"
    restoreButton.Size = UDim2.new(0.48, 0, 0.15, 0)
    restoreButton.Position = UDim2.new(0.52, 0, 0.5, 0)
    restoreButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    restoreButton.Text = "🔄 Restore"
    restoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    restoreButton.TextSize = 12
    restoreButton.Parent = mainFrame
    
    -- Preset Selection
    local presetFrame = Instance.new("Frame")
    presetFrame.Name = "PresetFrame"
    presetFrame.Size = UDim2.new(1, 0, 0.3, 0)
    presetFrame.Position = UDim2.new(0, 0, 0.7, 0)
    presetFrame.BackgroundTransparency = 1
    presetFrame.Parent = mainFrame
    
    -- Preset Buttons
    local presets = {"Default", "Balanced", "Performance", "Low", "UltraPotato"}
    for i, presetName in ipairs(presets) do
        local button = Instance.new("TextButton")
        button.Name = presetName .. "Button"
        button.Size = UDim2.new(0.18, 0, 0.8, 0)
        button.Position = UDim2.new((i-1) * 0.2, 0, 0.1, 0)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.Text = presetName
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 10
        button.Parent = presetFrame
        
        button.MouseButton1Click:Connect(function()
            self.Config.CurrentPreset = presetName
            self:OptimizeAll()
        end)
    end
    
    -- Store UI references
    self.UI.MainFrame = mainFrame
    self.UI.FPSLabel = fpsLabel
    self.UI.FrameTimeLabel = frameTimeLabel
    self.UI.PresetLabel = presetLabel
    
    -- Connect buttons
    optimizeButton.MouseButton1Click:Connect(function()
        self:OptimizeAll()
    end)
    
    restoreButton.MouseButton1Click:Connect(function()
        self:RestoreAll()
    end)
    
    -- Make draggable
    self:MakeDraggable(mainFrame, title)
    
    -- Update UI in loop
    task.spawn(function()
        while true do
            self:UpdateUI()
            task.wait(0.1)
        end
    end)
    
    return screenGui
end

function Optimizer:UpdateUI()
    if not self.UI.FPSLabel then return end
    
    -- Update FPS
    self.UI.FPSLabel.Text = string.format("FPS: %.1f", self.Performance.FPS)
    if self.Performance.FPS >= 50 then
        self.UI.FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    elseif self.Performance.FPS >= 30 then
        self.UI.FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    else
        self.UI.FPSLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
    
    -- Update Frame Time
    self.UI.FrameTimeLabel.Text = string.format("FT: %.2fms", self.Performance.FrameTime)
    
    -- Update Preset
    self.UI.PresetLabel.Text = "Preset: " .. self.Config.CurrentPreset
    
    -- Update Adaptive Level
    if self.Config.AutoOptimize then
        self.UI.PresetLabel.Text = self.UI.PresetLabel.Text .. " (Auto: " .. self.Adaptive.Level .. ")"
    end
end

function Optimizer:MakeDraggable(draggable, handle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = draggable.Position
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            draggable.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// New Object Handler
function Optimizer:HandleNewObjects()
    -- Listen for new descendants
    workspace.DescendantAdded:Connect(function(instance)
        -- Only process if it's a visual object
        if instance:IsA("BasePart") or instance:IsA("Texture") or instance:IsA("Decal") or
           instance:IsA("ParticleEmitter") or instance:IsA("MeshPart") then
            
            -- Check if optimization is aggressive
            if self.Config.AggressiveMode or self.Config.AutoOptimize then
                -- Process immediately if aggressive
                task.spawn(function()
                    -- Wait a frame for instance to be fully added
                    RunService.Heartbeat:Wait()
                    
                    if instance.Parent then
                        self:ProcessInstance(instance)
                        self:OptimizeInstance(instance)
                    end
                end)
            else
                -- Queue for next scan
                table.insert(self.Scanner.Categories.BasePart, instance)
            end
        end
    end)
end

function Optimizer:OptimizeInstance(instance)
    local preset = self.Presets[self.Config.CurrentPreset]
    if not preset then return end
    
    -- Optimize based on type
    if instance:IsA("Texture") or instance:IsA("Decal") then
        if preset.TextureQuality <= 0.1 then
            instance.Transparency = 1
            instance.Visible = false
        end
    elseif instance:IsA("MeshPart") then
        if preset.MeshLOD <= 0 then
            instance.RenderFidelity = Enum.RenderFidelity.Performance
        end
    elseif instance:IsA("ParticleEmitter") then
        if preset.ParticleRate <= 0.1 then
            instance.Enabled = false
        end
    elseif instance:IsA("BasePart") then
        if preset.CharacterOptimization then
            instance.Material = Enum.Material.Plastic
        end
    end
end

--// Main Loop
function Optimizer:Start()
    -- Initialize
    self:MonitorPerformance()
    
    -- Initial scan
    self:ScanWorkspace()
    
    -- Apply initial optimization
    if self.Config.AutoOptimize then
        self:OptimizeAll()
    end
    
    -- Create UI
    if self.Config.UIEnabled then
        self:CreateUI()
    end
    
    -- Handle new objects
    self:HandleNewObjects()
    
    -- Main loop
    task.spawn(function()
        while true do
            -- Update adaptive optimizer
            self:UpdateAdaptive()
            
            -- Periodic scan
            if tick() - self.Scanner.LastScan > self.Config.ScanInterval then
                if self.Config.AggressiveMode or self.Config.AutoOptimize then
                    self:ScanWorkspace()
                end
            end
            
            task.wait(1) -- 1 second interval
        end
    end)
    
    -- Auto-restore on leave
    Players.LocalPlayer.OnRemove:Connect(function()
        self:RestoreAll()
    end)
    
    -- Bind to game leaving
    game:BindToClose(function()
        self:RestoreAll()
    end)
    
    print("[Optimizer] Roblox FPS/Graphics Optimizer started!")
    print("[Optimizer] Target FPS: " .. self.Config.TargetFPS)
    print("[Optimizer] Current Preset: " .. self.Config.CurrentPreset)
    
    return self
end

--// Initialize
return Optimizer:Start()
