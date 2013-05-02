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

local __IDLE = 1
local __RUNNING = 2
local __STATE1 = 3

local deferHandlers = {}
deferHandlers[__IDLE] = 
			{name = "Idle", 
				handlerF = nilHandleF,
				self = -1,
				events={__Timer, __Char},
				masks={{en=false,param="left",mask=nil}, 
					   {en=false,param="right",mask=nil},
				       {en=false,param="top",mask=nil},
				  	   {en=false,param="back",mask=nil},
				       {en=false,param="bottom",mask=nil},
				       {en=false,param="front",mask=nil}}
			}
deferHandlers[__RUNNING] = 
			{name = "Running", 
				handlerF = nilHandleF,
				self = -1,
				events={__Redstone},
				masks={{en=true,param="left",mask=rsbIn.sys_on}}
			}
deferHandlers[__STATE1] = 
			{name = "State1", 
				handlerF = nilHandleF,
				self = -1,
				events={__Redstone},
				masks={{en=true,param="left",mask=rsbIn.arrival}}
			}

deferHandlers[__IDLE].handlerF = function (dH, Handler, EventT)
	deferHandle.clearevent(EventT)
	print(Handler.name.." Handling event:"..EventT.name)
end

deferHandlers[__RUNNING].handlerF = function (dH, Handler, EventT)
	deferHandle.clearevent(EventT)
	print(Handler.name.." Handling event:"..EventT.name..EventT.p1..EventT.p2)
	deferHandle.remove(dH, Handler)
	deferHandle.add(dH, deferHandlers[__STATE1])
end

deferHandlers[__STATE1].handlerF = function (dH, Handler, EventT)
	deferHandle.clearevent(EventT)
	print(Handler.name.." Handling event:"..EventT.name..EventT.p1..EventT.p2)
end

function Test_MaskHandleF(param)
	print("Mask handleF: "..param)
	return rsbIn.sys_on
end

function Main()
	print("deferhandle test")
	local dH = deferHandle.init()
	
	deferHandle.setMaskHandler(dH, Test_MaskHandleF, __Redstone)
	
	deferHandle.add(dH, deferHandlers[__IDLE])
	deferHandle.add(dH, deferHandlers[__RUNNING])
	
	deferHandle.handle(dH, deferHandle.newevent(__Timer))
	deferHandle.handle(dH, deferHandle.newevent(__Redstone,1,2))
	deferHandle.handle(dH, deferHandle.newevent(__Timer))
	deferHandle.handle(dH, deferHandle.newevent(__Redstone,1,2))
	deferHandle.handle(dH, deferHandle.newevent(__Char))
	deferHandle.handle(dH, deferHandle.newevent(__Rednet,1,2))

	deferHandle.handle(dH, deferHandle.newevent(__Timer))
	deferHandle.handle(dH, deferHandle.newevent(__Timer))
	
end

Main()
