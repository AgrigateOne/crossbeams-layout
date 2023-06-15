# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres roughly to [Semantic Versioning](http://semver.org/).


## [Unreleased]
### Added
### Changed
### Fixed
- For a Label with a hidden field, apply the field's id to the hidden field, not the label div
- Do not raise an exception if a Select has a selected value that is not included in options or disabled options
- RadioGroup - cast everything to string before matching items to the current value

## [2.1.0] - 2023-050-29
### Added
- New control: `SelectMultiple` for multi-select with single dropdown
- `BaseSelect` class inherits from Base - takes refactored option-building logic for `Select`, `SelectMultiple` and `Multi`
- `fit_width!` method for rows to use wide class
- `dom_id` for a Section
### Changed
- Brought back the print button for grids
- Link: Can supply a colour for :button style
- Link: Can supply a text size for buttons
- Link: New behaviour - `:remote` to submit the URL in a fetch request
### Fixed
- Validation errors are correctly styled for fields that are part of parent fields
- Remote inline form was not re-enabling the submit button
- Fix to checking of default options when no options are provided

## [2.0.0] - 2022-10-27
### Changed
- Upgrade to Ruby 3

## [1.0.0] - 2022-09-23
### Added
- New input: RadioGroup.
### Changed
- A `CallbackSection` can be rendered to work inside a dialog by calling the `remote!` method on the section.
- Set `data-new-page-link` on `Link`s when the link opens a new page (so that it can be disabled in the UI once clicked)
### Fixed
- a `FormButton` that is remote will briefly disable instead of disable.

## [0.6.0] - 2022-08-28
### Added
- Add `add_list` method to `Page`.
- Add `:json` as a valid syntax for `Text` controls.
- `Form` gets a new method: `add_button` so that a form can be submitted to different URLs for different buttons.
### Changed
- if `col_defs` are provided to a grid, do not attempt to build the URL from the multiselect URL. This allows the creation of multiselect grids in code.
### Fixed
- Input: regexp pattern needed to have leading and trailing slashes removed.

## [0.5.8] - 2021-12-29
### Added
- Section: two new methods: `full_dialog_height!` and `half_dialog_height!` to force the section to a min width for dialogs.
- FoldUp: can include a Section.
### Changed
- DropdownButton : menu items are set with `nowrap` so that items can be wider than the button width.
- Raise library-specific Error exceptions instead of RuntimeError.
- Grids: Can open with groups expanded - `group_default_expanded` can be a number for how many grouping levels to open. (0 == none; -1 == all; any positive number == that number of levels)

## [0.5.7] - 2021-07-03
### Changed
- Grid: If `is_multiselect` option is passed in, set defaults for `multiselect_key` and `multiselect_params` if they are not provided.
- Grid: When rendering with cols and rows, include extra options `multiselect_ids`, `extra_context` and `field_edit_url`.

## [0.5.6] - 2021-06-25
### Added
- Label: Can render with a hidden field - set `include_hidden_field: true`.
- Label: Optionally provide a different value for the hidden field using `:hidden_value`.
- Grids: Can pass in columns and rows directly so the grid loads with the page instead of using a URL to load rows via a delayed request.
- Nodes can add javascript to be included in the page. Currently only used by Grid.

## [0.5.5] - 2021-06-09
### Added
- Grid: added icons for saving and applying grid column state.
### Changed
- `for` attribute of label elements uses correct `id` attribute if there is a `:parent_field`.

## [0.5.0] - 2021-04-29
### Added
- `DropdownButton` control. Renders a button with items as a dropdown list of cliackable links.
- Icon: added two new icons: `window` and `link`.
- Row: `blank_column`. Renders a column with nothing in it. This forces another column in the same row to half-size.
- New option `initially_visible` as an antonym for `hide_on_load` added to Text and Inputs.
### Changed
- ProgressStep calculates step width percentages using `floor` instead of `round`. This prevents the aggregate width from exceeding 100%.

## [0.4.5] - 2020-09-14
### Added
- Diff control: `max_pane_width` setting in px to force horizontal scrollbars if content is wider.
- Diff control: `unnest_records` setting to "flatten" nested hashes. A nested value appears with its ancestor keys on the same line.
- Diff control: `sort_nested` setting defaults to true. If true, unnested hashes will be sorted. If false the order will depend on the calling code.
- Form control: base validation messages can have a `nil` key (Dry-Validation 1.x onwards) as well as a `:base` key (Crossbeams apps).
### Changed
- Input control: Add `:alphanumeric` pattern and set the `title` by default when a built-in pattern is used.

## [0.4.4] - 2020-07-04
### Added
- Download icon.
- LoadingMessage for rendering a loading graphic with optional caption.
### Changed
- New style for Link control - `:action_button` - renders a green button.
- New option for Link control - `:icon` - renders a valid `Icon` to the left of the given text.

## [0.4.3] - 2020-05-08
### Added
- Extra options for Text - `hide_on_load`, `dom_id` and `css_classes`.
- Text control can display XML with syntax highlighting.
- Label can be rendered within `<pre>` tags: `format: :preformat`.
- Raise an `ArgumentError` if a field has no renderer defined.
- List controls can be rendered with an icon to remove an item by calling a URL. Uses the `remove_item_url` property which **must** include a `$:id$` token to be replaced by the item's id value.

## [0.4.2] - 2020-03-13
### Changed
- Label with time values can be formatted: `format: :without_timezone` or `format: :without_timezone_or_seconds`.

## [0.4.1] - 2020-03-07
### Changed
- List can be rendered with a border and bg (`:filled_background: true`).
- List can be restricted to a particular height (`scroll_height: :short/:medium`).
- Diff can be rendered without surrounding padding (`no_padding: true`).

## [0.4.0] - 2020-02-17
### Added
- `Datetime` renderer created - replaces the `datetime` subtype of the `Input` renderer. This renders a date and time control together.
### Fixed
- FoldUp: make the cursor a pointer only on the summary and not also on the enclosed details content.

## [0.3.8] - 2019-12-24
### Added
- `input_change` behaviour added to listen to input changes (particularly for checkboxes).
- `inline_caption` option for Notice control: displays `Note`, `Error` etc caption on the same line as the text.
- `submit_in_loading_page!` for forms to convert the POST to a GET and call the action inside a "loading" window. 
### Fixed
- Buttons in grid header - set the type to "button" to prevent the default submit when rendered inside a form.

## [0.3.7] - 2019-11-01
### Added
- New Form method: `button_id` for setting the DOM id of the submit button.
- New Form method: `initially_hide_button` for hiding the submit button on initial render.
- New options for `input` - `minvalue` and `maxvalue` - applies to date/time/number types only.

## [0.3.6] - 2019-10-29
### Changed
- Table: give pivot data column a minimum width.
### Fixed
- `form_values` correctly applied to a field with a `parent_field`.
- Multi control was not picking up default selection properly when options were integers and selection was strings. Forced both to string.
- Alignment was not applied to pivoted columns.

## [0.3.5] - 2019-09-13
### Added
- HelpLink for displaying a button to open a help page.
- `parent_field` attribute for fields. Set this to the name of an encompasing Hash (JSONB) column.
### Changed
- Styling of fold_ups improved.
- Expand/Collapse can be called within a Column.
- `invisible` property of fields can be set and if true, the field will not be rendered.

## [0.3.4] - 2019-09-13
### Added
- `dom_id` option for Table will wrap the table in a div with the given id for dynamic replacement.
- Table can receive a `cell_transformers` option to dynamically format values in a cell.

## [0.3.3] - 2019-09-04
### Added
- New field config option `:hide_on_load`. When set, the form control and label will be rendered hidden.

## [0.3.2] - 2019-08-31
### Added
- Grids can include a colour_key option. This hash of `css_class: description` will display in the header to explain what each coloured row means.

## [0.3.1] - 2019-07-01
### Added
- Grid can render with a row bookmark button.

## [0.3.0] - 2019-06-23
### Added
- New behaviours: `keyup` and `lose_focus`.
- Select changes to make use of the `Choices` javascript library instead of the `Selectr` library.
- Select: `min_charwidth` option to set the `min-width` style in rem.
- Select: `native` option to render as a native select tag.
- Select: `remove_search_for_small_list` option to automatically render without a search box if the list of options is small.
- Select: `sort_items` option to have the javascript control sort items.
- Select: if `prompt` is not set, ensure the dropdown is not clearable.
### Changed
- Label renders as a div instead of a disabled input. This allows selecting of the text in the label.

## [0.2.2] - 2019-06-03
### Added
- Base helper method to extract field values from `extended_columns` field if required.
- Tooltip attribute for checkboxes - sets `title` attribute of `label` tag.
- Expand/Collapse control for FoldUps to open or close all foldups in the same form.
### Fixed
- Label controls render `disabled` so they do not form part of a form's submission.

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
