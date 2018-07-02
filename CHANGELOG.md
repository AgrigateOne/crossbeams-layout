# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres roughly to [Semantic Versioning](http://semver.org/).


## [Unreleased]
### Added
### Changed
- Caption of a Section renders above the section when fit-height is set. This prevents it from rendering alongside other content due to the flex display css styling.
### Fixed

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
