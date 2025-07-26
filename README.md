# Subscribe to Publication Updates (SPU)

The goal of this project is to provide a simple tool to manage/gather dependencies, documents, or any other versioned files while using the minimum number of dependencies (`git`, `grep`, and `cut`) and working with files in a human-readable format. It does this by taking a list of git repositories and tags, fetching/pulling/checking them out as necessary.

## Philosophy

SPU is intentionally minimalist. While it may appear similar to a package manager, it focuses on simplicity and reliability by:

- Using only basic dependencies (`git`, `grep`, and `cut`)
- Working with human-readable file formats
- Requiring only Git tags for version management
- Supporting any Git repository (GitHub, GitLab, private servers, etc.)

You may be thinking: this sounds an awful lot like another (bad) package manager. And you're right! It doesn't have fancy features like `npm`, `cargo`, or the many, many others. But, what it does have is only about 200 lines of `bash` script and essentially no requirements for the repositories it uses aside from using git tags. If you wanted to download or clone things directly from GitHub, GitLab, etc., you can. If you want to use `spu`, you can.

## Usage

This repository contains five files:

* `README.md`: this document
* `EXAMPLE.md`: a lengthy example to demonstrate how `spu` is used
* `.gitignore`: this repository's ignore list
* `init_url.txt`: a text file containing the baseline repository URL
* `spu`: the core program, a bash script that executes all of the necessary operations to update/manage dependencies

For all usage cases, ensure you run the binary in the repository directory, i.e. you should be running `./spu`.

### Getting SPU

To get `spu`, simply clone this repository. This will give you the files listed above.

### Initialization

`./spu -i` or `./spu --init`

This will clone the repository at the URL in `init_url.txt` into the `baseline` folder. Prior to running this command, ensure `init_url.txt` is a single line file containing the URL of the baseline repository you want to clone. At a minimum, the baseline repository you use should contain a `manuals.txt` and `versions.txt`.

#### What is `baseline`?

The motivation for having a baseline repository is to share a common starting point between multiple users. It should contain a list of the repositories that a group of users is pulling files from and a list of the most recent versions (git tag) of those repositories.

##### `manuals.txt`

`manuals.txt` is just a dictionary of repository names and URLs that the `spu` program can pull from. An example is

```
baseline git@gitlab.com:scratchpad8400308/scratchpad_baseline.git
nyc git@gitlab.com:scratchpad8400308/nyc.git
int git@gitlab.com:scratchpad8400308/int.git
nat git@gitlab.com:scratchpad8400308/nat.git
```

The URLs can be either HTTPS or SSH; however, because `spu` performs several `pull`s during most of its commands, SSH is recommended for ease of use if authentication is required. You'll also notice there is a `baseline` repository listed. This allows `spu` to continue updating a baseline after initialization, to include changing the baseline repository altogether if required.

##### `versions.txt`

`versions.txt` is just a dictionary of repository names and the most recent git tag for each repository. This file is updated by the maintainer of the baseline repository, allowing them to "pin" a repository to a version, even if that repository has been updated. An example is

```
int 20250220
nat 20250221
```

`spu` uses this file to decide which repositories to clone and what git tag to checkout after the repository is cloned. The advantage of using git tags over commit hashes is readability. In the example above, the tags are `YYYYMMDD`. Tags could be configured to be version numbers, dates, letters, etc.

### Updating SPU

`./spu -s` or `./spu --update-spu`

This command will pull the SPU repository itself, updating the files contained in its repository.

### Running SPU

`./spu` or `./spu manuals.txt versions.txt`

This is the primary command you will use to update the publications listed in `versions.txt`. By default (with no arguments), `spu` will use the `baseline/manuals.txt` and `baseline/versions.txt` files for its operations. If desired, provide a path to your own `manuals.txt` and `versions.txt` files to override the list of repository URLs and versions you would like to download. This can be used to further "pin" versions locally; however, you should frequently compare these to the baseline repository you are using to ensure repository URLs (`manuals.txt`), in particular, stay current.

The general sequence of events that occurs when running this command is

* `spu` analyzes all command line options and arguments to ensure they are valid and the `manuals.txt` and `versions.txt` files exist.
* (if update baseline flag is provided) `spu` updates the `baseline` folder by performing a `git pull` using the `baseline` URL in `manuals.txt`.
* `spu` verifies the `pubs` directory exists and makes it if it does not.
* `spu` extracts the list of repository names in `versions.txt`

#### Flags

The following is an explanation of the various flags you can use to modify `spu`'s behavior. All can be used in any combination.

##### Update Baseline

`./spu -b` or `./spu --update-baseline`

With this command line option, `spu` updates the `baseline` folder by performing a `git pull` using the `baseline` URL specified in `manuals.txt`. In general, you should use this command line option; however, it is not default behavior to avoid inadvertently performing an additional `git pull` operation.

##### Offline Mode

`./spu -o` or `./spu --offline`

With this command line option, `spu` will not perform any `git pull` operations, using only existing, downloaded data to perform any version changes. While this may seem counter to the motivation for `spu`, this allows a user to downloaded newer versions of repositories they subscribe to, stay "pinned" to an old version, and update later without connectivity. It could also be used to rollback to versions that have already been downloaded.

##### Verify

`./spu -v` or `./spu --verify`

With this command line option, after performing all other operations, `spu` prints the current status of each publication, providing more details about the status of each repository. This is primarily used for debugging and manual verification purposes. It is not necessary to run for normal operations.
