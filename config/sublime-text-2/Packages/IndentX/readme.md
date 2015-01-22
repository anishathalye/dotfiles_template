# IndentX

A basic xml indentation plugin for sublime.

This plugin was inspired by [Indent Xml](https://sublime.wbond.net/packages/Indent%20XML).

The main difference with this impelementation being:

* It is very dumb - it looks for open and close tags only
	* When an open tag is found, it will increase indent by one
	* When a close tag is found, it will decrease indent by one
* It doesn't require valid XML
	* One of the short comings of [Indent Xml](https://sublime.wbond.net/packages/Indent%20XML) is that it only worked with valid XML
* It doesn't re-order your attributes
	* [Indent Xml](https://sublime.wbond.net/packages/Indent%20XML) re-orders XML attributes

## Installation

Install using Package Control.
