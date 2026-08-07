# UltraSmartSaveInstance
- A smart **SaveInstance** that correctly saves any games **the way they look**.

## Usage
```lua
local prepass = loadstring(game:HttpGet("https://raw.githubusercontent.com/rinsfx/MySaveInstance/main/prepass.luau", true))()

local Options = {
    SaveBytecode = true,        -- Wajib true agar mentahan bytecode tersimpan di file .rbxl
    DecompileTimeout = 10,      -- Batas toleransi pembacaan skrip
}

local PrepassOptions = {
    RequestsPerMinute = 1350,
    MaxInFlight       = 30,
    ApiUrl            = "https://api.lua.expert/decompile",
    Verbose           = true,
    SkipPrepass       = false, -- skip cache warm-up, go straight to USSI
    SkipSaveInstance  = false, -- run only the prepass, don't call USSI
}

prepass(Options, PrepassOptions)
```

local prepass = loadstring(game:HttpGet("https://raw.githubusercontent.com/rinsfx/MySaveInstance/main/prepass.luau", true))()

local Options = {
    SaveBytecode = true,
    DecompileTimeout = 60,
    Isolate = true,            -- PENTING: Mencegah script game bentrok saat disave
   -- FileName = "MapHasilSave", -- Menghindari error nama file dari karakter ilegal
}

local PrepassOptions = {
    RequestsPerMinute = 1350,
    MaxInFlight       = 35,
    RequestTimeout    = 60,
    ApiUrl            = "https://api.lua.expert/decompile",
    Verbose           = true,
    SkipPrepass       = false,
    SkipSaveInstance  = false,
}

prepass(Options, PrepassOptions)



<details>
<summary><h3>What's different from the original / Why use this version</h3></summary>

- **Faster, lighter saves** - the file is assembled with a table buffer instead of repeated string concatenation, fixing the `O(n²)` growth that caused "not enough memory" on large games.
- **Terrain `SmoothGrid` / `PhysicsGrid`** are serialized and render properly.
- **Unions render correctly** - Re-enabled `gethiddenproperty` during the save (it was being disabled unconditionally) so the union's `MeshData2` is actually read, and stopped `IgnoreSharedStrings` from dropping the `MeshData2` / `ChildData2` / `PhysicalConfigData` SharedStrings. On executors that can't read union mesh data, unions fall back to a visible bounding-box Part instead of being invisible.
- **Part Color & Size are saved** - uses the official Roblox CDN API dump (other dumps strip the serialized `Color3uint8` / `size` members, which made parts load grey & default-sized).
- **Decals, images & sounds are saved** - the new `Content` DataType (`Image` / `Texture` / `SoundId`) is handled.

</details>

## Credits
- [luau](https://github.com/luau/UniversalSynSaveInstance) - UniversalSynSaveInstance
- [centerepic](https://gitlab.com/centerepic/ussiprepass) - USSI Prepass
- [lua.expert](https://lua.expert) - Lua(u) Decompiler
