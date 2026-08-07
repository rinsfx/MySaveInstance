local HttpService = game:GetService("HttpService")
local API = "https://siftrblx.com/api/v1"
local SIFT_API_KEY = getgenv().SIFT_API_KEY
local BASE64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local MIN_INTERVAL = 0.5
local lastCall = 0

local function base64Encode(input: string): string
	local output = table.create(math.ceil(#input / 3) * 4)
	for index = 1, #input, 3 do
		local a = string.byte(input, index) or 0
		local b = string.byte(input, index + 1) or 0
		local c = string.byte(input, index + 2) or 0

		local triple = a * 65536 + b * 256 + c
		local i1 = math.floor(triple / 262144) % 64
		local i2 = math.floor(triple / 4096) % 64
		local i3 = math.floor(triple / 64) % 64
		local i4 = triple % 64

		output[#output + 1] = BASE64_ALPHABET:sub(i1 + 1, i1 + 1)
		output[#output + 1] = BASE64_ALPHABET:sub(i2 + 1, i2 + 1)
		output[#output + 1] = index + 1 <= #input and BASE64_ALPHABET:sub(i3 + 1, i3 + 1) or "="
		output[#output + 1] = index + 2 <= #input and BASE64_ALPHABET:sub(i4 + 1, i4 + 1) or "="
	end
	return table.concat(output)
end

local function decompileBytecode(bytecode: string, filename: string?): string
	assert(type(bytecode) == "string" and #bytecode > 0, "bytecode must be a non-empty string")

	local elapsed = os.clock() - lastCall
	if elapsed < MIN_INTERVAL then
		task.wait(MIN_INTERVAL - elapsed)
	end

	local jsonBody = HttpService:JSONEncode({
		filename = filename or "chunk.luac",
		bytecodeBase64 = base64Encode(bytecode),
	})

	local response = request({
		Url = API .. "/decompile?engine=cpp&rootMode=full-script&outputStyle=preserve&outputTier=plain",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
			["X-API-Key"] = SIFT_API_KEY,
		},
		Body = jsonBody,
	})
	lastCall = os.clock()

	if not response or response.Body == nil then
		return "-- HTTP request returned no response body.\n\n--[[\nStatusCode: "
			.. tostring(response and response.StatusCode)
			.. "\nStatusMessage: "
			.. tostring(response and response.StatusMessage)
			.. "\n--]]"
	end

	local decoded, parsed = pcall(HttpService.JSONDecode, HttpService, response.Body)
	if not decoded then
		return "-- Sift API returned invalid JSON\n\n--[[\n" .. tostring(response.Body) .. "\n--]]"
	end

	if response.StatusCode ~= 200 then
		local message = parsed.error and parsed.error.message or response.Body
		return "-- Error occurred while requesting the Sift API\n\n--[[\n" .. tostring(message) .. "\n--]]"
	end

	local result = parsed.results and parsed.results[1]
	if not result or type(result.luau) ~= "string" then
		return "-- Sift API returned no decompile result."
	end

	return result.luau
end

local function decompiley(scriptPath: Script | ModuleScript | LocalScript): string
	local success, bytecode = pcall(getscriptbytecode, scriptPath)
	if not success then
		return "-- Failed to get script bytecode, error:\n\n--[[\n" .. tostring(bytecode) .. "\n--]]"
	end
	return decompileBytecode(bytecode, scriptPath.Name)
end

getgenv().decompile = decompiley

local Params = {
 RepoURL = "https://raw.githubusercontent.com/rinsfx/MySaveInstance/main/",
 SSI = "saveinstance",
}
local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
local Options = {
    SaveBytecode = true,        -- Wajib true agar mentahan bytecode tersimpan di file .rbxl
    DecompileTimeout = 10,      -- Batas toleransi pembacaan skrip
}
synsaveinstance(Options)
