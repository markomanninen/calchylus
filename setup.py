try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup
import os

#python setup.py register -r pypitest
#python setup.py register -r pypi
# next command not recommended but what can you do in Windows...
#python setup.py sdist upload -r pypitest
#python setup.py sdist upload
# 08/2017 windows: python setup.py sdist upload

def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname), encoding="utf8").read()

setup(
  name = 'calchylus',
  packages = ['calchylus'],
  package_dir = {'calchylus': 'calchylus'},
  package_data = {
    'calchylus': ['*.hy']
  },
  install_requires = ['hy>=0.13.0'],
  version = 'v0.1.3',
  description = 'Calchylus - Lambda Calculus with Hy',
  long_description = read('README'),
  author = 'Marko Manninen',
  author_email = 'elonmedia@gmail.com',

  url = 'https://github.com/markomanninen/calchylus',
  download_url = 'https://github.com/markomanninen/calchylus/archive/v0.1.3.tar.gz',
  keywords = ['hylang', 'python', 'lisp', 'macros', 'dsl', 'lambda calculus', 'functional language'],
  platforms = ['any'],

  classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Operating System :: OS Independent",
    "Programming Language :: Lisp",
    "Topic :: Software Development :: Libraries",
  ]
)
