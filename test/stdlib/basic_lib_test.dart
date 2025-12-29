import 'package:lua_dardo_plus/lua.dart';
import 'package:test/test.dart';

void main() {
  group('Basic Library Tests', () {
    late LuaState lua;

    setUp(() {
      lua = LuaState.newState();
      lua.openLibs();
    });

    group('type()', () {
      test('should return correct types', () {
        lua.doString('''
          results = {
            type(nil),
            type(true),
            type(123),
            type(3.14),
            type("hello"),
            type({}),
            type(function() end)
          }
        ''');
        lua.getGlobal('results');

        lua.rawGetI(-1, 1);
        expect(lua.toStr(-1), equals('nil'));
        lua.pop(1);

        lua.rawGetI(-1, 2);
        expect(lua.toStr(-1), equals('boolean'));
        lua.pop(1);

        lua.rawGetI(-1, 3);
        expect(lua.toStr(-1), equals('number'));
        lua.pop(1);

        lua.rawGetI(-1, 4);
        expect(lua.toStr(-1), equals('number'));
        lua.pop(1);

        lua.rawGetI(-1, 5);
        expect(lua.toStr(-1), equals('string'));
        lua.pop(1);

        lua.rawGetI(-1, 6);
        expect(lua.toStr(-1), equals('table'));
        lua.pop(1);

        lua.rawGetI(-1, 7);
        expect(lua.toStr(-1), equals('function'));
        lua.pop(1);
      });
    });

    group('tonumber()', () {
      test('should convert strings to numbers', () {
        lua.doString('result = tonumber("123")');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(123));
      });

      test('should convert with base', () {
        lua.doString('result = tonumber("ff", 16)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(255));
      });

      test('should return nil for invalid input', () {
        lua.doString('result = tonumber("hello")');
        lua.getGlobal('result');
        expect(lua.isNil(-1), isTrue);
      });
    });

    group('tostring()', () {
      test('should convert numbers to strings', () {
        lua.doString('result = tostring(123)');
        lua.getGlobal('result');
        expect(lua.toStr(-1), equals('123'));
      });

      test('should convert booleans to strings', () {
        lua.doString('result = tostring(true)');
        lua.getGlobal('result');
        expect(lua.toStr(-1), equals('true'));
      });

      test('should convert nil to string', () {
        lua.doString('result = tostring(nil)');
        lua.getGlobal('result');
        expect(lua.toStr(-1), equals('nil'));
      });
    });

    group('ipairs()', () {
      test('should iterate over array portion', () {
        lua.doString('''
          t = {10, 20, 30}
          sum = 0
          for i, v in ipairs(t) do
            sum = sum + v
          end
        ''');
        lua.getGlobal('sum');
        expect(lua.toNumber(-1), equals(60));
      });
    });

    group('pairs()', () {
      test('should iterate over all keys', () {
        lua.doString('''
          t = {a = 1, b = 2, c = 3}
          sum = 0
          for k, v in pairs(t) do
            sum = sum + v
          end
        ''');
        lua.getGlobal('sum');
        expect(lua.toNumber(-1), equals(6));
      });
    });

    group('next()', () {
      test('should return next key-value pair', () {
        lua.doString('''
          t = {a = 1}
          k, v = next(t, nil)
        ''');
        lua.getGlobal('k');
        expect(lua.toStr(-1), equals('a'));
        lua.getGlobal('v');
        expect(lua.toNumber(-1), equals(1));
      });
    });

    group('select()', () {
      test('should select from index', () {
        lua.doString('result = select(2, "a", "b", "c")');
        lua.getGlobal('result');
        expect(lua.toStr(-1), equals('b'));
      });

      test('should return count with #', () {
        lua.doString('result = select("#", "a", "b", "c")');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(3));
      });
    });

    group('pcall()', () {
      test('should catch errors', () {
        lua.doString('''
          ok, err = pcall(function()
            error("test error")
          end)
        ''');
        lua.getGlobal('ok');
        expect(lua.toBoolean(-1), isFalse);
      });

      test('should return true on success', () {
        lua.doString('''
          ok, result = pcall(function()
            return 42
          end)
        ''');
        lua.getGlobal('ok');
        expect(lua.toBoolean(-1), isTrue);
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(42));
      });
    });

    group('xpcall()', () {
      test('should return false on error', () {
        lua.doString('''
          ok = xpcall(function()
            error("test")
          end, function(err)
            return err
          end)
        ''');
        lua.getGlobal('ok');
        expect(lua.toBoolean(-1), isFalse);
      });
    });

    group('assert()', () {
      test('should pass through truthy values', () {
        lua.doString('result = assert(123)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(123));
      });

      test('should return false via pcall on false', () {
        // doString uses pCall internally, so we check for failure
        lua.doString('''
          ok = pcall(function()
            assert(false, "custom error")
          end)
        ''');
        lua.getGlobal('ok');
        expect(lua.toBoolean(-1), isFalse);
      });
    });

    group('rawequal()', () {
      test('should compare without metamethods', () {
        lua.doString('''
          t1 = {}
          t2 = {}
          t3 = t1
          r1 = rawequal(t1, t2)
          r2 = rawequal(t1, t3)
        ''');
        lua.getGlobal('r1');
        expect(lua.toBoolean(-1), isFalse);
        lua.getGlobal('r2');
        expect(lua.toBoolean(-1), isTrue);
      });
    });

    group('rawget() and rawset()', () {
      test('should bypass metamethods', () {
        lua.doString('''
          t = {}
          setmetatable(t, {
            __index = function() return "meta" end,
            __newindex = function() end
          })
          rawset(t, "key", "direct")
          result = rawget(t, "key")
        ''');
        lua.getGlobal('result');
        expect(lua.toStr(-1), equals('direct'));
      });
    });

    group('rawlen()', () {
      test('should return length without metamethods', () {
        lua.doString('''
          t = {1, 2, 3}
          setmetatable(t, {__len = function() return 100 end})
          result = rawlen(t)
        ''');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(3));
      });
    });

    group('getmetatable() and setmetatable()', () {
      test('should set and get metatable', () {
        lua.doString('''
          t = {}
          mt = {__index = {x = 10}}
          setmetatable(t, mt)
          result = t.x
          gotMt = getmetatable(t) == mt
        ''');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(10));
        lua.getGlobal('gotMt');
        expect(lua.toBoolean(-1), isTrue);
      });
    });

    group('load()', () {
      test('should load and execute string', () {
        lua.doString('''
          f = load("return 1 + 2")
          result = f()
        ''');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(3));
      });
    });
  });
}
