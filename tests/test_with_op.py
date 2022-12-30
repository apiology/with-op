#!/usr/bin/env python

"""Tests for `with_op` package."""

# from with_op import with_op

import pytest

import with_op


@pytest.fixture
def response():
    """Sample pytest fixture.

    See more at: http://doc.pytest.org/en/latest/fixture.html
    """
    # import requests
    # return requests.get('https://github.com/audreyr/cookiecutter-pypackage')


def test_dunders(response):
    assert with_op.__author__ is not None
    assert with_op.__email__ is not None
    assert with_op.__version__ is not None
