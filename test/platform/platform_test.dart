import 'package:lua_dardo_plus/lua.dart';
import 'package:lua_dardo_plus/src/platform/platform.dart';
import 'package:test/test.dart';

void main() {
  group('Platform Abstraction Layer Tests', () {
    group('PlatformServices singleton', () {
      test('should return same instance', () {
        final instance1 = PlatformServices.instance;
        final instance2 = PlatformServices.instance;
        expect(identical(instance1, instance2), isTrue);
      });

      test('should report isWeb correctly for native', () {
        expect(PlatformServices.instance.isWeb, isFalse);
      });

      test('should support file system on native', () {
        expect(PlatformServices.instance.supportsFileSystem, isTrue);
      });

      test('should support process on native', () {
        expect(PlatformServices.instance.supportsProcess, isTrue);
      });
    });

    group('Print callback', () {
      test('should allow custom print callback', () {
        final outputs = <String>[];
        final originalCallback = PlatformServices.instance.printCallback;

        PlatformServices.instance.printCallback = (s) {
          outputs.add(s);
        };

        try {
          final lua = LuaState.newState();
          lua.openLibs();
          lua.doString('print("test message")');

          expect(outputs.any((s) => s.contains('test message')), isTrue);
        } finally {
          PlatformServices.instance.printCallback = originalCallback;
        }
      });
    });

    group('Path separator', () {
      test('should return valid path separator', () {
        final sep = PlatformServices.instance.pathSeparator;
        expect(sep == '/' || sep == '\\', isTrue);
      });
    });

    group('Environment variables', () {
      test('should be able to get PATH', () {
        final path = PlatformServices.instance.getEnvironmentVariable('PATH');
        // PATH should exist on most systems
        expect(path, isNotNull);
      });

      test('should return null for non-existent variable', () {
        final value = PlatformServices.instance
            .getEnvironmentVariable('NON_EXISTENT_VAR_12345');
        expect(value, isNull);
      });
    });

    group('File operations', () {
      test('should detect non-existent file', () {
        final exists = PlatformServices.instance
            .fileExists('/non/existent/path/file.txt');
        expect(exists, isFalse);
      });

      test('should detect non-existent directory', () {
        final exists = PlatformServices.instance
            .directoryExists('/non/existent/path');
        expect(exists, isFalse);
      });

      test('should return null for non-existent file read as bytes', () {
        final bytes = PlatformServices.instance
            .readFileAsBytes('/non/existent/file.txt');
        expect(bytes, isNull);
      });

      test('should return null for non-existent file read as string', () {
        final content = PlatformServices.instance
            .readFileAsString('/non/existent/file.txt');
        expect(content, isNull);
      });

      test('should return false for deleting non-existent file', () {
        final result = PlatformServices.instance
            .deleteFile('/non/existent/file.txt');
        expect(result, isFalse);
      });

      test('should return false for renaming non-existent file', () {
        final result = PlatformServices.instance
            .renameFile('/non/existent/old.txt', '/non/existent/new.txt');
        expect(result, isFalse);
      });
    });

    group('Process operations', () {
      test('should run simple command', () {
        // 'echo' should exist on all platforms
        final exitCode = PlatformServices.instance.runProcess('echo', ['test']);
        expect(exitCode, equals(0));
      });

      test('should return null for non-existent command', () {
        final exitCode = PlatformServices.instance
            .runProcess('non_existent_command_12345', []);
        expect(exitCode, isNull);
      });
    });

    group('Lua integration with platform', () {
      late LuaState lua;

      setUp(() {
        lua = LuaState.newState();
        lua.openLibs();
      });

      test('os.getenv should use platform services', () {
        lua.doString('result = os.getenv("PATH")');
        lua.getGlobal('result');
        // PATH should be available
        expect(lua.isString(-1), isTrue);
      });

      test('print should use platform services callback', () {
        final outputs = <String>[];
        final originalCallback = PlatformServices.instance.printCallback;

        PlatformServices.instance.printCallback = (s) {
          outputs.add(s);
        };

        try {
          lua.doString('print("hello", "world")');
          expect(outputs.join(), contains('hello'));
          expect(outputs.join(), contains('world'));
        } finally {
          PlatformServices.instance.printCallback = originalCallback;
        }
      });

      test('package.config should have correct separator', () {
        lua.doString('result = package.config:sub(1,1)');
        lua.getGlobal('result');
        final sep = lua.toStr(-1);
        expect(sep == '/' || sep == '\\', isTrue);
      });
    });

    group('Platform reset', () {
      test('should allow resetting platform services', () {
        final outputs = <String>[];
        final originalCallback = PlatformServices.instance.printCallback;

        PlatformServices.instance.printCallback = (s) {
          outputs.add(s);
        };

        // Reset by calling reset
        PlatformServices.reset();

        // After reset, should use default print again
        final newInstance = PlatformServices.instance;
        expect(newInstance.printCallback, isNot(equals(originalCallback)));

        // Restore for other tests
        PlatformServices.instance.printCallback = originalCallback;
      });
    });
  });
}
