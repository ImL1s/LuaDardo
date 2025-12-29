import 'package:lua_dardo/lua.dart';
import 'package:test/test.dart';

void main() {
  group('Issue #24: math.random range', () {
    test('math.random(1, 10) should include 10', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      // Run multiple times to verify upper bound is included
      state.loadString(r'''
        local found10 = false
        math.randomseed(12345)
        for i = 1, 1000 do
          local n = math.random(1, 10)
          if n == 10 then
            found10 = true
            break
          end
        end
        return found10
      ''');
      state.pCall(0, 1, 0);
      bool found10 = state.toBoolean(-1);
      expect(found10, isTrue, reason: 'math.random(1, 10) should be able to return 10');
    });

    test('math.random should work with negative ranges', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
        math.randomseed(12345)
        local n = math.random(-10, 10)
        return n >= -10 and n <= 10
      ''');
      state.pCall(0, 1, 0);
      bool validRange = state.toBoolean(-1);
      expect(validRange, isTrue, reason: 'math.random(-10, 10) should work with negative ranges');
    });

    test('math.random lower bound should be included', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
        local found1 = false
        math.randomseed(12345)
        for i = 1, 1000 do
          local n = math.random(1, 10)
          if n == 1 then
            found1 = true
            break
          end
        end
        return found1
      ''');
      state.pCall(0, 1, 0);
      bool found1 = state.toBoolean(-1);
      expect(found1, isTrue, reason: 'math.random(1, 10) should be able to return 1');
    });
  });

  group('Issue #34: return without value', () {
    test('return without value should work', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
        function test()
          if true then
            return  -- return without value
          end
          return 42
        end
        return test()
      ''');
      state.pCall(0, 1, 0);
      bool isNil = state.isNil(-1);
      expect(isNil, isTrue, reason: 'return without value should return nil');
    });

    test('return with value should still work', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
        function test()
          return 42
        end
        return test()
      ''');
      state.pCall(0, 1, 0);
      int result = state.toInteger(-1);
      expect(result, equals(42));
    });

    test('function without return should return nil', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
        function noReturn()
          local x = 1 + 2
        end
        return noReturn()
      ''');
      state.pCall(0, 1, 0);
      bool isNil = state.isNil(-1);
      expect(isNil, isTrue);
    });
  });

  group('Issue #36: userdata metatable per-instance', () {
    test('setting metatable on one userdata should not affect others', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      // Create two userdata objects
      Userdata ud1 = state.newUserdata();
      ud1.data = "data1";
      state.setGlobal("ud1");

      Userdata ud2 = state.newUserdata();
      ud2.data = "data2";
      state.setGlobal("ud2");

      // Set metatable only on ud1
      state.loadString(r'''
        local mt = { __index = { value = 100 } }
        debug.setmetatable(ud1, mt)
        -- ud2 should NOT have this metatable
        local mt2 = debug.getmetatable(ud2)
        return mt2 == nil
      ''');
      state.pCall(0, 1, 0);
      bool ud2HasNoMetatable = state.toBoolean(-1);
      expect(ud2HasNoMetatable, isTrue,
        reason: 'Setting metatable on ud1 should not affect ud2');
    });
  });

  group('Issue #33: error messages with line numbers', () {
    test('error message should include source and line info', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      // Try to call a nil value - should produce error with line info
      state.loadString(r'''
local notAFunction = nil
notAFunction()
''');

      ThreadStatus status = state.pCall(0, 0, 0);
      expect(status, equals(ThreadStatus.luaErrRun));

      String errorMsg = state.toStr(-1)!;
      // Error message should contain source file reference and line number
      expect(errorMsg.contains('['), isTrue,
        reason: 'Error message should contain source/line info: $errorMsg');
    });

    test('arithmetic error should include type info', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
local x = "hello" + 1
''');

      ThreadStatus status = state.pCall(0, 0, 0);
      expect(status, equals(ThreadStatus.luaErrRun));

      String errorMsg = state.toStr(-1)!;
      expect(errorMsg.toLowerCase().contains('arithmetic'), isTrue,
        reason: 'Error should mention arithmetic: $errorMsg');
    });

    test('comparison error should include type names', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
local result = {} < 5
''');

      ThreadStatus status = state.pCall(0, 0, 0);
      expect(status, equals(ThreadStatus.luaErrRun));

      String errorMsg = state.toStr(-1)!;
      expect(errorMsg.toLowerCase().contains('compare'), isTrue,
        reason: 'Error should mention compare: $errorMsg');
    });
  });
}
