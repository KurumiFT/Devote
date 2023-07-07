type Echelon = {

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

    Contain all Garbage from Echelon as Tweens and Instance 
]=]

--[=[
    @class Echelon
    Component for easier, safer and more convenient work with Instance
]=]
local Echelon = {}

local TweenService = game:FindService("TweenService")

local Maid = require(script.Parent.Maid)

--[=[
    @function __index
    @param index string
    @return ((...any) -> (...any)) | any
    @within Echelon

    Return Echelon's method or [Instance's](#instance) property / child if Echelon don't have it
    
    :::tip
        Use it for getting your instance property, don't get instance by yourself!
    :::

    ```lua
    local myEon = Echelon.new('Part')
    myEon:Setup(...) -- Get Echelon's method
    print(myEon.Transparency) -- Get Transparency prop from instance
    ```
]=]
Echelon.__index = function(self, index : any)
    if Echelon[index] then return Echelon[index] end
    return self.instance[index]
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
    @param shouldClone boolean -- Should given instance be cloned

    Return new `Echelon` object from exist Instance  
    <br/>If you use asset that should be cloned, then set `true` in second argument
    ```lua
    local Asset = ReplicatedStorage.FireballAsset
    local myEon = Echelon.from(Asset, true):Setup({Parent = workspace})
    ```
]=]
function Echelon.from(instance : Instance, shouldClone : boolean) : Echelon
    return setmetatable({
        Instance = if shouldClone then instance:Clone() else instance,
        Maid = Maid.new()
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
    local parent = self.instance.Parent
    
    for key : string, prop : any in pairs(props) do
        if key == 'Parent ' then parent = prop; continue end
        self.instance[key] = prop
    end

    self.instance.Parent = parent

    return self
end

--[=[
    @param tweenInfo TweenInfo
    @param target {[any] : any} -- Tween's target props
    @param shouldStart boolean -- Should start tween immediately

    Create tween for Echelon's instance
    ```lua
    local myEon = Echelon.from(Part)
    myEon:Tween(TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = .5}, true) -- Create and start tween
    ```

    :::tip
        Prefer to use this instead TweenService:Create(...) cause that safely for caching instance
    :::
]=]
function Echelon:Tween(tweenInfo : TweenInfo, target : {[any] : any}, shouldStart : boolean) : Tween
    local tweenTrack = TweenService:Create(self.instance, tweenInfo, target)
    
    if self.Maid['Tween'] then
        self.Maid['Tween']:Add(tweenTrack)
    else
        self.Maid['Tween'] = Maid.new(tweenTrack)
    end

    if shouldStart then tweenTrack:Play() end
    return tweenTrack
end


