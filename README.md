# LuaDardo Plus

A maintained fork of [LuaDardo](https://github.com/arcticfox1919/LuaDardo) - Lua 5.3 virtual machine written in pure Dart.

## Why This Fork?

The original LuaDardo has been inactive since July 2023 with several critical bugs unfixed. This fork provides:

- **Bug fixes** for issues #24, #33, #34, #36
- **Active maintenance** and community support
- **100% Dart** - works on all platforms (iOS, Android, Web, Desktop)

### Fixed Issues

| Issue | Description |
|-------|-------------|
| #24 | `math.random` upper bound not inclusive, negative ranges rejected |
| #33 | Error messages lack source file and line number information |
| #34 | `return` without value causes runtime error |
| #36 | Userdata metatables shared globally instead of per-instance |

## Installation

```yaml
dependencies:
  lua_dardo_plus: ^0.1.0
```

## Example

```dart
import 'package:lua_dardo_plus/lua.dart';

void main() {
  LuaState state = LuaState.newState();
  state.openLibs();
  state.loadString(r'''
a = 10
while a < 20 do
   print("a value is", a)
   a = a + 1
end
''');
  state.call(0, 0);
}
```

## Usage

The LuaDardo Plus library is compatible with Lua C APIs. For Dart-Lua interoperability, refer to the [Lua C API guide](https://www.lua.org/manual/5.3/manual.html#luaL_newstate).

### Dart Calls Lua

Get Lua variables:
```lua
-- test.lua
a = 100
b = 120
```

```dart
LuaState ls = LuaState.newState();
ls.openLibs();
ls.doFile("test.lua");

ls.getGlobal("a");
if (ls.isNumber(-1)) {
  var a = ls.toNumber(-1);
  print("a=$a");
}

ls.getGlobal("b");
if (ls.isNumber(-1)) {
  var b = ls.toNumber(-1);
  print("b=$b");
}
```

Get Lua table:
```lua
-- test.lua
mytable = {k1 = 1, k2 = 2.34, k3 = "test"}
```

```dart
ls.getGlobal("mytable");
ls.getField(-1, "k1");
if (ls.isInteger(-1)) {
  var k1 = ls.toInteger(-1);
}
```

Call Lua function:
```lua
-- test.lua
function myFunc()
    print("myFunc run")
end
```

```dart
ls.doFile("test.lua");
ls.getGlobal("myFunc");
if (ls.isFunction(-1)) {
  ls.pCall(0, 0, 0);
}
```

### Lua Calls Dart

```dart
import 'package:lua_dardo_plus/lua.dart';
import 'dart:math';

// Wrapper function signature: int Function(LuaState ls)
// Return value is the number of returned values
int randomInt(LuaState ls) {
  int max = ls.checkInteger(1);
  ls.pop(1);

  var random = Random();
  var randVal = random.nextInt(max);
  ls.pushInteger(randVal);
  return 1;
}

void main() {
  LuaState state = LuaState.newState();
  state.openLibs();

  state.pushDartFunction(randomInt);
  state.setGlobal('randomInt');

  state.loadString('''
rand_val = randomInt(10)
print('random value is '..rand_val)
''');
  state.call(0, 0);
}
```

## Migration from lua_dardo

Simply update your import:

```dart
// Before
import 'package:lua_dardo/lua.dart';

// After
import 'package:lua_dardo_plus/lua.dart';
```

## License

Apache-2.0 (same as original LuaDardo)

## Credits

- Original author: [arcticfox1919](https://github.com/arcticfox1919)
- Fork maintainer: [ImL1s](https://github.com/ImL1s)
