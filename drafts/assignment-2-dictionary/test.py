import subprocess
import unittest
from pathlib import Path

APP = Path(__file__).resolve().parent / 'main'


class DictionaryCliTests(unittest.TestCase):
    def invoke(self, input_data):
        return subprocess.run([str(APP)], input=input_data, capture_output=True, timeout=3)

    def test_existing_keys(self):
        for key, meaning in [
            (b'first word', b'first word explanation\n'),
            (b'second word', b'second word explanation\n'),
            (b'third word', b'third word explanation\n'),
        ]:
            with self.subTest(key=key):
                p = self.invoke(key + b'\n')
                self.assertEqual((p.returncode, p.stdout, p.stderr), (0, meaning, b''))

    def test_missing_key_uses_stderr(self):
        p = self.invoke(b'missing\n')
        self.assertEqual(p.returncode, 1)
        self.assertEqual(p.stdout, b'')
        self.assertIn(b'not found', p.stderr)

    def test_prefix_is_not_a_match(self):
        self.assertEqual(self.invoke(b'first\n').returncode, 1)

    def test_empty_key(self):
        self.assertEqual(self.invoke(b'\n').returncode, 1)

    def test_eof_without_newline(self):
        self.assertEqual(self.invoke(b'first word').stdout, b'first word explanation\n')

    def test_maximum_length(self):
        p = self.invoke(b'a' * 255 + b'\n')
        self.assertEqual(p.returncode, 1)  # valid input, absent key
        self.assertIn(b'not found', p.stderr)

    def test_overlong_input(self):
        p = self.invoke(b'a' * 256 + b'\n')
        self.assertEqual(p.returncode, 2)
        self.assertEqual(p.stdout, b'')
        self.assertIn(b'exceeds 255', p.stderr)

    def test_overlong_input_even_when_followed_by_eof(self):
        self.assertEqual(self.invoke(b'a' * 256).returncode, 2)


if __name__ == '__main__':
    unittest.main()
