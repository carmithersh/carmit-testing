#!/usr/bin/env python

from setuptools import setup

setup(
    name='jfrog-python-example',
    version='1.8',
    description='Project example for building Python project with JFrog products.',
    author='JFrog',
    author_email='jfrog@jfrog.com',
    url='https://github.com/carmithersh/carmit-testing',
    packages=['pythonExample'],
    install_requires=['PyYAML>3.11', 'nltk'],
)
