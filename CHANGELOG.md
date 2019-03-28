# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres roughly to [Semantic Versioning](http://semver.org/).


## [Unreleased]
### Added
### Changed
### Fixed

## [0.2.1] - 2019-03-28
### Changed
- Link control: new options: `id` and `visible`.
  Id becomes the anchor's DOM id.
  If visible is false, the anchor will be rendered with attribute `hidden`.
- Text control uses `hidden` attribute for the toggle target, instead of `display:none`.

## [0.2.0] - 2019-02-26
### Added
- New Lookup control - render a button to link to a grid to lookup a row.
- New FoldUp control - nodes inside the control are folded-up using HTML5 `display` tag. A mouse click toggles the open/close state.

## [0.1.15] - 2019-02-04
### Added
- The div surrounding an input field gets a DOM id (the field's id with "_wrapper" appended). Useful to hide/show an input and its label.
- Form can render a caption above non-remote forms.
- Table can render a caption.
- Table can be rendered with a top margin which can be in the range 0 to 7.
- Link can be styled as a small button.
### Changed
- Checkbox and Multi can be disabled.

## [0.1.14] - 2019-01-25
### Added
- New control: `Notice`. Use it to display highlighted text as a warning, error, info or success notice.

## [0.1.13] - 2018-11-19
### Added
- Table renderer can render pivoted (columns become rows).
- A link can have a prompt which will force the user to confirm their action or cancel it.
- An input can validate ip v4 format ip addresses.
- A link can load in a new window if the `loading_window` option is set.
- New icons: `back` and `newwindow`.
### Changed
- List and SortableList get `add_csrf` methods that are noop.
- Selectr select will send an empty parameter when options are cleared.
### Fixed
- Return String value for input if a date/time is passed in as a string.

## [0.1.12] - 2018-10-26
### Added
- Grid trees can open collapsed or expanded to any level.
- Text can be toggled based on an id within the text - rather than only on the id of the wrapper around the text.
- Link can store the grid-id in the datalist (`data-grid-id`).
- Label has a new option - `:css_class` - for specifying additional CSS classes.
- Table has a new option - `:header_captions` - for overriding the captions in the table header.
- Link gets new behaviour - `:replace_dialog`. It should only be set for a link displayed in a dialog. When the link is clicked, the current dialog's contents will be replaced by calling the link's href.
### Changed
- `FieldFactory` renders `date`, `time` and `datetime` as `Input` renderers (don't have to specify subtype in the config).
### Fixed
- Inputs for `date`, `datetime` and `time` handle null values correctly.

## [0.1.11] - 2018-08-31
### Added
- Select can have `required` attribute set. This is just for styling by the Selectr javascript library.
- Forms can display validation errors for the `:base` of the form.
- Forms can have a DOM id set.
- Grids can render as trees.
- Labels for boolean fields can render as `checkon` or `checkoff` icons.

## [0.1.10] - 2018-08-10
### Added
- Link can be styled as a back button.
- Table can render a 2-dimensional array as well as an array of hashes.
- Text can be rendered with a button to toggle the showing/hiding of text.
- Select can render with option groups. The `:options` must be a hash where the key is the group label and the value is an Array of 2-dimensional Arrays ([label, value]).
### Changed
- All icon usage changed from using FontAwesome to using embedded SVG icons.
- Multi can have a `required` attribute set to true. If true, the user must choose at least one option of the multiselect.

## [0.1.9] - 2018-07-13
### Added
- A progress step control for showing the state of progress as a line with circle nodes at each step.
- A repeating request control for rendering a div and calling a url to modify it at intervals.
### Changed
- Removed the inline javascript `fetch` code for a Callback section. The inline javascript now calls `crossbeamsUtils.loadCallBackSection` to do the loading.
- Table cells can apply classes based on the results of lambda calls.
### Fixed
- A Multi control without any selected values was not rendering. Changed the default from `nil` to `[]`.

## [0.1.8] - 2018-07-06
### Changed
- Caption of a Section renders above the section when fit-height is set. This prevents it from rendering alongside other content due to the flex display css styling.
- `multiselect_save_remote` renamed to `multiselect_save_method`.

## [0.1.7] - 2018-06-29
### Changed
- A sortable list can drag elements out to another sortable list by giving both lists the same value for `drag_between_lists_name`.
- Inputs can be renedered with a `copy_to_clipboard` button at the right.
- Sections (and grids within) can be renedered to take up available height by using `section.fit_height!`.
- Grids can be rendered to take up available height if they are not in a section by setting option `fit_height: true`. Note that the containing element must have the css property `display: flex`.
- A section can render with a border by using `section.show_border!`.

## [0.1.6] - 2018-05-28
### Added
- New Diff element.

## [0.1.5] - 2018-05-15
### Added
- New List element for forms and columns.

## [0.1.4] - 2018-04-03
### Changed
- AG-Grid upgraded to version 17.
- Use new ag-theme-balham.
- Tool panel button removed from grid header (now built-in to grid).

## [0.1.3] - 2018-03-13
### Added
- observe-selected behaviour to copy selected items from a multi to a sortable control.
- Remote forms re-enable their submit buttons after a brief delay.
- Sortable can be included in a column. This allows it to be used in forms.

## [0.1.2] - 2018-02-21
### Added
- This changelog.
- Hint option for field renderers.
- File input type for file uploads.
- Multipart option on forms.
- Inline option on forms.
### Changed
- Text renderer has a wrapper option. The array/symbol will be used to wrap text in appropriate HTML tags.
  (:p == paragrahp tag, :h2 == Header 2 tag etc.).
### Fixed
- Textarea renders without excess blank spaces.

## [0.1.1] - 2018-02-08
### Changed
- Upgrade to Ruby 2.5.
- Start to use git flow for releases.
