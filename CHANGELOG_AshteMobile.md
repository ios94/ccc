# AshteMobile update

- Hardened Debian AR archive reading against unreadable files, malformed headers, invalid numeric fields, and out-of-bounds member sizes.
- Removed force-try and unsafe range access from the AR archive reader.
- Corrected archive permission parsing to octal.
- Updated the Debian package handler to propagate archive-loading errors.
- Added `ASHteMobile_PROJECT_REVIEW.md` with validation results and security/design follow-up notes.
