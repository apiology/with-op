.PHONY: clean clean-test clean-pyc clean-build docs test help typecheck quality
.DEFAULT_GOAL := default

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

default: quicktypecheck clean-coverage test coverage clean-mypy typecheck typecoverage ## run default typechecking and tests

# Does not support coverage reporting and may be unreliable - 'dmypy
# restart' should clear things up if so.
#
quicktypecheck: ## Use dmypy for cached mypy runs.
	@dmypy run --timeout 300 *.py tests with_op

# https://app.circleci.com/pipelines/github/apiology/cookiecutter-pypackage/281/workflows/b85985a9-16d0-42c4-93d4-f965a111e090/jobs/366
typecheck: ## run mypy against project
	mypy --cobertura-xml-report typecover --html-report typecover with_op
	mypy tests

citypecheck: typecheck ## Run type check from CircleCI

typecoverage: typecheck ## Run type checking and then ratchet coverage in metrics/mypy_high_water_mark
	@python setup.py mypy_ratchet

clean-mypy: ## Clean out mypy previous results to avoid flaky results
	@rm -fr .mypy_cache

citypecoverage: typecoverage ## Run type checking, ratchet coverage, and then complain if ratchet needs to be committed
	@echo "Looking for un-checked-in type coverage metrics..."
	@git status --porcelain metrics/mypy_high_water_mark
	@test -z "$$(git status --porcelain metrics/mypy_high_water_mark)"

clean: clean-build clean-pyc clean-test clean-mypy clean-coverage ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

requirements_dev.txt.installed: requirements_dev.txt
	pip install --disable-pip-version-check -r requirements_dev.txt -e .
	touch requirements_dev.txt.installed

pip_install: requirements_dev.txt.installed ## Install Python dependencies

Gemfile.lock.installed: Gemfile.lock
	bundle install
	touch Gemfile.lock.installed

bundle_install: Gemfile.lock.installed ## Install Ruby dependencies

lint: ## check style with flake8
	flake8 with_op tests

test-reports:
	mkdir test-reports

citest: test-reports test ## Run unit tests from CircleCI

test: ## run tests quickly with the default Python
	@coverage run --source with_op -m pytest

test-all: ## run tests on every Python version with tox
	tox

quality: ## run precommit quality checks
	bundle exec overcommit --run

clean-coverage: ## Clean out previous output of test coverage to avoid flaky results from previous runs
	@rm -fr .coverage

coverage: test ## check code coverage and then ratchet coverage in metrics/coverage_high_water_mark
	@coverage report -m
	@coverage html --directory=cover
	@coverage xml
	@python setup.py coverage_ratchet

cicoverage: coverage ## check code coverage, ratchet coverage, and then complain if ratchet needs to be committed
	@echo "Looking for un-checked-in unit test coverage metrics..."
	@git status --porcelain metrics/coverage_high_water_mark
	@test -z "$$(git status --porcelain metrics/coverage_high_water_mark)"

docs: ## generate Sphinx HTML documentation, including API docs
	rm -f docs/with_op.rst
	rm -f docs/modules.rst
	sphinx-apidoc -o docs/ with_op
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

servedocs: docs ## compile the docs watching for changes
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

release: dist ## package and upload a release
	set -e; \
	new_version=$$(python3 setup.py --version); \
	twine upload -u $$(with-op op get item 'PyPI - test' --fields username) -p $$(with-op op get item 'PyPI - test' --fields password) dist/op_env-$${new_version:?}.tar.gz -r testpypi; \
	twine upload -u $$(with-op op get item 'PyPI' --fields username) -p $$(with-op op get item 'PyPI' --fields password) dist/op_env-$${new_version:?}.tar.gz -r pypi

dist: clean ## builds source and wheel package
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist

install: clean ## install the package to the active Python's site-packages
	python setup.py install

update_from_cookiecutter: ## Bring in changes from template project used to create this repo
	bundle exec overcommit --uninstall
	IN_COOKIECUTTER_PROJECT_UPGRADER=1 cookiecutter_project_upgrader || true
	git checkout cookiecutter-template && git push && git checkout main
	git checkout main && git pull && git checkout -b update-from-cookiecutter-$$(date +%Y-%m-%d-%H%M)
	git merge cookiecutter-template || true
	bundle exec overcommit --install
	@echo
	@echo "Please resolve any merge conflicts below and push up a PR with:"
	@echo
	@echo '   gh pr create --title "Update from cookiecutter" --body "Automated PR to update from cookiecutter boilerplate"'
	@echo
	@echo
