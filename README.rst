==============
with-op script
==============


.. image:: https://circleci.com/gh/apiology/with-op.svg?style=svg
    :target: https://circleci.com/gh/apiology/with-op

.. image:: https://img.shields.io/pypi/v/with-op.svg
        :target: https://pypi.python.org/pypi/with-op

.. image:: https://readthedocs.org/projects/with-op/badge/?version=latest
        :target: https://with-op.readthedocs.io/en/latest/?badge=latest
        :alt: Documentation Status

Script to stash 1Password CLI 2.x credentials into local keychain


* Free software: MIT license
* Documentation: https://with-op.readthedocs.io.


Setup
-----

1. Install `1Password command-line tool <https://developer.1password.com/docs/cli>`_ - `brew install --cask 1password-cli`, for instance.
2. Install `jq <https://stedolan.github.io/jq/>`_ dependency - `brew install jq`, for instance.
3. Install `with-op` - `pip3 install with_op`
4. Invoke: `with-op op get item "My login to some site"`

Features
--------

* Installs session keys into your OS keychain instead of in a single shell's environment.
* Once one user window authenticates with `op`, all that are authorized to see the keychain are authorized to use `op`.
* `with-op` will re-prompt for your password when your session expires.

Credits
-------

This package was created with Cookiecutter_ and the `audreyr/cookiecutter-pypackage`_ project template.

.. _Cookiecutter: https://github.com/audreyr/cookiecutter
.. _`audreyr/cookiecutter-pypackage`: https://github.com/audreyr/cookiecutter-pypackage
