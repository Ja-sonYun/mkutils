import fcntl
import os
import sys

ESC = "\x1b"
CTRL_C = "\x03"
CTRL_D = "\x04"

KEYS = {
    ESC + "[A": "up",
    ESC + "[B": "down",
    ESC + "[C": "right",
    ESC + "[D": "left",
    "k": "up",
    "j": "down",
    "\r": "enter",
    "\n": "enter",
    " ": "toggle",
    "q": "quit",
    CTRL_C: "quit",
    CTRL_D: "quit",
    "\x7f": "backspace",
    "\x08": "backspace",
    "\x01": "home",
    "\x05": "end",
    "\x17": "delete_word",
}


class ANSI:
    _no_color = bool(os.environ.get("NO_COLOR", ""))

    @classmethod
    def _wrap(cls, c, t):
        return t if cls._no_color else "\033[{}m{}\033[0m".format(c, t)

    @classmethod
    def cyan(cls, t):
        return cls._wrap(36, t)

    @classmethod
    def green(cls, t):
        return cls._wrap(32, t)

    @classmethod
    def red(cls, t):
        return cls._wrap(31, t)

    @staticmethod
    def cursor_up(n=1):
        return "\033[{}A".format(n)

    @staticmethod
    def clear_line():
        return "\033[2K"

    @staticmethod
    def hide_cursor():
        return "\033[?25l"

    @staticmethod
    def show_cursor():
        return "\033[?25h"


class TerminalWriter:
    def __init__(self, stream):
        self._stream = stream
        self._lines = 0
        self._partial = False

    def write(self, t):
        self._stream.write(t)
        if t:
            self._lines += t.count("\n")
            self._partial = not t.endswith("\n")

    def writeln(self, t=""):
        self._stream.write(ANSI.clear_line() + t + "\n")
        self._lines += 1
        self._partial = False

    def flush(self):
        self._stream.flush()

    def clear(self):
        if self._lines > 0 or self._partial:
            if self._lines > 0:
                self._stream.write(ANSI.cursor_up(self._lines))
            self._stream.write("\r\033[J")
        self._lines = 0
        self._partial = False


def char_width(ch):
    cp = ord(ch)
    if cp < 0x1100:
        return 1
    if 0x1100 <= cp <= 0x115F:  # Hangul Jamo
        return 2
    if 0x2E80 <= cp <= 0xA4CF:  # CJK Radicals ~ CJK Compat
        return 2
    if 0xAC00 <= cp <= 0xD7A3:  # Hangul Syllables
        return 2
    if 0xF900 <= cp <= 0xFAFF:  # CJK Compat Ideographs
        return 2
    if 0xFE10 <= cp <= 0xFE6F:  # Vertical/CJK Compat Forms
        return 2
    if 0xFF00 <= cp <= 0xFF60:  # Fullwidth Forms
        return 2
    if 0xFFE0 <= cp <= 0xFFE6:  # Fullwidth Symbols
        return 2
    if 0x20000 <= cp <= 0x2FFFD:  # CJK Extension B-F
        return 2
    return 1


def str_width(s):
    return sum(char_width(c) for c in s)


def get_key():
    import termios
    import tty

    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    old_flags = fcntl.fcntl(fd, fcntl.F_GETFL)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        if ch == ESC:
            fcntl.fcntl(fd, fcntl.F_SETFL, old_flags | os.O_NONBLOCK)
            try:
                ch += sys.stdin.read(2)
            except:
                pass
        elif ord(ch) >= 0x80:
            fcntl.fcntl(fd, fcntl.F_SETFL, old_flags | os.O_NONBLOCK)
            try:
                while True:
                    b = sys.stdin.read(1)
                    if not b:
                        break
                    ch += b
            except:
                pass
        return ch
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
        fcntl.fcntl(fd, fcntl.F_SETFL, old_flags)


def parse_option(raw):
    if raw.endswith("]") and "[" in raw:
        idx = raw.rfind("[")
        if idx >= 0:
            return raw[:idx], raw[idx + 1 : -1]
    return raw, ""


def parse_options(raw_options):
    return [{"value": v, "desc": d} for v, d in (parse_option(o) for o in raw_options)]


def option_label(opt):
    if opt["desc"]:
        return "{} - {}".format(opt["value"], opt["desc"])
    return opt["value"]


def select_ui(options, prompt, default):
    parsed = parse_options(options)
    values = [o["value"] for o in parsed]
    if not sys.stdin.isatty():
        return default if default in values else values[0]
    idx = values.index(default) if default in values else 0
    n = len(parsed)
    w = TerminalWriter(sys.stderr)

    def render(first=False):
        if not first:
            w.clear()
        w.writeln(ANSI.cyan("[?]") + " {}:".format(prompt))
        for i, opt in enumerate(parsed):
            label = option_label(opt)
            w.write(ANSI.cyan("> " + label) if i == idx else "  " + label)
            if i < n - 1:
                w.write("\n")
        w.flush()

    sys.stderr.write(ANSI.hide_cursor())
    render(first=True)
    while True:
        key = KEYS.get(get_key())
        if key == "up":
            idx = (idx - 1) % n
        elif key == "down":
            idx = (idx + 1) % n
        elif key == "enter":
            break
        elif key == "quit":
            sys.stderr.write(ANSI.show_cursor() + "\n" + ANSI.red("Aborted.") + "\n")
            sys.exit(1)
        render()
    w.clear()
    sys.stderr.write(
        ANSI.show_cursor()
        + ANSI.green("[OK]")
        + " {}: {}\n".format(prompt, values[idx])
    )
    return values[idx]


def select_multi_ui(options, prompt, defaults):
    parsed = parse_options(options)
    values = [o["value"] for o in parsed]
    if not sys.stdin.isatty():
        return defaults if defaults else []
    selected = set(i for i, v in enumerate(values) if v in set(defaults or []))
    idx, n = 0, len(parsed)
    w = TerminalWriter(sys.stderr)

    def render(first=False):
        if not first:
            w.clear()
        w.writeln(ANSI.cyan("[?]") + " {}:".format(prompt))
        for i, opt in enumerate(parsed):
            label = option_label(opt)
            chk = "[x]" if i in selected else "[ ]"
            w.write(
                ANSI.cyan("> {} {}".format(chk, label))
                if i == idx
                else "  {} {}".format(chk, label)
            )
            if i < n - 1:
                w.write("\n")
        w.flush()

    sys.stderr.write(ANSI.hide_cursor())
    render(first=True)
    while True:
        key = KEYS.get(get_key())
        if key == "up":
            idx = (idx - 1) % n
        elif key == "down":
            idx = (idx + 1) % n
        elif key == "toggle":
            selected.symmetric_difference_update({idx})
        elif key == "enter":
            break
        elif key == "quit":
            sys.stderr.write(ANSI.show_cursor() + "\n" + ANSI.red("Aborted.") + "\n")
            sys.exit(1)
        render()
    w.clear()
    result = [values[i] for i in sorted(selected)]
    sys.stderr.write(
        ANSI.show_cursor()
        + ANSI.green("[OK]")
        + " {}: {}\n".format(prompt, ", ".join(result) or "(none)")
    )
    return result


def input_ui(prompt, default=""):
    if not sys.stdin.isatty():
        return default
    buf, cur = list(default), len(default)
    pt = ANSI.cyan("[?]") + " {}: ".format(prompt)
    while True:
        t = "".join(buf)
        sys.stderr.write("\r" + ANSI.clear_line() + pt + t)
        if cur < len(buf):
            sys.stderr.write("\033[{}D".format(str_width("".join(buf[cur:]))))
        sys.stderr.flush()
        key = get_key()
        act = KEYS.get(key)
        if act == "enter":
            break
        elif act == "quit":
            sys.stderr.write("\n" + ANSI.red("Aborted.") + "\n")
            sys.exit(1)
        elif act == "left" and cur > 0:
            cur -= 1
        elif act == "right" and cur < len(buf):
            cur += 1
        elif act == "home":
            cur = 0
        elif act == "end":
            cur = len(buf)
        elif act == "backspace" and cur > 0:
            buf.pop(cur - 1)
            cur -= 1
        elif act == "delete_word" and cur > 0:
            while cur > 0 and not (buf[cur - 1].isalnum() or buf[cur - 1] == "_"):
                buf.pop(cur - 1)
                cur -= 1
            while cur > 0 and (buf[cur - 1].isalnum() or buf[cur - 1] == "_"):
                buf.pop(cur - 1)
                cur -= 1
        elif key and len(key) == 1 and key.isprintable():
            buf.insert(cur, key)
            cur += 1
    result = "".join(buf) or default
    sys.stderr.write(
        "\r"
        + ANSI.clear_line()
        + ANSI.green("[OK]")
        + " {}: {}\n".format(prompt, result)
    )
    return result


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == "select":
        print(
            select_ui(
                sys.argv[2].split("|"),
                sys.argv[3] if len(sys.argv) > 3 else "Select",
                sys.argv[4] if len(sys.argv) > 4 else "",
            )
        )
    elif cmd == "select-multi":
        for i in select_multi_ui(
            sys.argv[2].split("|"),
            sys.argv[3] if len(sys.argv) > 3 else "Select",
            sys.argv[4].split("|") if len(sys.argv) > 4 else [],
        ):
            print(i)
    elif cmd == "input":
        print(
            input_ui(
                sys.argv[2] if len(sys.argv) > 2 else "Input",
                sys.argv[3] if len(sys.argv) > 3 else "",
            )
        )
