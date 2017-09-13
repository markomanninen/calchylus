from distutils.core import setup

install_requires = ['hy>=0.13.0']

#python setup.py register -r pypitest
#python setup.py register -r pypi
# next command not recommended but what can you do in Windows...
#python setup.py sdist upload -r pypitest
#python setup.py sdist upload
# 08/2017 windows: python setup.py sdist upload -r https://www.python.org/pypi

setup(
  name = 'calchylus',

  packages = ['calchylus'],
  package_dir = {'calchylus': 'calchylus'},
  package_data = {
    'calchylus': ['*.hy']
  },

  version = 'v0.1.0',
  description = 'Calchylus - Lambda Calculus with Hy',
  author = 'Marko Manninen',
  author_email = 'elonmedia@gmail.com',

  url = 'https://github.com/markomanninen/calchylus',
  download_url = 'https://github.com/markomanninen/calchylus/archive/v0.1.0.tar.gz',
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
