-- deferHdl

rsbIn = {read_done=1,sys_test=2,sys_on=4,s5_torches=8,s3_cargo2=16,lime=32,
		 s6_bridge=64,gray=128,lightgray=256,depart_stateok=512,departure=1024,
		 s2_cargo1=2048,s4_rails=4096,arrival=8192,s1_carttype=16384, downhill=32768}
		 
rsbOut ={rs_general=1,send_derailer=2,sys_test=4,unload=8,sw_cartpark=16,lime=32,
		 sys_fault=64,gray=128,lightgray=256,rs_fuel=512,send_miner=1024,
		 rs_rails=2048,sensor_reset=4096,sys_running=8192,sw_mine=16384, sys_stop=32768}


local _Event_t = {name="", p1="", p2="", p3="", p4=""}

local __Timer = "timer"
local __Redstone = "redstone"

function nilHandleF()
	print("nil handler")
end

local __IDLE = 1
local __RUNNING = 2

local deferHandlers = {}
deferHandlers[__IDLE] = 
			{name = "Idle", 
				handlerF = nilHandleF,
				self = -1,
				events={__Timer},
				mask1=rsbIn.sys_test+rsbIn.sys_on, 
				mask2=65535-rsbOut.send_miner-rsbOut.send_derailer,
				mask3=0,
				mask4=0,
				mask5=0, 
				mask6=0
			}
deferHandlers[__RUNNING] = 
			{name = "Running", 
				handlerF = nilHandleF,
				self = -1,
				events={__Redstone},
				mask1=rsbIn.sys_test+rsbIn.sys_on, 
				mask2=65535-rsbOut.send_miner-rsbOut.send_derailer,
				mask3=0,
				mask4=0,
				mask5=0, 
				mask6=0
			}

deferHandlers[__IDLE].handlerF = function (Hdl, EventT)
	event = deferHandle.EventClearEvent(EventT, Hdl.events)
	print("Idle_F")
	print("Handling event:"..event)
end

deferHandlers[__RUNNING].handlerF = function (Hdl, EventT)
	event = deferHandle.EventClearEvent(EventT, Hdl.events)
	print("Running")
	print("Handling event:"..event)
end
	
deferHandle = {} 

function deferHandle.init()
	return {}
end

function deferHandle.add(Hdl, Handler)
	table.insert(Hdl, Handler)
	Handler.self = # Hdl
end

function deferHandle.remove(Hdl, Handler)
	table.remove(Hdl, Handler.self)
end

function dPrint(str)
	print(str)
end

function deferHandle.handle(Hdl, EventT)
	dPrint("deferHandler running...sz="..#EventT)
	local EvTSz = 0
	local HandleComplete = false
	local HandlingEvents = true
	
	while HandlingEvents do
		for Idx, newevent in ipairs(EventT) do
			if HandleComplete then break end
			for HdlIdx, Handler in ipairs(Hdl) do
				if HandleComplete then break end
				dPrint("Checking"..Handler.name)
				for EvIdx, event in pairs(Handler.events) do
					dPrint(event..":"..newevent)
					if event == newevent then
						dPrint("Matched event: "..event.." for handler: "..Handler.name)
						Handler.handlerF(Handler, EventT)
						HandleComplete = true
						break
					end
				end
			end
		end
		if HandleComplete then
			HandleComplete = false
		else
			HandlingEvents = false
		end
	end
	
end

function deferHandle.EventClearEvent(NewEventT, MaskEventsT)
	for TIdx, newevent in pairs(NewEventT) do
		dPrint(TIdx..":"..newevent)
		for Idx, event in pairs(MaskEventsT) do
			dPrint(Idx..":"..event)
			if event == newevent then
				table.remove(NewEventT, TIdx)
				return event
			end
		end
	end
	return nil
end


function Main()
	print("deferhandle test")
	local dH = deferHandle.init()
	
	for Idx, Handler in ipairs(deferHandlers) do
		deferHandle.add(dH, deferHandlers[Idx])
	end
	--deferHandle.add(dH, deferHandlers[__RUNNING])
	
	local eventT = {__Timer, __Redstone}
	
	deferHandle.handle(dH, eventT)
	deferHandle.handle(dH, eventT)
	deferHandle.handle(dH, eventT)
	eventT = {__Timer, __Redstone}
	deferHandle.handle(dH, eventT)
	deferHandle.handle(dH, eventT)
	
end

Main()

