import re
import time
import diplomat


class CarpProc:
    def __init__(self):
        self.proc = diplomat.Diplomat('carp')
        self._version_info = None
        self.adornment_re = re.compile(".\[33m.*?\[0m")
        self.warning_re = re.compile("\[WARNING\] (.*)\n?")

    def wait_for_boot(self):
        while not self.proc.output():
            time.sleep(0.5)
        return self

    def version_info(self):
        if not self._version_info:
            self._version_info = list(self.proc.output_stream())[0].replace("Welcome to Carp ", "")[:-1]
        return self._version_info

    def read_output(self, old_output):
        while self.proc.output() == old_output:
            time.sleep(0.5)
        res = self.adornment_re.sub("", self.proc.output()[len(old_output):]).strip()
        warnings = self.warning_re.findall(res)
        res = self.warning_re.sub("", res)
        if res.startswith("=> "):
            return {'result': 'success', 'value': res[3:], 'warnings': warnings}
        if not res:
            return {'result': 'success', 'value': '()', 'warnings': warnings}
        return {'result': 'error', 'value': res, 'warnings': warnings}

    def evaluate(self, statements):
        assert self.proc.is_running(), "carp process has died"
        if not self._version_info:
            self.version_info()

        old_output = self.proc.output()
        self.proc._process.stdin.write(statements.encode("utf-8") + b"\n")
        self.proc._process.stdin.flush()
        return self.read_output(old_output)


def start_carp_proc():
    return CarpProc().wait_for_boot()
