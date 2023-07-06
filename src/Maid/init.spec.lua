return function ()
    local Maid = require(script.Parent)

    describe('create Maid', function()
        it('should have .new method', function()
            local _maid = Maid.new()
        end)

        it('should return object', function()
            local _maid = Maid.new()
            expect(_maid).to.be.ok()
        end)
    end)

    describe('adding Garbage', function()
        it('should added by __newindex', function()
            local _maid = Maid.new()
            
            local mock = newproxy(false)
            _maid['Mock'] = mock

            expect(_maid['Mock']).to.equal(mock)
        end)

        it('should added by :Add', function()
            local _maid = Maid.new()

            local mock = newproxy(false)
            _maid:Add(mock)

            expect(_maid.Closet[1]).to.equal(mock)
        end)
    end)

    describe('remove Garbage', function()
        local _maid, _table
        _table = { Destroy = function()
            _table.Destroyed = true
        end }

        beforeEach(function()
            _maid = Maid.new()
            _table.Destroyed = false 
        end)

        it('should remove by :Clean / :Destroy', function()
            _maid:Add(_table)

            _maid:Clean()

            expect(_table.Destroyed).to.equal(true)
            expect(#_maid.Closet).to.equal(0)
        end)

        it('should remove by __newindex on nil', function()
            _maid['Mock'] = _table
            _maid['Mock'] = nil
            
            expect(_table.Destroyed).to.equal(true)
        end)
    end)
end