# TODO and ideas

## Fields

* Fields should be layout nodes only.
* Actual rendering of field should be outside object which can be plugged-in.
* Config has list of attributes/rules for each field as well as the class name to use to render the field.
* Remove the text object and use a field instead with a test renderer.

Have a `Crossbeams::Layout::Element` class and input, select, email, tel, number, link etc inherit from it.

## Hidden and invisible

* Each part of the layout has a hidden? and invisible? method.
* Collections ask their nodes and return true if true for all nodes.
* Fields return true or false based on the rendering specs.

## Tests

* Need to set up tests where HTML result can easily be checked.

## IDs

* Find a strategy for creating unique ids in a layout that can be addressed in JS if required?

## Non-data-bound values

* Did a quick kludge on hidden fields to manage a non-data object value.
* Need to rethink and do something more intelligent...
