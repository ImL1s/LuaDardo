# LuaDardo Plus

![LuaDardo Plus Hero](assets/images/hero.png)

[English](README.md) | [繁體中文](README_zh.md)

[LuaDardo](https://github.com/arcticfox1919/LuaDardo) 的維護分支 - 純 Dart 編寫的 Lua 5.3 虛擬機。

## 為何建立此分支？

原始的 LuaDardo 專案自 2023 年 7 月以來已停止活躍維護，且有數個關鍵漏洞未修復。此分支提供：

- **錯誤修復**：修復了 issue #13, #24, #33, #34, #36
- **Web 平台支援**：可在所有平台上運行，包括瀏覽器
- **非同步 Dart 函數**：支援從 Lua 呼叫非同步 (async) Dart 程式碼
- **活躍維護**：持續更新與社群支援
- **100% Dart**：無任何原生依賴

### 已修復的問題

| Issue | 描述 |
|-------|------|
| #13 | `string.gsub` 無窮迴圈與替換不正確 |
| #24 | `math.random` 上限不包含，且拒絕負數範圍 |
| #33 | 錯誤訊息缺少來源檔案與行號資訊 |
| #34 | 無回傳值的 `return` 導致運行時錯誤 |
| #36 | Userdata metatables 全域共用而非每個實例獨立 |
| - | `math.min` 回傳最大值而非最小值 |
| - | `math.modf` 僅回傳小數部分 |

## 安裝

```yaml
dependencies:
  lua_dardo_plus: ^0.3.0
```

## 範例

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

## 使用方式

LuaDardo Plus 函式庫與 Lua C API 相容。關於 Dart-Lua 互操作性，請參考 [Lua C API 指南](https://www.lua.org/manual/5.3/manual.html#luaL_newstate)。

### Dart 呼叫 Lua

取得 Lua 變數：
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

取得 Lua table：
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

呼叫 Lua 函數：
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

### Lua 呼叫 Dart

```dart
import 'package:lua_dardo_plus/lua.dart';
import 'dart:math';

// 包裝函數簽章: int Function(LuaState ls)
// 回傳值為回傳給 Lua 的參數數量
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

### 非同步 Dart 函數 (Async Dart Functions)

從 Lua 呼叫非同步 Dart 函數 (v0.3.0+)：

```dart
import 'package:lua_dardo_plus/lua.dart';

Future<int> fetchData(LuaState ls) async {
  final url = ls.checkString(1);

  // 模擬非同步操作 (例如 HTTP 請求)
  await Future.delayed(Duration(seconds: 1));

  ls.pushString('Data from $url');
  return 1; // 回傳值數量
}

void main() async {
  LuaState state = LuaState.newState();
  state.openLibs();

  // 註冊非同步函數
  state.registerAsync('fetchData', fetchData);

  // 使用 callAsync 從 Dart 呼叫
  state.getGlobal('fetchData');
  state.pushString('https://api.example.com');
  await state.callAsync(1, 1);

  print(state.toStr(-1)); // "Data from https://api.example.com"
}
```

可用的非同步方法：
- `registerAsync(name, func)` - 註冊全域非同步函數
- `pushDartFunctionAsync(func)` - 推送非同步函數至堆疊
- `pushDartClosureAsync(func, nUpvals)` - 推送帶有 upvalues 的非同步閉包
- `callAsync(nArgs, nResults)` - 非同步呼叫函數
- `pCallAsync(nArgs, nResults, errFunc)` - 受保護的非同步呼叫
- `doStringAsync(code)` - 非同步執行 Lua 字串
- `doFileAsync(path)` - 非同步執行 Lua 檔案

### Web 平台支援

LuaDardo Plus 支援 Web 平台 (v0.3.0+)。本函式庫使用平台抽象層來處理 `dart:io` 依賴：

```dart
import 'package:lua_dardo_plus/lua.dart';
import 'package:lua_dardo_plus/src/platform/platform.dart';

void main() {
  // 自訂 print 輸出 (在 web 上很有用)
  PlatformServices.instance.printCallback = (s) {
    // 重新導向至 console、DOM 等
    print(s);
  };

  LuaState state = LuaState.newState();
  state.openLibs();
  state.doString('print("Hello from Lua on the web!")');
}
```

**Web 限制：**
- `os.execute()`、`os.exit()`、`os.remove()`、`os.rename()`、`os.getenv()` 會拋出 `UnsupportedError`
- `os.time()`、`os.clock()`、`os.date()`、`os.difftime()` 正常運作
- Web 不支援檔案載入 (`doFile`、`loadFile`)

## 從 lua_dardo 遷移

只需更新 import：

```dart
// 更新前
import 'package:lua_dardo/lua.dart';

// 更新後
import 'package:lua_dardo_plus/lua.dart';
```

## License

Apache-2.0 (與原始 LuaDardo 相同)

## Credits

- 原始作者：[arcticfox1919](https://github.com/arcticfox1919)
- 分支維護者：[ImL1s](https://github.com/ImL1s)
