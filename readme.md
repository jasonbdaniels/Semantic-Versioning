# Semantic Versioning Tool

Command line tool used to perform operations on [semantic versions](http://semver.org). Current Implementation follows Semantic Versioning *2.0.0*

A valid version part can be one of the following:

- `major` This is the major number.
- `minor` This is the minor number.
- `patch` This is the patch number.
- `pre` This is the pre-version information.
- `meta` This is the build metadata information.

## Making

This command is useful for making semantic version strings. Each part is checked for validity.

```
semver make <major> [<minor> [<patch> [<pre> [<meta>]]]]
```

### Examples

```
$ semver make 3 12 2 alpha.1 00101 
$ 3.12.2-alpha.1+00101
```

## Parsing

Parsing functions help get specific parts from the version string.

To parse out a versin part execute:

```
semver <part> <semver-string>
```

### Example

```
$ semver patch "3.12.2-alpha+00101"
$ 2
```

## Mutating

Mutation functions can bump up or down various parts of the version string.

### Bump

Increments a version part.

```
semver bump <part> <semver-string>
```

#### Bumping Rules

All rules cascade upnwards. For example, if *Rule 1* is applied then all rules greater than 1 will be applied appropriately. 

1. Bumping major will set minor to zero.
2. Bumping minor or seting minor to zero as a consequence of *Rule 1* will set patch to zero.
3. Bumping patch or setting patch to zero as a consequence of *Rule 2* will remove all trailling dot number seperators from the Pre-Version Information.

### Pre-version and Build Metatdata

Bumping either the Pre-version Information or the Build Metadata has the following behavior:

- If the part **does end in a dot number**, such as, *alpha.1*, then the number is incremented by one; producing *alpha.2* as the new part.
- If the part **does not end in a dot number**, such as, *alpha*, then a *.1* is appended to the part; producing *alpha.1* as the new part.

### Set

This command overwrites a version part with a new value.

```
semver set <part> <new-value> <semver-string>
```

The new value is checked for validity before returning the new version string. If the new value is invalid, then the output is the same as `semver-string`. No other parts of the version string are effected.

Typically the set is used for the Pre-version Information and Build Metadata, because setting the minor part, for example, might create an undesired version string.

### Examples

#### Bump a patch with Pre-version Information

The following increments the patch number *2* and removes all dot number parts from the Pre-Version Information, then outputs the result.

```
$ semver bump patch "3.12.2-alpha.1+00101"
$ 3.12.3-alpha+00101
```
	
#### Bump a major with Pre-version Inforamation

The following increments the major number *3*, sets lower parts to zero, removes all dot number parts from the Pre-Version Information, then outputs the result.

```
$ semver bump major "3.12.2-alpha.1+00101"
$ 4.0.0-alpha+00101
```

#### Set Build Metadata

Replace `00101` with `00110`.

```
$ semver set meta "00110" "3.12.2-alpha.1+00101"
$ 3.12.2-alpha.1+00110
```

#### Set Pre-version Information

Replace `alpha.1` with `beta`.

```
$ semver set pre "beta" "3.12.2-alpha.1+00101"
$ 3.12.2-beta+00110
```
