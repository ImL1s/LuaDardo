# LuaDardo Plus

![LuaDardo Plus Hero](assets/images/hero.png)


A maintained fork of [LuaDardo](https://github.com/arcticfox1919/LuaDardo) - Lua 5.3 virtual machine written in pure Dart.

[English](README.md) | [繁體中文](README_zh.md)


## Why This Fork?

The original LuaDardo has been inactive since July 2023 with several critical bugs unfixed. This fork provides:

- **Bug fixes** for issues #13, #24, #33, #34, #36
- **Web platform support** - runs on all platforms including browsers
- **Async Dart functions** - call async Dart code from Lua
- **Active maintenance** and community support
- **100% Dart** - no native dependencies

### Fixed Issues

| Issue | Description |
|-------|-------------|
| #13 | `string.gsub` infinite loop and incorrect replacement |
| #24 | `math.random` upper bound not inclusive, negative ranges rejected |
| #33 | Error messages lack source file and line number information |
| #34 | `return` without value causes runtime error |
| #36 | Userdata metatables shared globally instead of per-instance |
| - | `math.min` returning maximum value instead of minimum |
| - | `math.modf` returning only fractional part |

## Installation

```yaml
dependencies:
  lua_dardo_plus: ^0.3.0
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

### Async Dart Functions

Call async Dart functions from Lua (v0.3.0+):

```dart
import 'package:lua_dardo_plus/lua.dart';

Future<int> fetchData(LuaState ls) async {
  final url = ls.checkString(1);

  // Simulate async operation (e.g., HTTP request)
  await Future.delayed(Duration(seconds: 1));

  ls.pushString('Data from $url');
  return 1; // Number of return values
}

void main() async {
  LuaState state = LuaState.newState();
  state.openLibs();

  // Register async function
  state.registerAsync('fetchData', fetchData);

  // Call from Dart using callAsync
  state.getGlobal('fetchData');
  state.pushString('https://api.example.com');
  await state.callAsync(1, 1);

  print(state.toStr(-1)); // "Data from https://api.example.com"
}
```

Available async methods:
- `registerAsync(name, func)` - Register async function as global
- `pushDartFunctionAsync(func)` - Push async function onto stack
- `pushDartClosureAsync(func, nUpvals)` - Push async closure with upvalues
- `callAsync(nArgs, nResults)` - Call function asynchronously
- `pCallAsync(nArgs, nResults, errFunc)` - Protected async call
- `doStringAsync(code)` - Execute Lua string asynchronously
- `doFileAsync(path)` - Execute Lua file asynchronously

### Web Platform Support

LuaDardo Plus works on web platforms (v0.3.0+). The library uses platform abstraction to handle `dart:io` dependencies:

```dart
import 'package:lua_dardo_plus/lua.dart';
import 'package:lua_dardo_plus/src/platform/platform.dart';

void main() {
  // Customize print output (useful for web)
  PlatformServices.instance.printCallback = (s) {
    // Redirect to console, DOM, etc.
    print(s);
  };

  LuaState state = LuaState.newState();
  state.openLibs();
  state.doString('print("Hello from Lua on the web!")');
}
```

**Web limitations:**
- `os.execute()`, `os.exit()`, `os.remove()`, `os.rename()`, `os.getenv()` throw `UnsupportedError`
- `os.time()`, `os.clock()`, `os.date()`, `os.difftime()` work normally
- File loading (`doFile`, `loadFile`) not supported on web

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
