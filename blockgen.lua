red = "\x1b[31m"
cyan = "\x1b[96m"
white = "\x1b[0m"
green = "\x1b[32m"

local function ansi(...)
    return '\x1b[' .. table.concat({...}, ';') .. 'm'
end

local STYLE = {
    RESET = 0,
    BOLD = 1,
    DIM = 2,
    ITALIC = 3,
    UNDERLINE = 4,
    BLINK = 5,
    FAST_BLINK = 6,
    REVERSE = 7,
    HIDE = 8,
    STRIKETHROUGH = 9,
    DOUBLE_UNDERLINE = 21,
    REGULAR = 22,
    NO_ITALIC = 23,
    NO_UNDERLINE = 24,
    NO_BLINK = 25,
    NO_REVERSE = 27,
    NO_HIDE = 28,
    NO_STRIKETHROUGH = 29,
}

local FG = {
    DEFAULT = 39,
    BLACK = 30,
    RED = 31,
    GREEN = 32,
    YELLOW = 33,
    BLUE = 34,
    MAGENTA = 35,
    CYAN = 36,
    WHITE = 37,
    BRIGHT_BLACK = 90,
    BRIGHT_RED = 91,
    BRIGHT_GREEN = 92,
    BRIGHT_YELLOW = 93,
    BRIGHT_BLUE = 94,
    BRIGHT_MAGENTA = 95,
    BRIGHT_CYAN = 96,
    BRIGHT_WHITE = 97
}

local BG = {
    DEFAULT = 49,
    BLACK = 40,
    RED = 41,
    GREEN = 42,
    YELLOW = 43,
    BLUE = 44,
    MAGENTA = 45,
    CYAN = 46,
    WHITE = 47,
    BRIGHT_BLACK = 100,
    BRIGHT_RED = 101,
    BRIGHT_GREEN = 102,
    BRIGHT_YELLOW = 103,
    BRIGHT_BLUE = 104,
    BRIGHT_MAGENTA = 105,
    BRIGHT_CYAN = 106,
    BRIGHT_WHITE = 107
}

function graceful_error(msg) 
    io.write(temp_ansi("error: ", FG.RED))
    io.stderr:write(msg .. "\n")
    os.exit(1)
end

function temp_ansi(str, ...)
    return ansi(...) .. str .. ansi(STYLE.RESET)
end

function parse_hex(input)
    input = input:lower() -- covers capital X in 0X

    if input:sub(1, 2) == "0x" then
        input = input:sub(3) -- cut off 0x part, but only if present
    end

    if input:len() == 3 then
        input = input:sub(1, 1):rep(2) .. input:sub(2, 2):rep(2) .. input:sub(3, 3):rep(2) -- covers FFF -> FFFFFF
    end

    local matched = input:match('%x%x%x%x%x%x')
    if matched and matched:len() == input:len() then
        return matched
    end
end

print(temp_ansi("Lua",STYLE.RESET,FG.BLUE,BG.BRIGHT_WHITE).." block generator designed by "..temp_ansi("Famous5000#8968",FG.BRIGHT_CYAN).." on "..temp_ansi("Discord",FG.MAGENTA)..".")

function getInput(Request, Type)
    if Type == nil or Type == "String" then -- Default behavior.
        io.write(Request)
        return io.read("*line")
    elseif Type == "Number" then -- Number assertion.
        io.write(Request)
        local IN = io.read("*line")
        if tonumber(IN) == nil then
            print(red.."Invalid number."..white)
            return getInput(Request, Type)
        else
            return tonumber(IN)
        end
    elseif Type == "ONumber" then -- Optional number assertion.
        io.write(Request)
        local IN = io.read("*line")
        if IN == "" then
            return 0
        end
        if tonumber(IN) == nil then
            print(red.."Invalid number. Leave blank to exclude."..white)
            return getInput(Request, Type)
        else
            return tonumber(IN)
        end
    elseif Type == "Paragraph" then -- Multi-line input
        io.write(Request.."\n")
        local Out = ""
        while true do
            io.write("> "..green)
            local IN = io.read("*line")
            io.write(white)
            if IN:len() == 0 then
                if Out:len() ~= 0 then
                    Out = string.sub(1,Out:len()-1)
                end
                return Out
            end
            Out = Out..IN.."\n"
        end
    elseif Type == "Hex6" then -- Color 0xRRGGBB
        io.write(Request)
        local IN = io.read("*line")
        local match = parse_hex(IN)
        if match == nil then
            print(red.."Invalid color6 value. You should format it similar to this:"..green.."0xRRGGBB"..red..", "..green.."RRGGBB"..red..", or "..green.."RGB"..red..".")
            return getInput(Request,Type)
        end
        return match
    else
        error('Invalid datatype specified.')
    end
end

run = 1
shapes = {}
while run ~= 0 do
    local IN = getInput(cyan.."Input shape, or if you are done, leave empty: "..white)
    if IN:len() == 0 then
        run = 0
    else
        shapes[#shapes+1] = IN
    end
end
if #shapes == 0 then
    graceful_error("You didn't input any shapes! Exiting.")
end
while run == 0 do
    local types = getInput(cyan.."Input the number of shape types you will be generating. Each will have their own requests, decimals will be truncated: "..white,"Number")
    if types == 0 then
        print(red.."Invalid number."..white)
    else
        run = 1
    end
    types = math.floor(types)
end
sizeoffset = getInput(cyan.."Input the starting scale of the shapes you will be generating. Useful for vanilla shape utilization, starting from 0. Leave blank for 0: "..white,"ONumber")
sizeoffset = math.floor(sizeoffset)
faction = getInput(cyan.."Input the faction that the palette will belong to: "..white,"Number")
sizes = 0
while run == 1 do
    sizes = getInput(cyan.."Input the number of shape sizes you will be generating. The max number should be the shape with the lowest size limit: "..white,"Number")
    if sizes == 0 then
        print(red.."Invalid number."..white)
    else
        run = 0
    end
    sizes = math.floor(sizes)
end
data = {}
for i = 1,types do
    local prefix = red.."- "..white..i..red.."/"..white..types.." "
    data[i] = {}
    data[i].Name = getInput(prefix..cyan.."Enter name of the block type. This will be shared along the type: "..white)
    data[i].Blurb = getInput(prefix..cyan.."Enter description of the block, using an empty line to finish: "..white,"Paragraph") -- This is the last line that uses the definitions provided by the color codes above. The rest is used via the ansi-conversion functions.
    data[i].fillColor = "0x"..getInput(prefix..ansi(FG.BRIGHT_CYAN).."Enter the fillColor of the block: "..ansi(STYLE.RESET),"Hex6")
    data[i].fillColor1 = "0x"..getInput(prefix..ansi(FG.BRIGHT_CYAN).."Enter the fillColor1 of the block: "..ansi(STYLE.RESET),"Hex6")
    data[i].lineColor = "0x"..getInput(prefix..ansi(FG.BRIGHT_CYAN).."Enter the lineColor of the block: "..ansi(STYLE.RESET),"Hex6")
    data[i].density = getInput(prefix..temp_ansi("Enter the density multiplier per area of the block: ",FG.BRIGHT_CYAN),"Number")
    data[i].durability = getInput(prefix..temp_ansi("Enter the durability multiplier per area of the block: ",FG.BRIGHT_CYAN),"Number")
    local features = getInput(prefix..temp_ansi("Enter any features that you would need the block to have, separated by |'s. If left empty, this field will not be auto-generated.\nExamples are "..ansi(FG.GREEN).."NORECOLOR|EXPLODE|TRACTOR"..ansi(FG.BRIGHT_CYAN)..": ",FG.BRIGHT_CYAN))
    if features ~= "" then
        data[i].features = features
    end
    local capacity = getInput(prefix..temp_ansi("Enter the amount of R-capacity for this type of block to have. Leave blank or put 0 to exclude this field from auto-generation: ",FG.BRIGHT_CYAN),"ONumber")
    if capacity ~= 0 then
        data[i].capacity = capacity
    end
    data[i].extra = getInput(prefix..temp_ansi("Enter any additional paramaters that are not covered in the answers above that you'd like this group to have, using an empty line to finish: ",FG.BRIGHT_CYAN),"Paragraph")
end
total = types*#shapes*sizes
if total > 200 then
    print(temp_ansi("Warning: You're writing over 200 individual blocks. The range 0-200 will be automatically disabled."))
end
N = getInput(temp_ansi("Input the starting ID for the blocks. Leave empty for the default setting: ",FG.BRIGHT_CYAN),"ONumber")
start = 0
if N + total > 200 and N < 17000 then
    start = 17000
    print(temp_ansi("Warning: You specified a range that would overwrite vanilla blocks. Switching the start range to 17000.",FG.RED))
else
    start = N
end
file = nil
while file == nil do
    local error
    file,error = io.open(getInput(temp_ansi("Finally, insert the location that the blocks will be written to, ending with the file-name: ",FG.BRIGHT_CYAN)),"w")
    if file == nil then
        print(temp_ansi("Error: "..error,BG.RED))
    end
end
print(temp_ansi("The code will now execute to write the blocks for you, in formatted code. Hang tight!",FG.GREEN))
total = types*#shapes
file:write([[-- Auto-generated by the Easy Block List program
-- Please post any bug reports to Famous5000#8968 on Discord.


{]].."\n")
start = start - 1
for x = 1,types do
    for y = 1,#shapes do
        io.write("\r"..temp_ansi((x-1)*#shapes+y.."/"..total.." unique blocks written.",FG.GREEN))
        if ((x-1)*#shapes+y)%50 == 0 then
            print("")
        end
        for z = 1,sizes do
            file:write("    {"..(start+((x-1)*#shapes*(types+1)+(x-1))+(y-1)*types+(y-x)+z).."\n")
            local tab = "        "
            if z == 1 and y == 1 then
                file:write(tab.."name = \""..data[x].Name.."\"\n")
                file:write(tab.."blurb = \""..data[x].Blurb.."\"\n")
                file:write(tab.."fillColor = "..data[x].fillColor.."\n")
                file:write(tab.."fillColor1 = "..data[x].fillColor1.."\n")
                file:write(tab.."lineColor = "..data[x].lineColor.."\n")
                file:write(tab.."density = "..data[x].density.."\n")
                file:write(tab.."scale = "..sizeoffset+z.."\n")
                file:write(tab.."shape = "..shapes[y].."\n")
                file:write(tab.."group = "..faction.."\n")
                if data[x].features ~= nil then
                    file:write(tab.."features = "..data[x].features.."\n")
                end
                if data[x].capacity ~= nil then
                    file:write(tab.."capacity = "..data[x].capacity.."\n")
                end
                if data[x].extra:len() > 0 then
                    file:write(data[x].extra.."\n")
                end
            elseif z == 1 then
                file:write(tab.."extends = "..(start+((x-1)*#shapes*(types+1)+(x-1)+2-x).."\n"))
                file:write(tab.."shape = "..shapes[y].."\n")
            else
                file:write(tab.."extends = "..(start+((x-1)*#shapes*(types+1)+(x-1))+(y-1)*types+(y-x)+1).."\n")
                file:write(tab.."scale = "..sizeoffset+z.."\n")
            end
            file:write("    }\n")
        end
    end
end
file:write("}")
print(temp_ansi("\nJob complete!",FG.GREEN).." Total size: "..temp_ansi(file:seek()))
file:close()
print(temp_ansi("File closed successfully. Code execution complete!",FG.BRIGHT_GREEN))
