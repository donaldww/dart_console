import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart' as ffi;

// int tcgetattr(int, struct termios *);
typedef tcgetattrNative = Int32 Function(
    Int32 fildes, Pointer<TermIOS> termios);
typedef tcgetattrDart = int Function(int fildes, Pointer<TermIOS> termios);

// int tcsetattr(int, int, const struct termios *);
typedef tcsetattrNative = Int32 Function(
    Int32 fildes, Int32 optional_actions, Pointer<TermIOS> termios);
typedef tcsetattrDart = int Function(
    int fildes, int optional_actions, Pointer<TermIOS> termios);

const STDIN_FILENO = 0;
const STDOUT_FILENO = 1;
const STDERR_FILENO = 2;

// INPUT FLAGS
const int IGNBRK = 0x00000001; // ignore BREAK condition
const int BRKINT = 0x00000002; // map BREAK to SIGINTR
const int IGNPAR = 0x00000004; // ignore (discard) parity errors
const int PARMRK = 0x00000008; // mark parity and framing errors
const int INPCK = 0x00000010; // enable checking of parity errors
const int ISTRIP = 0x00000020; // strip 8th bit off chars
const int INLCR = 0x00000040; // map NL into CR
const int IGNCR = 0x00000080; // ignore CR
const int ICRNL = 0x00000100; // map CR to NL (ala CRMOD)
const int IXON = 0x00000200; // enable output flow control
const int IXOFF = 0x00000400; // enable input flow control
const int IXANY = 0x00000800; // any char will restart after stop
const int IMAXBEL = 0x00002000; // ring bell on input queue full
const int IUTF8 = 0x00004000; // maintain state for UTF-8 VERASE

// OUTPUT FLAGS
const int OPOST = 0x00000001; // enable following output processing
const int ONLCR = 0x00000002; // map NL to CR-NL (ala CRMOD)
const int OXTABS = 0x00000004; // expand tabs to spaces
const int ONOEOT = 0x00000008; // discard EOT's (^D) on output)

// CONTROL FLAGS
const int CIGNORE = 0x00000001; // ignore control flags
const int CSIZE = 0x00000300; // character size mask
const int CS5 = 0x00000000; // 5 bits (pseudo)
const int CS6 = 0x00000100; // 6 bits
const int CS7 = 0x00000200; // 7 bits
const int CS8 = 0x00000300; // 8 bits

// LOCAL FLAGS
const int ECHOKE = 0x00000001; // visual erase for line kill
const int ECHOE = 0x00000002; // visually erase chars
const int ECHOK = 0x00000004; // echo NL after line kill
const int ECHO = 0x00000008; // enable echoing
const int ECHONL = 0x00000010; // echo NL even if ECHO is off
const int ECHOPRT = 0x00000020; // visual erase mode for hardcopy
const int ECHOCTL = 0x00000040; // echo control chars as ^(Char)
const int ISIG = 0x00000080; // enable signals INTR, QUIT, [D]SUSP
const int ICANON = 0x00000100; // canonicalize input lines
const int ALTWERASE = 0x00000200; // use alternate WERASE algorithm
const int IEXTEN = 0x00000400; // enable DISCARD and LNEXT
const int EXTPROC = 0x00000800; // external processing
const int TOSTOP = 0x00400000; // stop background jobs from output
const int FLUSHO = 0x00800000; // output being flushed (state)
const int NOKERNINFO = 0x02000000; // no kernel output from VSTATUS
const int PENDIN = 0x20000000; // XXX retype pending input (state)
const int NOFLSH = 0x80000000; // don't flush after interrupt

const int TCSANOW = 0; // make change immediate
const int TCSADRAIN = 1; // drain output, then change
const int TCSAFLUSH = 2; // drain output, flush input

const int VMIN = 16; // minimum number of characters to receive
const int VTIME = 17; // time in 1/10s before returning

// typedef unsigned long   tcflag_t;
// typedef unsigned char   cc_t;
// typedef unsigned long   speed_t;
// #define NCCS            20

// struct termios {
// 	tcflag_t        c_iflag;        /* input flags */
// 	tcflag_t        c_oflag;        /* output flags */
// 	tcflag_t        c_cflag;        /* control flags */
// 	tcflag_t        c_lflag;        /* local flags */
// 	cc_t            c_cc[NCCS];     /* control chars */
// 	speed_t         c_ispeed;       /* input speed */
// 	speed_t         c_ospeed;       /* output speed */
// };
class TermIOS extends Struct {
  @Int64()
  int c_iflag;
  @Int64()
  int c_oflag;
  @Int64()
  int c_cflag;
  @Int64()
  int c_lflag;

  @Int8()
  int c_cc0;
  @Int8()
  int c_cc1;
  @Int8()
  int c_cc2;
  @Int8()
  int c_cc3;
  @Int8()
  int c_cc4;
  @Int8()
  int c_cc5;
  @Int8()
  int c_cc6;
  @Int8()
  int c_cc7;
  @Int8()
  int c_cc8;
  @Int8()
  int c_cc9;
  @Int8()
  int c_cc10;
  @Int8()
  int c_cc11;
  @Int8()
  int c_cc12;
  @Int8()
  int c_cc13;
  @Int8()
  int c_cc14;
  @Int8()
  int c_cc15;
  @Int8()
  int c_cc16; // VMIN
  @Int8()
  int c_cc17; // VTIME
  @Int8()
  int c_cc18;
  @Int8()
  int c_cc19;

  @Int64()
  int c_ispeed;
  @Int64()
  int c_ospeed;
}

void main() {
  final libc = Platform.isMacOS
      ? DynamicLibrary.open('/usr/lib/libSystem.dylib')
      : DynamicLibrary.open('libc-2.28.so');

  final tcgetattr =
      libc.lookupFunction<tcgetattrNative, tcgetattrDart>('tcgetattr');
  final tcsetattr =
      libc.lookupFunction<tcsetattrNative, tcsetattrDart>('tcsetattr');

  final origTermIOSPointer = ffi.allocate<TermIOS>();
  var result = tcgetattr(STDIN_FILENO, origTermIOSPointer);
  print('result is $result');

  var origTermIOS = origTermIOSPointer.ref;

  print('origTermIOS.c_iflag: 0b${origTermIOS.c_iflag.toRadixString(2)}');
  print('Copying and modifying...');

  final newTermIOSPointer = ffi.allocate<TermIOS>();
  var newTermIOS = newTermIOSPointer.ref;

  newTermIOS.c_iflag =
      origTermIOS.c_iflag & ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
  newTermIOS.c_oflag = origTermIOS.c_oflag & ~(OPOST);
  newTermIOS.c_cflag = origTermIOS.c_cflag | (CS8);
  newTermIOS.c_lflag = origTermIOS.c_lflag & ~(ECHO | ICANON | IEXTEN | ISIG);
  newTermIOS.c_ispeed = origTermIOS.c_ispeed;
  newTermIOS.c_oflag = origTermIOS.c_ospeed;
  newTermIOS.c_cc0 = origTermIOS.c_cc0;
  newTermIOS.c_cc1 = origTermIOS.c_cc1;
  newTermIOS.c_cc2 = origTermIOS.c_cc2;
  newTermIOS.c_cc3 = origTermIOS.c_cc3;
  newTermIOS.c_cc4 = origTermIOS.c_cc4;
  newTermIOS.c_cc5 = origTermIOS.c_cc5;
  newTermIOS.c_cc6 = origTermIOS.c_cc6;
  newTermIOS.c_cc7 = origTermIOS.c_cc7;
  newTermIOS.c_cc8 = origTermIOS.c_cc8;
  newTermIOS.c_cc9 = origTermIOS.c_cc9;
  newTermIOS.c_cc10 = origTermIOS.c_cc10;
  newTermIOS.c_cc11 = origTermIOS.c_cc11;
  newTermIOS.c_cc12 = origTermIOS.c_cc12;
  newTermIOS.c_cc13 = origTermIOS.c_cc13;
  newTermIOS.c_cc14 = origTermIOS.c_cc14;
  newTermIOS.c_cc15 = origTermIOS.c_cc15;
  newTermIOS.c_cc16 = 0;
  newTermIOS.c_cc17 = 1;
  newTermIOS.c_cc18 = origTermIOS.c_cc18;
  newTermIOS.c_cc19 = origTermIOS.c_cc19;

  print('origTermIOS.c_iflag: 0b${origTermIOS.c_iflag.toRadixString(2)}');
  print('newTermIOS.c_iflag:  0b${newTermIOS.c_iflag.toRadixString(2)}');
  print('origTermIOS.c_oflag: 0b${origTermIOS.c_oflag.toRadixString(2)}');
  print('newTermIOS.c_oflag:  0b${newTermIOS.c_oflag.toRadixString(2)}');
  print('origTermIOS.c_cflag: 0b${origTermIOS.c_cflag.toRadixString(2)}');
  print('newTermIOS.c_cflag:  0b${newTermIOS.c_cflag.toRadixString(2)}');
  print('origTermIOS.c_lflag: 0b${origTermIOS.c_lflag.toRadixString(2)}');
  print('newTermIOS.c_lflag:  0b${newTermIOS.c_lflag.toRadixString(2)}');

  result = tcsetattr(STDIN_FILENO, TCSAFLUSH, newTermIOS.addressOf);
  print('result is $result\n');

  print('RAW MODE: Here is some text.\nHere is some more text.');
  result = tcsetattr(STDIN_FILENO, TCSAFLUSH, origTermIOS.addressOf);
  print('result is $result\n');

  print('\nORIGINAL MODE: Here is some text.\nHere is some more text.');

  ffi.free(origTermIOSPointer);
  ffi.free(newTermIOSPointer);
}
