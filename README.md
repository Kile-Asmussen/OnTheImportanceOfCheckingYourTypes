# What is this mod?

This mod has one line of code:

```lua
-- data.lua:
string.icon = "__base__/code/review/is/important.png"
```

It crashes Factorio.

# What? Why?

This is because whoever wrote `__base__/data-updates.lua` did some, shall we say... unorthodox type-checking on line 62:

```lua
local function generate_barrel_icons(fluid, base_icon, side_mask, top_mask)
  return
  {
    {
      icon = base_icon.icon or base_icon, -- Line 62
      icon_size = base_icon.icon_size or defines.default_icon_size,
    },
    {
      icon = side_mask,
      icon_size = defines.default_icon_size,
      tint = util.get_color_with_alpha(fluid.base_color, side_alpha, true)
    },
    {
      icon = top_mask,
      icon_size = defines.default_icon_size, 
      tint = util.get_color_with_alpha(fluid.flow_color, top_hoop_alpha, true)
    }
  }
end

```
(Code is taken from the actual game files, all intellectual rights belong to Wube, sic comments removed for brevity)

The indicated line looks innocuous until you realize what the purpose of it is. This function is part of the script that automatically generates barrelling recipes for fluids. The `base_icon` variable can either be an [IconData](https://lua-api.factorio.com/latest/types/IconData.html) struct or a [FileName](https://lua-api.factorio.com/latest/types/FileName.html) (i.e. a string).

`IconData` has a field `icon` which is a file name. So the line tries to access that field, and when it comes up `nil`, defaults to using the value because it must be a string...

But wait a second, I hear you say, if `base_icon` can be either a table or a string &mdash; you can't index a string like a table! Why doesn't this code break?

Because Lua is a terrible language. You may have heard of metatables, which is how Lua handles operator overloading. One of the overloadable operations, named `__index` is what happens when one indexes a table with a key that does not exist. By default that returns `nil` but it is possible for instance to impose rigor on table accesses by setting `__index` to a function that throws an error, to indicate that an entry in the table does not exist.

One cool thing about the `__index` operator in particular is that if you set it to a table, then that will serve as a "backup table" for lookups:

```lua
t1 = { a = 2 }
t2 = { b = 3 }
setmetatable(t1, { __index = t2 })
print(t1.b) -- prints 3
```

As it happens, strings have a metatable. Indeed all of them have the same one. It has a single key, `__index` and it is set to...

```lua
print( getmetatable("").__index == _ENV.string ) -- prints true
```

The global `string` table! This is why you can call string functions on strings like methods:

```lua
s = "hello"
print(s:gsub("ll", "ww")) -- prints hewwo and 1 (the number of substitutions made, string.gsub is multi-return)
```

Now what does that mean? It means this:

```lua
print("".icon) -- prints nil
string.icon = "gotcha"
print("".icon) -- prints gotcha
```

And that is what the code in `__base__/data-updates.lua` relies on to check whether something is an `IconData` struct (which must have an `icon` field that is a string) or a filename.

This mod simply makes it so line 62 above, always results in the `icon` being set to the name of a graphics file that does not exist, causing the game to fail to load. Other shenanigans is also possible, whereby we can set the icon in fluid recipes to contain arbitrary graphics, and even adjust their sizing by setting `string.icon_size`, but I felt this mod was more than fun enough.

# Why?

Because I think it is hilarious. The fix is very simple, I've included a code sample in this mod which is not loaded by the game, just the necessary code to correct this problem.

The thumbnail is an example of how this exploit can be used to do other interesting things.