# ``ExtendedAttributes``

Extended attributes allow storage of additional metadata beyond the standard filesystem attributes, such as custom data, security information, or system tags.

## Overview

This package provides two main APIs:

- **``ExtendedAttributes``**: Direct access to macOS extended attributes (`xattr`) with strongly-typed names for common attributes like quarantine info and security settings
- **``SystemMetadata``**: Access to Spotlight metadata (`kMDItem*`) with strongly-typed names for file properties, document info, media metadata, and more

---

[Learn more about extended attributes](https://en.wikipedia.org/wiki/Extended_file_attributes)
