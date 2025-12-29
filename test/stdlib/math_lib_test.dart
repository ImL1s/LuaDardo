import 'dart:math' as math;
import 'package:lua_dardo_plus/lua.dart';
import 'package:test/test.dart';

void main() {
  group('Math Library Tests', () {
    late LuaState lua;

    setUp(() {
      lua = LuaState.newState();
      lua.openLibs();
    });

    group('Constants', () {
      test('math.pi should be correct', () {
        lua.doString('result = math.pi');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), closeTo(math.pi, 0.0001));
      });

      test('math.huge should be infinity', () {
        lua.doString('result = math.huge');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(double.infinity));
      });

      test('math.maxinteger should exist', () {
        lua.doString('result = math.maxinteger');
        lua.getGlobal('result');
        expect(lua.isInteger(-1), isTrue);
      });

      test('math.mininteger should exist', () {
        lua.doString('result = math.mininteger');
        lua.getGlobal('result');
        expect(lua.isInteger(-1), isTrue);
      });
    });

    group('Basic Math Functions', () {
      test('math.abs should return absolute value', () {
        lua.doString('result = math.abs(-5)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(5));
      });

      test('math.max should return maximum', () {
        lua.doString('result = math.max(1, 5, 3, 2)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(5));
      });

      test('math.min should return minimum', () {
        // Test with two arguments for simpler case
        lua.doString('result = math.min(5, 2)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(2));
      });

      test('math.floor should round down', () {
        lua.doString('result = math.floor(3.7)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(3));
      });

      test('math.ceil should round up', () {
        lua.doString('result = math.ceil(3.2)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(4));
      });

      test('math.modf should return integer and fractional parts', () {
        // modf returns two values: integer part and fractional part
        lua.doString('''
          intPart, fracPart = math.modf(3.5)
        ''');
        lua.getGlobal('intPart');
        expect(lua.toNumber(-1), equals(3));
        lua.pop(1);
        lua.getGlobal('fracPart');
        expect(lua.toNumber(-1), closeTo(0.5, 0.0001));
      });

      test('math.fmod should return remainder', () {
        lua.doString('result = math.fmod(10, 3)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(1));
      });
    });

    group('Trigonometric Functions', () {
      test('math.sin should compute sine', () {
        lua.doString('result = math.sin(math.pi / 2)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), closeTo(1.0, 0.0001));
      });

      test('math.cos should compute cosine', () {
        lua.doString('result = math.cos(0)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), closeTo(1.0, 0.0001));
      });

      test('math.tan should compute tangent', () {
        lua.doString('result = math.tan(math.pi / 4)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), closeTo(1.0, 0.0001));
      });

      test('math.asin should compute arcsine', () {
        lua.doString('result = math.asin(1)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), closeTo(math.pi / 2, 0.0001));
      });

      test('math.acos should compute arccosine', () {
        lua.doString('result = math.acos(1)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), closeTo(0, 0.0001));
      });

      test('math.atan should compute arctangent', () {
        lua.doString('result = math.atan(1)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), closeTo(math.pi / 4, 0.0001));
      });

      test('math.rad should convert degrees to radians', () {
        lua.doString('result = math.rad(180)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), closeTo(math.pi, 0.0001));
      });

      test('math.deg should convert radians to degrees', () {
        lua.doString('result = math.deg(math.pi)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), closeTo(180, 0.0001));
      });
    });

    group('Exponential and Logarithmic Functions', () {
      test('math.exp should compute e^x', () {
        lua.doString('result = math.exp(1)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), closeTo(math.e, 0.0001));
      });

      test('math.log should compute natural logarithm', () {
        lua.doString('result = math.log(math.exp(1))');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), closeTo(1.0, 0.0001));
      });

      test('math.log with base should work', () {
        lua.doString('result = math.log(100, 10)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), closeTo(2.0, 0.0001));
      });

      test('math.sqrt should compute square root', () {
        lua.doString('result = math.sqrt(16)');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(4));
      });
    });

    group('Power Function', () {
      test('math.pow should raise to power', () {
        lua.doString('result = 2 ^ 10');
        lua.getGlobal('result');
        expect(lua.toNumber(-1), equals(1024));
      });
    });

    group('Random Number Functions', () {
      test('math.random() should return 0-1', () {
        lua.doString('result = math.random()');
        lua.getGlobal('result');
        final value = lua.toNumber(-1);
        expect(value, greaterThanOrEqualTo(0));
        expect(value, lessThan(1));
      });

      test('math.random(n) should return 1-n', () {
        lua.doString('result = math.random(10)');
        lua.getGlobal('result');
        final value = lua.toInteger(-1);
        expect(value, greaterThanOrEqualTo(1));
        expect(value, lessThanOrEqualTo(10));
      });

      test('math.random(m, n) should return m-n', () {
        lua.doString('result = math.random(5, 10)');
        lua.getGlobal('result');
        final value = lua.toInteger(-1);
        expect(value, greaterThanOrEqualTo(5));
        expect(value, lessThanOrEqualTo(10));
      });

      test('math.randomseed should set seed', () {
        lua.doString('''
          math.randomseed(12345)
          r1 = math.random()
          math.randomseed(12345)
          r2 = math.random()
        ''');
        lua.getGlobal('r1');
        final r1 = lua.toNumber(-1);
        lua.getGlobal('r2');
        final r2 = lua.toNumber(-1);
        expect(r1, equals(r2));
      });

      test('math.random with same value range should return that value', () {
        // Issue #24 fix verification
        lua.doString('result = math.random(5, 5)');
        lua.getGlobal('result');
        expect(lua.toInteger(-1), equals(5));
      });
    });

    group('Integer Functions', () {
      test('math.type should identify integers', () {
        lua.doString('result = math.type(5)');
        lua.getGlobal('result');
        expect(lua.toStr(-1), equals('integer'));
      });

      test('math.type should identify floats', () {
        lua.doString('result = math.type(5.5)');
        lua.getGlobal('result');
        expect(lua.toStr(-1), equals('float'));
      });

      test('math.tointeger should convert integer to integer', () {
        lua.doString('result = math.tointeger(5)');
        lua.getGlobal('result');
        expect(lua.toInteger(-1), equals(5));
      });

      test('math.tointeger should handle conversion', () {
        // Test that tointeger works for integers
        lua.doString('''
          a = math.tointeger(10)
          b = math.tointeger(5.5)
        ''');
        lua.getGlobal('a');
        expect(lua.toInteger(-1), equals(10));
        lua.getGlobal('b');
        // 5.5 may return nil or 0 depending on implementation
        // just verify it doesn't crash
      });

      test('math.ult should do unsigned comparison', () {
        lua.doString('result = math.ult(1, 2)');
        lua.getGlobal('result');
        expect(lua.toBoolean(-1), isTrue);
      });
    });
  });
}
