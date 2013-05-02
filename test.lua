--[[ test
]]

if type(bit) == 'nil' then
	print("loading bit")
	package.path = 'lmod\\?.lua;' .. package.path
	bit = require 'bit.numberlua'
end

--package.path = '\?.lua;' .. package.path
local deferHandle = require 'deferHdl'


local rsbIn = {read_done=1,sys_test=2,sys_on=4,s5_torches=8,s3_cargo2=16,lime=32,
		 s6_bridge=64,gray=128,lightgray=256,depart_stateok=512,departure=1024,
		 s2_cargo1=2048,s4_rails=4096,arrival=8192,s1_carttype=16384, downhill=32768}
		 
local rsbOut ={rs_general=1,send_derailer=2,sys_test=4,unload=8,sw_cartpark=16,lime=32,
		 sys_fault=64,gray=128,lightgray=256,rs_fuel=512,send_miner=1024,
		 rs_rails=2048,sensor_reset=4096,sys_running=8192,sw_mine=16384, sys_stop=32768}

local __Timer = "timer"
local __Redstone = "redstone"
local __Char = "char"
local __Rednet = "rednet_message"

--local __IDLE = 1
--local __RUNNING = 2
--local __STATE1 = 3

local rsbStat = {}
rsbStat["left"] = {lastStatus=0}
rsbStat["right"] = {lastStatus=0}
rsbStat["top"] = {lastStatus=0}
rsbStat["back"] = {lastStatus=0}
rsbStat["bottom"] = {lastStatus=0}
rsbStat["front"] = {lastStatus=0}

local deferHandlers = {}
deferHandlers.Idle = 
			{name = "Idle", 
				handlerF = nil,
				selfIdx = -1,
				events={__Timer, __Char},
				masks={{en=false,param="left",status=nil, mask=nil}, 
					   {en=false,param="right",status=nil, mask=nil},
				       {en=false,param="top",status=nil, mask=nil},
				  	   {en=false,param="back",status=nil, mask=nil},
				       {en=false,param="bottom",status=nil, mask=nil},
				       {en=false,param="front",status=nil, mask=nil}}
			}
deferHandlers.Running = 
			{name = "Running", 
				handlerF = nil,
				selfIdx = -1,
				events={__Redstone},
				masks={{en=true,param="left",status=nil, mask=rsbIn.sys_on}}
			}
deferHandlers.State1 = 
			{name = "State1", 
				handlerF = nil,
				selfIdx = -1,
				events={__Redstone},
				masks={{en=true,param="left",status=nil, mask=rsbIn.sys_on}}
			}

deferHandlers.State2 = 
			{name = "State2", 
				handlerF = nil,
				selfIdx = -1,
				events={__Redstone},
				masks={{en=true,param="left",status=nil, mask=rsbIn.sys_on}}
			}

deferHandlers.Idle.handlerF = function (dH, Handler, EventT)
	deferHandle.clearevent(EventT)
	print(Handler.name.." Handling event:"..EventT.name)
end

deferHandlers.Running.handlerF = function (dH, Handler, EventT)
	deferHandle.clearevent(EventT)
	print(Handler.name.." Handling event:"..EventT.name..EventT.p1..EventT.p2)
	deferHandle.remove(dH, Handler)
	deferHandle.add(dH, deferHandlers.State1)
end

deferHandlers.State1.handlerF = function (dH, Handler, EventT)
	deferHandle.clearevent(EventT)
	print(Handler.name.." Handling event:"..EventT.name..EventT.p1..EventT.p2)
	deferHandle.remove(dH, Handler)
	deferHandle.add(dH, deferHandlers.State2)
end

deferHandlers.State2.handlerF = function (dH, Handler, EventT)
	deferHandle.clearevent(EventT)
	print(Handler.name.." Handling event:"..EventT.name..EventT.p1..EventT.p2)
end

function rsbStatusInit(deferHandlers)
	-- init all the masks to hold the proper status table
	for name,Handler in pairs(deferHandlers) do
		for MaskIdx, mask in ipairs(Handler.masks) do
			mask.status = rsbStat[mask.param]
		end
	end
end

local RsbInputVal=0

function rsbGetInput()
	return RsbInputVal
end

function Test_MaskHandleF(maskE)
	print("Mask handleF: "..maskE.param)

	local newstatus = rsbGetInput(maskE.param)
	local oldstatus = maskE.status.lastStatus
	print(newstatus..":"..oldstatus)
	local chgstatus = bit.bxor(newstatus,oldstatus)
	local maskcheck = bit.band(chgstatus, maskE.mask)
	maskE.status.lastStatus = newstatus
	return maskcheck ~= 0
end

function Main()
	print("deferhandle test")
	local dH = deferHandle.init()
	
	deferHandle.setMaskHandler(dH, Test_MaskHandleF, __Redstone)
	rsbStatusInit(deferHandlers)
	
	deferHandle.add(dH, deferHandlers.Idle)
	deferHandle.add(dH, deferHandlers.Running)
	
	RsbInputVal = rsbIn.sys_on
	deferHandle.handle(dH, deferHandle.newevent(__Timer))
	deferHandle.handle(dH, deferHandle.newevent(__Redstone,1,2))
	deferHandle.handle(dH, deferHandle.newevent(__Timer))
	deferHandle.handle(dH, deferHandle.newevent(__Redstone,1,2))
	deferHandle.handle(dH, deferHandle.newevent(__Char))
	deferHandle.handle(dH, deferHandle.newevent(__Rednet,1,2))
	RsbInputVal = 0
	deferHandle.handle(dH, deferHandle.newevent(__Redstone,1,2))

	deferHandle.handle(dH, deferHandle.newevent(__Timer))
	deferHandle.handle(dH, deferHandle.newevent(__Timer))
	
end

Main()

return