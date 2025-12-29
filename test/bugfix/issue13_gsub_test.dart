import 'package:lua_dardo_plus/lua.dart';
import 'package:test/test.dart';

void main() {
  group('Issue #13: string.gsub', () {
    test('gsub should replace all occurrences by default', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
        local result, count = string.gsub("test", "t", "T")
        return result, count
      ''');
      state.pCall(0, 2, 0);

      String result = state.toStr(-2)!;
      int count = state.toInteger(-1);

      expect(result, equals('TesT'), reason: 'All t should be replaced with T');
      expect(count, equals(2), reason: 'Should report 2 replacements');
    });

    test('gsub with n=1 should replace only first occurrence', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
        local result, count = string.gsub("test", "t", "T", 1)
        return result, count
      ''');
      state.pCall(0, 2, 0);

      String result = state.toStr(-2)!;
      int count = state.toInteger(-1);

      expect(result, equals('Test'), reason: 'Only first t should be replaced');
      expect(count, equals(1), reason: 'Should report 1 replacement');
    });

    test('gsub with n=0 should replace nothing', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
        local result, count = string.gsub("test", "t", "T", 0)
        return result, count
      ''');
      state.pCall(0, 2, 0);

      String result = state.toStr(-2)!;
      int count = state.toInteger(-1);

      expect(result, equals('test'), reason: 'Nothing should be replaced');
      expect(count, equals(0), reason: 'Should report 0 replacements');
    });

    test('gsub should handle pattern not found', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
        local result, count = string.gsub("hello", "x", "Y")
        return result, count
      ''');
      state.pCall(0, 2, 0);

      String result = state.toStr(-2)!;
      int count = state.toInteger(-1);

      expect(result, equals('hello'), reason: 'String should be unchanged');
      expect(count, equals(0), reason: 'Should report 0 replacements');
    });

    test('gsub should handle empty replacement', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
        local result, count = string.gsub("hello", "l", "")
        return result, count
      ''');
      state.pCall(0, 2, 0);

      String result = state.toStr(-2)!;
      int count = state.toInteger(-1);

      expect(result, equals('heo'), reason: 'All l should be removed');
      expect(count, equals(2), reason: 'Should report 2 replacements');
    });

    test('gsub with words pattern', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
        local result, count = string.gsub("hello world", "world", "Lua")
        return result, count
      ''');
      state.pCall(0, 2, 0);

      String result = state.toStr(-2)!;
      int count = state.toInteger(-1);

      expect(result, equals('hello Lua'));
      expect(count, equals(1));
    });

    test('gsub should handle multiple occurrences with limit', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      state.loadString(r'''
        local result, count = string.gsub("aaa", "a", "b", 2)
        return result, count
      ''');
      state.pCall(0, 2, 0);

      String result = state.toStr(-2)!;
      int count = state.toInteger(-1);

      expect(result, equals('bba'), reason: 'Only first 2 a should be replaced');
      expect(count, equals(2));
    });

    test('gsub with regex pattern', () {
      LuaState state = LuaState.newState();
      state.openLibs();

      // Note: Lua patterns are converted to Dart RegExp
      state.loadString(r'''
        local result, count = string.gsub("hello123world456", "[0-9]+", "NUM")
        return result, count
      ''');
      state.pCall(0, 2, 0);

      String result = state.toStr(-2)!;
      int count = state.toInteger(-1);

      expect(result, equals('helloNUMworldNUM'));
      expect(count, equals(2));
    });
  });
}
