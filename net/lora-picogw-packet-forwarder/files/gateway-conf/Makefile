.PHONY: deps default

default: configs.txt

deps:
	pip install PyYAML

configs.txt: frequency-plans.yml
	python script/generate-configs.py
