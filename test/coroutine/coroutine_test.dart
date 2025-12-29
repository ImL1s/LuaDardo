import 'package:lua_dardo_plus/lua.dart';
import 'package:test/test.dart';

void main() {
  group('Coroutine Tests', () {
    late LuaState ls;

    setUp(() {
      ls = LuaState.newState();
      ls.openLibs();
    });

    test('coroutine.create returns a thread', () {
      final code = '''
        local co = coroutine.create(function() end)
        return type(co)
      ''';
      ls.loadString(code);
      ls.pCall(0, 1, 0);
      expect(ls.toStr(-1), equals('thread'));
    });

    test('coroutine.status returns correct status', () {
      final code = '''
        local co = coroutine.create(function() end)
        return coroutine.status(co)
      ''';
      ls.loadString(code);
      ls.pCall(0, 1, 0);
      expect(ls.toStr(-1), equals('suspended'));
    });

    test('coroutine.resume starts coroutine', () {
      final code = '''
        local result = 0
        local co = coroutine.create(function()
          result = 42
        end)
        coroutine.resume(co)
        return result
      ''';
      ls.loadString(code);
      ls.pCall(0, 1, 0);
      expect(ls.toInteger(-1), equals(42));
    });

    test('coroutine.resume returns true on success', () {
      final code = '''
        local co = coroutine.create(function() end)
        local ok = coroutine.resume(co)
        return ok
      ''';
      ls.loadString(code);
      ls.pCall(0, 1, 0);
      expect(ls.toBoolean(-1), isTrue);
    });

    test('coroutine with arguments', () {
      final code = '''
        local co = coroutine.create(function(a, b)
          return a + b
        end)
        local ok, result = coroutine.resume(co, 10, 20)
        return result
      ''';
      ls.loadString(code);
      ls.pCall(0, 1, 0);
      expect(ls.toInteger(-1), equals(30));
    });

    test('coroutine.yield basic', () {
      final code = '''
        local co = coroutine.create(function()
          coroutine.yield(1)
          coroutine.yield(2)
          return 3
        end)
        local ok1, v1 = coroutine.resume(co)
        local ok2, v2 = coroutine.resume(co)
        local ok3, v3 = coroutine.resume(co)
        return v1, v2, v3
      ''';
      ls.loadString(code);
      ls.pCall(0, 3, 0);
      expect(ls.toInteger(-3), equals(1));
      expect(ls.toInteger(-2), equals(2));
      expect(ls.toInteger(-1), equals(3));
    });

    test('coroutine.status after completion', () {
      final code = '''
        local co = coroutine.create(function() end)
        coroutine.resume(co)
        return coroutine.status(co)
      ''';
      ls.loadString(code);
      ls.pCall(0, 1, 0);
      expect(ls.toStr(-1), equals('dead'));
    });

    test('coroutine.running returns current thread', () {
      final code = '''
        local co = coroutine.running()
        return type(co)
      ''';
      ls.loadString(code);
      ls.pCall(0, 1, 0);
      expect(ls.toStr(-1), equals('thread'));
    });

    test('coroutine.wrap creates resumable function', () {
      final code = '''
        local f = coroutine.wrap(function()
          coroutine.yield(100)
          return 200
        end)
        local v1 = f()
        local v2 = f()
        return v1, v2
      ''';
      ls.loadString(code);
      ls.pCall(0, 2, 0);
      expect(ls.toInteger(-2), equals(100));
      expect(ls.toInteger(-1), equals(200));
    });

    test('cannot resume dead coroutine', () {
      final code = '''
        local co = coroutine.create(function() end)
        coroutine.resume(co)  -- finishes
        local ok, msg = coroutine.resume(co)  -- try again
        return ok, msg
      ''';
      ls.loadString(code);
      ls.pCall(0, 2, 0);
      expect(ls.toBoolean(-2), isFalse);
      expect(ls.toStr(-1), contains('dead'));
    });
  });
}
