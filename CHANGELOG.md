# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres roughly to [Semantic Versioning](http://semver.org/).


## [Unreleased]
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
