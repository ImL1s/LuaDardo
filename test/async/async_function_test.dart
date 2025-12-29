import 'dart:async';
import 'package:lua_dardo_plus/lua.dart';
import 'package:test/test.dart';

void main() {
  group('Async Dart Function Tests', () {
    late LuaState lua;

    setUp(() {
      lua = LuaState.newState();
      lua.openLibs();
    });

    group('registerAsync()', () {
      test('should register async function and call via callAsync', () async {
        // Register an async Dart function
        lua.registerAsync('asyncAdd', (LuaState ls) async {
          final a = ls.toInteger(1);
          final b = ls.toInteger(2);
          // Simulate async operation
          await Future.delayed(Duration(milliseconds: 10));
          ls.pushInteger(a + b);
          return 1;
        });

        // Call from Dart using callAsync
        lua.getGlobal('asyncAdd');
        lua.pushInteger(10);
        lua.pushInteger(20);

        await lua.callAsync(2, 1);

        expect(lua.toInteger(-1), equals(30));
      });

      test('should handle async function returning multiple values', () async {
        lua.registerAsync('asyncMulti', (LuaState ls) async {
          await Future.delayed(Duration(milliseconds: 5));
          ls.pushString('hello');
          ls.pushInteger(42);
          ls.pushBoolean(true);
          return 3;
        });

        lua.getGlobal('asyncMulti');
        await lua.callAsync(0, 3);

        expect(lua.toBoolean(-1), isTrue);
        lua.pop(1);
        expect(lua.toInteger(-1), equals(42));
        lua.pop(1);
        expect(lua.toStr(-1), equals('hello'));
      });
    });

    group('pushDartFunctionAsync()', () {
      test('should push and call async function via callAsync', () async {
        lua.pushDartFunctionAsync((LuaState ls) async {
          await Future.delayed(Duration(milliseconds: 5));
          ls.pushString('async result');
          return 1;
        });
        lua.setGlobal('myAsyncFunc');

        lua.getGlobal('myAsyncFunc');
        await lua.callAsync(0, 1);

        expect(lua.toStr(-1), equals('async result'));
      });
    });

    group('pushDartClosureAsync()', () {
      test('should push async closure with upvalues', () async {
        // Push upvalue
        lua.pushInteger(100);

        // Push async closure with 1 upvalue
        lua.pushDartClosureAsync((LuaState ls) async {
          // Get upvalue
          final upvalue = ls.toInteger(luaUpvalueIndex(1));
          await Future.delayed(Duration(milliseconds: 5));
          ls.pushInteger(upvalue * 2);
          return 1;
        }, 1);
        lua.setGlobal('asyncClosure');

        lua.getGlobal('asyncClosure');
        await lua.callAsync(0, 1);

        expect(lua.toInteger(-1), equals(200));
      });
    });

    group('pCallAsync()', () {
      test('should handle successful async call', () async {
        lua.registerAsync('asyncOk', (LuaState ls) async {
          await Future.delayed(Duration(milliseconds: 5));
          ls.pushString('success');
          return 1;
        });

        lua.getGlobal('asyncOk');
        final status = await lua.pCallAsync(0, 1, 0);

        expect(status, equals(ThreadStatus.luaOk));
        expect(lua.toStr(-1), equals('success'));
      });

      test('should catch errors in async function', () async {
        lua.registerAsync('asyncError', (LuaState ls) async {
          await Future.delayed(Duration(milliseconds: 5));
          throw Exception('Async error!');
        });

        lua.getGlobal('asyncError');
        final status = await lua.pCallAsync(0, 0, 0);

        expect(status, equals(ThreadStatus.luaErrRun));
      });
    });

    group('doStringAsync()', () {
      test('should execute Lua code via pCallAsync', () async {
        // doStringAsync allows the top-level Lua function to be executed asynchronously
        // This is useful when Dart needs to await Lua code execution
        final success = await lua.doStringAsync('''
          x = 10
          y = 20
          result = x + y
        ''');

        expect(success, isTrue);
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(30));
      });

      test('should return false on syntax error', () async {
        final success = await lua.doStringAsync('invalid lua code @@@@');
        expect(success, isFalse);
      });

      test('should return false on runtime error', () async {
        final success = await lua.doStringAsync('''
          error("test error")
        ''');
        expect(success, isFalse);
      });
    });

    group('doFileAsync()', () {
      test('should return false for non-existent file', () async {
        final success = await lua.doFileAsync('/non/existent/file.lua');
        expect(success, isFalse);
      });
    });

    group('Mixed sync/async calls from Dart', () {
      test('should call sync functions with callAsync', () async {
        lua.register('syncFunc', (LuaState ls) {
          ls.pushInteger(42);
          return 1;
        });

        lua.getGlobal('syncFunc');
        await lua.callAsync(0, 1);

        expect(lua.toInteger(-1), equals(42));
      });

      test('should work with Lua functions via callAsync', () async {
        lua.doString('''
          function luaFunc(x)
            return x * 2
          end
        ''');

        lua.getGlobal('luaFunc');
        lua.pushInteger(21);
        await lua.callAsync(1, 1);

        expect(lua.toInteger(-1), equals(42));
      });

      test('should handle Lua function returning multiple values', () async {
        lua.doString('''
          function multiReturn()
            return 1, 2, 3
          end
        ''');

        lua.getGlobal('multiReturn');
        await lua.callAsync(0, 3);

        expect(lua.toInteger(-1), equals(3));
        lua.pop(1);
        expect(lua.toInteger(-1), equals(2));
        lua.pop(1);
        expect(lua.toInteger(-1), equals(1));
      });
    });

    group('Async error handling', () {
      test('should propagate errors properly', () async {
        lua.registerAsync('failAsync', (LuaState ls) async {
          await Future.delayed(Duration(milliseconds: 5));
          throw StateError('async failure');
        });

        lua.getGlobal('failAsync');
        final status = await lua.pCallAsync(0, 0, 0);

        expect(status, equals(ThreadStatus.luaErrRun));
        // Error message should be on stack
        expect(lua.isString(-1), isTrue);
      });

      test('should handle errors thrown synchronously in async function',
          () async {
        lua.registerAsync('syncThrow', (LuaState ls) async {
          throw ArgumentError('sync throw in async');
        });

        lua.getGlobal('syncThrow');
        final status = await lua.pCallAsync(0, 0, 0);

        expect(status, equals(ThreadStatus.luaErrRun));
      });
    });

    group('Sequential async operations', () {
      test('should handle multiple sequential async calls from Dart', () async {
        var callCount = 0;

        lua.registerAsync('asyncIncrement', (LuaState ls) async {
          await Future.delayed(Duration(milliseconds: 5));
          callCount++;
          ls.pushInteger(callCount);
          return 1;
        });

        // First call
        lua.getGlobal('asyncIncrement');
        await lua.callAsync(0, 1);
        expect(lua.toInteger(-1), equals(1));
        lua.pop(1);

        // Second call
        lua.getGlobal('asyncIncrement');
        await lua.callAsync(0, 1);
        expect(lua.toInteger(-1), equals(2));
        lua.pop(1);

        // Third call
        lua.getGlobal('asyncIncrement');
        await lua.callAsync(0, 1);
        expect(lua.toInteger(-1), equals(3));
        lua.pop(1);

        expect(callCount, equals(3));
      });
    });

    group('Async with upvalues', () {
      test('should access multiple upvalues in async closure', () async {
        // Push upvalues
        lua.pushInteger(10);
        lua.pushString('hello');
        lua.pushBoolean(true);

        // Push async closure with 3 upvalues
        lua.pushDartClosureAsync((LuaState ls) async {
          await Future.delayed(Duration(milliseconds: 5));

          final num = ls.toInteger(luaUpvalueIndex(1));
          final str = ls.toStr(luaUpvalueIndex(2));
          final bool_ = ls.toBoolean(luaUpvalueIndex(3));

          ls.pushString('$num-$str-$bool_');
          return 1;
        }, 3);

        await lua.callAsync(0, 1);

        expect(lua.toStr(-1), equals('10-hello-true'));
      });
    });
  });
}
