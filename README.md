# Access Code Example

## What?

This demonstrates an example implementation of the concept of access codes, with the following invariants:

* Access codes are case-insensitive (`"ABC"`, `"abc"`, `"AbC"`, and `"abC"` are equivalent)
* Access codes are not equal if the values are blank / empty / nil (`"\n"`, `""`, `"   "`, and `nil` are not equivalent to each other **or themselves**)
* Access codes should not be susceptible to [timing attacks] when values are compared

## Running the Tests

```sh
rspec access_code.rb
```
