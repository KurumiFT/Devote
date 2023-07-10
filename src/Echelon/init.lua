type Echelon = {
    Setup : (Echelon, props : {[string] : any}) -> Echelon,
    new : (className : string) -> Echelon,
    from : (instance : Instance, shouldClone : boolean?) -> Echelon,
    Destroy : (Echelon) -> (),
    Debris : (Echelon, time : number) -> (),
    Tween : (Echelon, tweenInfo : TweenInfo, target : {[string] : any}, shouldStart : boolean?) -> Tween
}

--[=[
    @prop Instance Instance
    @within Echelon
    @private

    Main property of `Echelon` object, that contain your instance
    :::warning 
        Don't get this, if you don't want to accidentally broke the Echelon :)
        Better use Indexing to the Instance props through Echelon
    :::
]=]

--[=[
    @prop Maid Maid
    @within Echelon
    @private

    Contain all Garbage from Echelon as Tweens and Childs
]=]

--[=[
    @prop CacheInfo {[string] : any}?
    @within Echelon
    @private

    Contain information about linking the echelon to the cache
]=]

--[=[
    @type CacheSection { Basis : Instance, ID : number, TTL : number, Used : number, Childs : {Instance} }
    @within Echelon
    @private    

    The type that section in the cache are represented by
]=]

--[=[
    @class Echelon
    Component for easier, safer and more convenient work with Instance
]=]
local Echelon = {}
local Cache = {}

local TweenService = game:FindService("TweenService")

local Maid = require(script.Parent.Maid)

--[=[
    @function __index
    @param index string
    @return ((...any) -> (...any)) | Echelon | any
    @within Echelon

    Return Echelon's method if it exist or [Instance's](#instance) child as new Echelon or instance prop
    
    :::tip
        Use it for getting your instance property / child, don't get instance from Echelon by yourself!
    :::

    ```lua
    local VFXAsset = ...

    local myEon = Echelon.from(VFXAsset, true)
    myEon:Setup(...) -- Get Echelon's method
    print(myEon.Transparency) -- Get Transparency prop from instance
    myEon.ParticleEmitter:Setup({Rate = 50}) -- Get VFXAsset child and setup it
    ```
]=]
Echelon.__index = function(self, index : any)
    if self.Destroyed then error('Echelon is destroyed!', 2) end

    if Echelon[index] then return Echelon[index] end
    local child : Instance? = self.Instance:FindFirstChild(index) or (if typeof(index) == 'Instance' and self.Instance:IsAncestorOf(index) then index else nil)
    if child then -- Check if instance have child
        local childsSection = self.Maid:Extend('Childs')
        if childsSection[child] then return childsSection[child] end
        
        local childEchelon = Echelon.from(child)
        childsSection[child] = childEchelon
        return childEchelon
    end

    return self.Instance[index] -- Return instance prop
end

Echelon.__tostring = function(self)
    if self.Destroyed then return nil end
    return self.Instance.ClassName
end

--[=[
    Return new `Echelon` object from ClassName

    ```lua
    local myEon = Echelon.new('Part')
    ```
]=]
function Echelon.new(className : string ) : Echelon
    local _instance = Instance.new(className)
    return Echelon.from(_instance)
end

--[=[
    @param instance Instance
    @param shouldClone boolean? -- Should given instance be cloned
    @param cacheInfo {[string] : any}? -- Private field

    Return new `Echelon` object from exist Instance (*wrapping*)  
    If you use asset that should be cloned, then set `true` in second argument
    ```lua
    local Asset = ReplicatedStorage.FireballAsset
    local myEon = Echelon.from(Asset, true):Setup({Parent = workspace})
    ```
]=]
function Echelon.from(instance : Instance, shouldClone : boolean?, cacheInfo : {[string] : any}?) : Echelon
    return setmetatable({
        Destroyed = false,
        Instance = if shouldClone then instance:Clone() else instance,
        Maid = Maid.new(),
        CacheInfo = cacheInfo
    }, Echelon)
end

--[=[
    Set properties for Echelon's instance

    :::info
        This method safely sets the parent only after all properties have been set.
        Don't use standart "Instance.new('Part', workspace)"
        Setting the parent before the set properties triggers a lot of "Changed" events!
    :::

    ```lua
    local myEon = Echelon.new('Part'):Setup({Name = 'MyPart', Parent = workspace})
    ```
]=]
function Echelon:Setup(props : { [string] : any }) : Echelon
    local parent = self.Instance.Parent
    
    for key : string, prop : any in pairs(props) do
        if key == 'Parent' then parent = prop; continue end
        self.Instance[key] = prop
    end

    self.Instance.Parent = parent

    return self
end

--[=[
    @param tweenInfo TweenInfo
    @param target {[any] : any} -- Tween's target props
    @param shouldStart boolean? -- Should start tween immediately

    Create tween for Echelon's instance
    ```lua
    local myEon = Echelon.from(Part)
    myEon:Tween(TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = .5}, true) -- Create and start tween
    ```

    :::tip
        Prefer to use this instead TweenService:Create(...) cause that safely for caching instance
    :::
]=]
function Echelon:Tween(tweenInfo : TweenInfo, target : {[any] : any}, shouldStart : boolean?) : Tween
    local tweenTrack = TweenService:Create(self.instance, tweenInfo, target)
    self.Maid:Extend('Tween'):Add(tweenTrack)

    if shouldStart then tweenTrack:Play() end
    return tweenTrack
end

--[=[
    @private
    Return Instance prop
]=]
function Echelon:_getInstance() : Instance
    return self.Instance
end

--[=[
    @param key string -- Key for cache section
    @param instance Instance | Echelon -- Target instance that should be cached
    @param intial_size number? -- Intial size of cache | Default 0
    @param ttl number? -- Time to live | Default nil

    Assigns an Instance to a Cache Section by key  
    When an instance is cached, it is automatically cloned  
    Don't clone an asset when caching, this can cause undefined behavior.  

    When caching, the object is cloned `intial_size` times, which avoids cloning at times when performance is needed  
    `ttl` - determines when an object is removed from the cache if it is not used for a given amount of time (in seconds).  
    `0 | nil` - the object will be returned and remain in the cache until it is explicitly removed from there
    ```lua
    Echelon.cache('Fireball', Fireball_Asset, 10, 30) -- Cache fireball assets with 10 clones at once and TTL = 30
    local myPart = Echelon.new('Part'):Setup({Anchored = true, Transparency = .5})
    Echelon.cache('MyPart', myPart, 40) -- Cache created part with 40 clones at once without lifetime limit
    ```

    :::tip
        Cached object is the basis and all new objects in the current cache section will be its clones
        Use caching for frequently used objects, for example lasers / vfx, etc
    :::

    :::warning
        If you use an already existing key, the cache will be overwritten and already existing objects will be deleted
    :::
]=]
function Echelon.cache(key : string, instance : Instance | Echelon, intial_size : number?, ttl : number?) : nil
    local newSection = {
        Basis = (if typeof(instance) == 'Instance' then instance:Clone() else instance:_getInstance():Clone() ),
        ID = tick(),
        TTL = (if not ttl then 0 else ttl),
        Childs = {}
    }

    if not Cache[key] then
        Cache[key] = newSection
    else
        Cache[key].Basis:Destroy()
        for _, v in ipairs(Cache[key].Childs) do
            v:Destroy()
        end

        Cache[key] = newSection
    end
end

function Echelon:GetChildren()
    local childs = {}

    for _, child in ipairs(self.Instance:GetChildren()) do
        table.insert(childs, self[child])
    end

    return childs
end

--[=[
    Safely destroy Echelon with all instances

    ```lua
    local myEon = Echelon.new('Part')
    myEon:Destroy() -- Destroy myEon object
    myEon:Setup({...}) -- ERROR!
    ```
]=]
function Echelon:Destroy()
    self.Instance:Destroy()
    self.Maid:Destroy()

    self.Destroyed = true
end

--[=[
    Improved version of `Debris:AddItem(Instance)`, that can working with caching

    ```lua
    local myEon = Echelon.fromCache('VFX'):Setup({CFrame = CFrame.new(0, 0, 0), Parent = workspace})
    myEon:Tween(TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 1}, true)
    myEon:Debris(1)
    ```
]=]
function Echelon:Debris(time : number)
    task.delay(time, function()
        if self.Destroyed then return end

        self:Destroy()
    end)
end

return Echelon