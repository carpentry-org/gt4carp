import subprocess


class CarpProc:
    def __init__(self):
        self.proc = subprocess.Popen(['carp'])

    def evaluate(self, statements):
        self.proc.stdin.send(statements)


def start_carp_proc():
    return CarpProc()
