-- deferHdl

rsbIn = {read_done=1,sys_test=2,sys_on=4,s5_torches=8,s3_cargo2=16,lime=32,
		 s6_bridge=64,gray=128,lightgray=256,depart_stateok=512,departure=1024,
		 s2_cargo1=2048,s4_rails=4096,arrival=8192,s1_carttype=16384, downhill=32768}
		 
rsbOut ={rs_general=1,send_derailer=2,sys_test=4,unload=8,sw_cartpark=16,lime=32,
		 sys_fault=64,gray=128,lightgray=256,rs_fuel=512,send_miner=1024,
		 rs_rails=2048,sensor_reset=4096,sys_running=8192,sw_mine=16384, sys_stop=32768}


local Idle_F
local Running_F

local _Event_t = {name="", p1="", p2="", p3="", p4=""}

local deferHandles = {
			{name = "Idle", 
				handlerF = Idle_F,
				self = -1,
				events={timer},
				mask1=rsbIn.sys_test+rsbIn.sys_on, 
				mask2=65535-rsbOut.send_miner-rsbOut.send_derailer,
				mask3=0,
				mask4=0,
				mask5=0, 
				mask6=0
			},
			{name = "Running", 
				handlerF = Running_F,
				self = -1,
				events={timer},
				mask1=rsbIn.sys_test+rsbIn.sys_on, 
				mask2=65535-rsbOut.send_miner-rsbOut.send_derailer,
				mask3=0,
				mask4=0,
				mask5=0, 
				mask6=0
			},
		}

deferHandle = {} 

function deferHandle.init()
	return {first = 0, last = -1}
end

function deferHandle.pushleft (list, value)
    local first = list.first - 1
    list.first = first
	list[first] = value
end
    
function deferHandle.pushright (list, value)
    local last = list.last + 1
    list.last = last
	list[last] = value
end
    
function deferHandle.popleft (list)
    local first = list.first
    if first > list.last then return nil end
    local value = list[first]
    list[first] = nil        -- to allow garbage collection
    list.first = first + 1
	return value
end
    
function deferHandle.popright (list)
    local last = list.last
    if list.first > last then return nil end
    local value = list[last]
    list[last] = nil         -- to allow garbage collection
    list.last = last - 1
	return value
end
	
function deferHandle.add(Hdl, Handler)
	deferHandle.pushright(Hdl, Handler)
	Handler.self = Hdl.last
end

function deferHandleRemove(DeferHandle, Handler)
	table.remove(DeferHandle, Handler.self)
end

function deferHandlerHandle(DeferHandle, EventT)
	

end