# painter

A simple flutter widget to paint with your fingers.

## Features

The widget supports:
- Changing fore- and background color
- Changing the thickness of lines you draw
- Exporting your painting as png
- Undo drawing a line
- Clearing the hole drawing

## Some Notes

- After calling 'finish()' on a PainterController you can't draw on this painting any more
- To create a new painting after finishing the old one simply create a new PainterController
- Calling 'finish()' for the first time will render the drawing. Successive calls will then return a cached version of the rendered picture 

## Example

For a full example take a look at the [example project](https://github.com/epnw/painter/tree/master/example).
Here is a short recording showing it.
Note that the color picker is an external dependency which is only required for the example.

![demo!](https://raw.githubusercontent.com/epnw/painter/master/example/demo.gif)