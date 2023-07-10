type Maid = {
    Destroy : () -> (),
    Add : (...Garbage) -> ...Garbage,
    Clean : () -> ()
}

--[=[
    @type Garbage Instance | table | RBXScriptConnection
    @within Maid

    #### Type of objects that contains in `Closet`
    Table used as `Garbage` should implement `Destroy` method

    ```lua
    -- Requires
    local Signal = require(Packages.Signal)

    local myMaid = Maid.new()
    local mySignal = myMaid:Add(Signal.new()) -- Signal implement Destroy method
    ```
]=]
type Garbage = Instance | table | RBXScriptConnection

--[=[
    @prop Closet { [any] : Garbage }
    @within Maid
    @private

    Store all garbage in `Maid` object
]=]

--[=[
    @prop Sub { [string | number] : Maid }
    @within Maid
    @private

    Store all sub maids in `Maid` object  
    Get sub maid only by using ":Extend(index)"
]=]

--[=[ 
    @class Maid
    Component for preventing memory leaks
]=]
local Maid = {}
local function getCleanUpMethod(object : Garbage)
    local objectType = typeof(object)

    if objectType == 'Instance' or objectType == 'table' then return 'Destroy' end
    if objectType == 'function' then return end
    if objectType == 'RBXScriptConnection' then return 'Disconnect' end

    return 'Destroy'
end

local function cleanUp(object : Garbage)
    local cleanUp = getCleanUpMethod(object)

    if cleanUp then object[cleanUp]()
    else object() end
end

--[=[
    @function __index
    @param index any
    @return ((...any) -> (...any)) | Garbage?
    @within Maid

    Return Maid's method if exist or object from `Closet` by given index *(could be nil)*
]=]
Maid.__index = function(self, index)
    if Maid[index] then return Maid[index] end

    return self.Closet[index]
end

--[=[ 
    @function __newindex
    @param index any
    @param value Garbage?
    @within Maid

    You can add items into Maid by setting value on index
     
    :::tip
       Use this for frequently used instances, for example: Signal, UI...
    :::

    ```lua
    self.myMaid = Maid.new()
    self.myMaid['Frame'] = Frame -- Attach Frame to Maid

    -- In other function
    if self.myMaid['Frame'] then
        self.myMaid['Frame'].BackgroundTransparency = 1
        ...
    end
     ```
]=]
Maid.__newindex = function(self, index, value)
    if self.Closet[index] then
        cleanUp(self.Closet[index])
    end

    self.Closet[index] = value
end

--[=[
    Return new `Maid` object

    ```lua
    local myMaid = Maid.new()
    ```
]=]
function Maid.new(... : Garbage?) : Maid
    return setmetatable({
        Closet = {...},
        Sub = {}, --* Sub maids
    }, Maid)
end

--[=[
    Extend Maid by creating sub-maid  
    If Sub-Maid on index is exist then return it else create new and return
    :::warning
        Use :Extend only using index binding (set index)  
        Else you can create a lot of sub-maids and get performance issues due to floating objects
    :::

    ```lua
    local myMaid = Maid.new()
    local tweensMaid = Maid:Extend('Tweens')

    tweensMaid:Add(someTween)
    --...
    myMaid:Clean() -- Will clean all tweens in 'Tweens' sub-maid, but don't remove this

    --In other part of script
    local simillaryTweensMaid = Maid:Extend('Tweens') -- Here i get already exist 'Tweens' sub-maid
    ```
]=]
function Maid:Extend(index : string?) : Maid
    local returnableMaid
    if index then
        if not self.Sub[index] then
            self.Sub[index] = Maid.new()
        end
        returnableMaid = self.Sub[index]
    else
        returnableMaid = Maid.new()
        table.insert(self.Sub, returnableMaid)
    end

    return returnableMaid
end

--[=[
    Push Garbage into Maid

    ```lua
    local vfxPart = Instance.new('Part')
    -- TODO

    myMaid:Add(vfxPart)
    ```

    :::note
        Don't forget that you can push multiple garbage in one call
    :::
]=]
function Maid:Add(... : Garbage) : ...Garbage
    for _, v in ipairs({...}) do
       table.insert(self.Closet, v) 
    end

    return ...
end

--[=[
   Clean Maid from Garbage

    ```lua
    local myMaid = Maid.new()
    myMaid['testInstance'] = Instance.new('Part')
        
    print(myMaid['testInstance']) -- Part

    myMaid:Destroy()

    print(myMaid['testInstance']) -- nil
    ```
]=]
function Maid:Destroy()
    -- Clear closet
    for _, v in pairs(self.Closet) do
        cleanUp(v)
    end

    self.Closet = {}

    -- Call `Destroy` method for every sub maid and then clear table 
    for _, v in pairs(self.Sub) do
        v:Destroy()
    end

    self.Sub = {}
end

--[=[
    *Allias of `Maid:Destroy()`*

    ```lua
    local myMaid = Maid.new()
    myMaid['testInstance'] = Instance.new('Part')
        
    print(myMaid['testInstance']) -- Part

    myMaid:Clean()

    print(myMaid['testInstance']) -- nil
    ```
]=]
function Maid:Clean()
    self:Destroy()
end

return Maid