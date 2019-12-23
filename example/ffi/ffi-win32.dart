import 'dart:ffi';
import 'package:ffi/ffi.dart' as ffi;

const STD_INPUT_HANDLE = -10;
const STD_OUTPUT_HANDLE = -11;
const STD_ERROR_HANDLE = -12;

// HANDLE WINAPI GetStdHandle(
//   _In_ DWORD nStdHandle
// );
typedef getStdHandleNative = Int32 Function(Int32 nStdHandle);
typedef getStdHandleDart = int Function(int nStdHandle);

// BOOL WINAPI GetConsoleScreenBufferInfo(
//   _In_  HANDLE                      hConsoleOutput,
//   _Out_ PCONSOLE_SCREEN_BUFFER_INFO lpConsoleScreenBufferInfo
// );
typedef getConsoleScreenBufferInfoNative = Int8 Function(Int32 hConsoleOutput,
    Pointer<CONSOLE_SCREEN_BUFFER_INFO> lpConsoleScreenBufferInfo);
typedef getConsoleScreenBufferInfoDart = int Function(int hConsoleOutput,
    Pointer<CONSOLE_SCREEN_BUFFER_INFO> lpConsoleScreenBufferInfo);

// Requires an unpacking of COORD and SMALL_RECT because of
// missing support for nested structs
// (https://github.com/dart-lang/sdk/issues/37271)

// typedef struct _CONSOLE_SCREEN_BUFFER_INFO {
//   COORD      dwSize;
//   COORD      dwCursorPosition;
//   WORD       wAttributes;
//   SMALL_RECT srWindow;
//   COORD      dwMaximumWindowSize;
// } CONSOLE_SCREEN_BUFFER_INFO;
class CONSOLE_SCREEN_BUFFER_INFO extends Struct {
  @Int16()
  int dwSizeX;

  @Int16()
  int dwSizeY;

  @Int16()
  int dwCursorPositionX;
  @Int16()
  int dwCursorPositionY;

  @Int16()
  int wAttributes;

  @Int16()
  int srWindowLeft;
  @Int16()
  int srWindowTop;
  @Int16()
  int srWindowRight;
  @Int16()
  int srWindowBottom;

  @Int16()
  int dwMaximumWindowSizeX;
  @Int16()
  int dwMaximumWindowSizeY;
}

// typedef struct _COORD {
//   SHORT X;
//   SHORT Y;
// } COORD, *PCOORD;
class COORD extends Struct {
  @Int16()
  int X;

  @Int16()
  int Y;
}

// typedef struct _SMALL_RECT {
//   SHORT Left;
//   SHORT Top;
//   SHORT Right;
//   SHORT Bottom;
// } SMALL_RECT;
class SMALL_RECT extends Struct {
  @Int16()
  int Left;

  @Int16()
  int Top;

  @Int16()
  int Right;

  @Int16()
  int Bottom;
}

// BOOL WINAPI SetConsoleCursorPosition(
//   _In_ HANDLE hConsoleOutput,
//   _In_ COORD  dwCursorPosition
// );
typedef setConsoleCursorPositionNative = Int8 Function(
    Int32 hConsoleOutput, Int32 dwCursorPosition);
typedef setConsoleCursorPositionDart = int Function(
    int hConsoleOutput, int dwCursorPosition);

void main() {
  final kernel = DynamicLibrary.open('Kernel32.dll');

  final GetStdHandle = kernel
      .lookupFunction<getStdHandleNative, getStdHandleDart>('GetStdHandle');
  final GetConsoleScreenBufferInfo = kernel.lookupFunction<
      getConsoleScreenBufferInfoNative,
      getConsoleScreenBufferInfoDart>('GetConsoleScreenBufferInfo');
  final SetConsoleCursorPosition = kernel.lookupFunction<
      setConsoleCursorPositionNative,
      setConsoleCursorPositionDart>('SetConsoleCursorPosition');

  // stdout.write('\x1b[2J\x1b[H'); // clear screen and reset cursor to origin

  final outputHandle = GetStdHandle(STD_OUTPUT_HANDLE);
  print('Output handle (DWORD): $outputHandle');

  final pBufferInfo = ffi.allocate<CONSOLE_SCREEN_BUFFER_INFO>();
  var bufferInfo = pBufferInfo.ref;
  GetConsoleScreenBufferInfo(outputHandle, pBufferInfo);
  print('Window dimensions LTRB: (${bufferInfo.srWindowLeft}, '
      '${bufferInfo.srWindowTop}, ${bufferInfo.srWindowRight}, '
      '${bufferInfo.srWindowBottom})');
  print('Cursor position X/Y: (${bufferInfo.dwCursorPositionX}, '
      '${bufferInfo.dwCursorPositionY})');
  print('Window size X/Y: (${bufferInfo.dwSizeX}, ${bufferInfo.dwSizeY})');
  print('Maximum window size X/Y: (${bufferInfo.dwMaximumWindowSizeX}, '
      '${bufferInfo.dwMaximumWindowSizeY})');
  var cursorPosition = (15 << 16) + 3;

  SetConsoleCursorPosition(outputHandle, cursorPosition);
  GetConsoleScreenBufferInfo(outputHandle, pBufferInfo);
  print('Cursor position X/Y: (${bufferInfo.dwCursorPositionX}, '
      '${bufferInfo.dwCursorPositionY})');
}
