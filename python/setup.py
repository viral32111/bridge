import setuptools

setuptools.setup(
	name = "bridge",
	description = "The internal communication library for my community game servers.",
	keywords = "python api interface library module development viral32111",

	version = "0.1.0",
	license = "AGPL-3.0-only",
	url = "https://github.com/viral32111/bridge",

	author = "viral32111",
	author_email = "contact@viral32111.com",

	python_requires = ">=3.9.2",
	packages = [ "bridge" ],

	classifiers = [
		"Development Status :: 3 - Alpha",
		"Intended Audience :: Developers",
		"Topic :: Internet",
		"Topic :: Software Development :: Libraries :: Python Modules",
		"License :: OSI Approved :: GNU Affero General Public License v3",
		"Programming Language :: Python :: 3.9",
		"Natural Language :: English",
		"Operating System :: OS Independent"
	]
)
