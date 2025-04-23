# Subscribe to Publication Updates (SPU)

The goal of this project is to provide a simple tool to manage/gather dependencies, documents, or any other versioned files while using the minimum number of dependencies (`git` and `jq`) and working with files in a human-readable format (JSON). It does this by taking a list of git repositories and tags, fetching/pulling/checking them out as necessary.

## Philosophy

You may be thinking: this sounds an awful lot like another (bad) package manager. And you're right! It doesn't have fancy features like `npm`, `cargo`, or the many, many others. But, what it does have is only about 200 lines of `bash` script and essentially no requirements for the repositories it uses aside from using git tags. If you wanted to download or clone things directly from GitHub, GitLab, etc., you can. If you want to use `spu`, you can.

## Usage

This repository contains four files:

* `README`: this document
* `.gitignore`: this repository's ignore list
* `init_url.txt`: a text file containing the baseline repository URL
* `spu`: the core program, a bash script that executes all of the necessary operations to update/manage dependencies

For all usage cases, ensure you run the binary in the repository directory, i.e. you should be running `./spu`.

### Getting SPU

To get `spu`, simply clone this repository. This will give you the four files listed above.

### Initialization

`./spu -i` or `./spu --init`

This will clone the repository at the URL in `init_url.txt` into the `baseline` folder. Prior to running this command, ensure `init_url.txt` is a single line file containing the URL of the baseline repository you want to clone. At a minimum, the baseline repository you use should contain a `manuals.json` and `versions.json`.

#### What is `baseline`?

The motivation for having a baseline respository is to share a common starting point between multiple users. It should contain a list of the repositories that a group of users is pulling files from and a list of the most recent  versions (git tag) of those repositories.

##### `manuals.json`

`manuals.json` is just a dictionary of repository names and URLs that the `spu` program can pull from. An example is

```json
{
    "baseline": "git@gitlab.com:scratchpad8400308/scratchpad_baseline.git",
    "nyc": "git@gitlab.com:scratchpad8400308/nyc.git",
    "int": "git@gitlab.com:scratchpad8400308/int.git",
    "nat": "git@gitlab.com:scratchpad8400308/nat.git"
}
```

The URLs can be either HTTPS or SSH; however, because `spu` performs several `pull`s during most of its commands, SSH is recommended for ease of use. You'll also notice there is a `baseline` repository listed. This allows `spu` to continue updating a baseline after initialization, to include changing the baseline repository altogether if required.

##### `versions.json`

`versions.json` is just a dictionary of repository names and the most recent git tag for each repository. This file is updated by the maintainer of the baseline repository, allowing them to "pin" a repository to a version, even if that repository has been updated. An example is

```json
{
    "int": "20250220",
    "nat": "20250221"
}
```

`spu` uses this file to decide which repositories to clone and what git tag to checkout after the repository is cloned. The advantage of using git tags over commit hashes is readability. In the example above, the tags are `YYYYMMDD`. Tags could be configured to be version numbers, dates, letters, etc.

### Updating SPU

`./spu -s` or `./spu --update-spu`

This command will pull the SPU repository itself, updating the four documents contained in its repository.

### Running SPU

`./spu` or `./spu manuals.json versions.json`

This is the primary command you will use to update the publications listed in `versions.json`. By default (with no arguments), `spu` will use the `baseline/manuals.json` and `baseline/versions.json` files for its operations. If desired, provide a path to your own `manuals.json` and `versions.json` files to override the list of repository URLs and versions you would like to download. This can be used to further "pin" versions locally; however, you should frequently compare these to the baseline repository you are using to ensure repository URLs (`manuals.json`), in particular, stay current.

The general sequence of events that occurs when running this command is

* `spu` analyzes all command line options and arguments to ensure they are valid and the `manuals.json` and `versions.json` files exist.
* (if update baseline flag is provided) `spu` updates the `baseline` folder by performing a `git pull` using the `baseline` URL in `manuals.json`.
* `spu` verifies the `pubs` directory exists and makes it if it does not.
* `spu` extracts the list of repository names in `versions.json`

#### Flags

The following is an explanation of the various flags you can use to modify `spu`'s behavior. All can be used in any combination.

##### Update Baseline

`./spu -b` or `./spu --update-baseline`

With this command line option, `spu` updates the `baseline` folder by performing a `git pull` using the `baseline` URL specified in `manuals.json`. In general, you should use this command line option; however, it is not default behavior to avoid inadvertently performing an additional `git pull` operation.

##### Offline Mode

`./spu -o` or `./spu --offline`

With this command line option, `spu` will not perform any `git pull` operations, using only existing, downloaded data to perform any version changes. While this may seem counter to the motivation for `spu`, this allows a user to downloaded newer versions of repositories they subscribe to, stay "pinned" to an old version, and update later without connectivity. It could also be used to rollback to versions that have already been downloaded.

##### Verify

`./spu -v` or `./spu --verify`

With this command line option, after performing all other operations, `spu` prints the current status of each publication, providing more details about the status of each repository. This is primarily used for debugging and manual verification purposes. It is not necessary to run for normal operations.

## Example

To help solidify the use case for `spu`, consider the following example: Billy runs an auto repair franchise. He has representatives in each state that manage all of the shops in that state. As a result of the differences between the needs of each state, they've developed slightly different requirements/specialties. Some work on domestic light and heavy-duty pick-up trucks, some work on sporty foreign convertables, and some work on classic cars, but they all need access to generic and vehicle-specific maintenance procedures, recalls, and manuals.

### Problem

Over the years, he's had lots of issues with version control. Manufacturers would disseminate recalls, manual changes, etc., and his publications team would manually distribute them to his state reps, who would then distribute them to the shops. This process required a lot of work, each rep and shop had different ways of storing the documents, and it was difficult to track who had what version of publications. To fix this, he got everyone to start using one, central network storage location. This made sure that there was one place with the most up-to-date copy of each reference. His publications team was now pulling publications from manufacturer websites and uploading them to their shared network storage where they became immediately accessible by everybody. This, for the most part, solved his problems.

Every now and then, though, he still ran into issues. Two recurring ones caught his attention:

1. When new publications were uploaded, the reps and shops didn't always immediately recognize it, and they lost access to the old version, making it difficult to teach the techs working at the shops the difference between the two.
2. Network connectivity was absolutely required. This meant that if a shop or rep lost connectivity, they couldn't access any of their documents. In addition, his fleet of mobile techs who serviced the ranches and backwoods constantly found their maintenance tablets *still* were not current. That, and they couldn't possibly fit every single manual on their small tablets. After all, they had to cut costs somewhere, and gigantic SSDs weren't cheap back when they bought them.

As a result, he went searching for a solution, and stumbled upon `spu`.

### Roles

`spu` is used a little differently by each member of his franchise. A summary of each is below.

#### Publications Team

The publications team's job hasn't changed significantly. They are still responsible for downloading and uploading manufacturer manuals; however, instead of uploading them to the shared network storage, they upload them to the repository. This allows both version tracking and a history of manuals.

For publications/procedures generated by Billy's team, using a repository allows the team to track changes down to the letter, allowing both their internal review team and their state reps/shop managers to focus their efforts on the parts of the manual that have actually changed.

They maintain the following repositories:

* `trucks`: maintenance manuals for light and medium duty trucks
* `foreign`: maintenance manuals for imported cars
* `sports`: maintenance manuals for sports cars
* `common`: procedures common to all vehicles, like tire rotations, checking tire wear, and general cleaning

They also maintain the primary `baseline` repository, containing the following:

##### `baseline/manuals.json`

```json
{
    "baseline": "git@billysgit.com:main/baseline.git",
    "trucks": "git@billysgit.com:main/trucks.git",
    "foreign": "git@billysgit.com:main/foreign.git",
    "sports": "git@billysgit.com:main/sports.git",
    "common": "git@billysgit.com:main/common.git"
}
```

##### `baseline/versions.json`

```json
{
    "baseline": "20250301",
    "trucks": "20250201",
    "foreign": "20250201",
    "sports": "20250101",
    "common": "20250301"
}
```

#### Reps

The state reps are monitoring the main `baseline` repository and see changes immediately. They skim the manuals to understand the differences in any changed publications, update their custom baseline repositories, and move on.

##### Example Rep

The Maine rep deals with shops that work on trucks and foreign cars. As a result, they maintain their own baseline repository, `me_baseline`. They also maintains a baseline for mobile truck techs, `me_truck_baseline`, that allows their stores to easily prep "go" tablets.

###### `me_baseline/manuals.json`

```json
{
    "baseline": "git@billysgit.com:main/me_baseline.git",
    "trucks": "git@billysgit.com:main/trucks.git",
    "foreign": "git@billysgit.com:main/foreign.git",
    "common": "git@billysgit.com:main/common.git"
}
```

###### `me_baseline/versions.json`

```json
{
    "baseline": "20250301",
    "trucks": "20250201",
    "foreign": "20250201",
    "common": "20250301"
}
```

###### `me_truck_baseline/manuals.json`

```json
{
    "baseline": "git@billysgit.com:main/me_truck_baseline.git",
    "trucks": "git@billysgit.com:main/trucks.git",
    "common": "git@billysgit.com:main/common.git"
}
```

###### `me_truck_baseline/versions.json`

```json
{
    "baseline": "20250301",
    "trucks": "20250201",
    "common": "20250301"
}
```

#### Shops

As a result of all this work, the shop manager's job is easy: simply initialize `spu` with the baseline repository provided by the state rep and run an update every morning. This will ensure that the most recent manuals are available

#### Mobile Techs

Like the shop manager, the mobile tech's job is also easy: just run a `spu` update before heading out on the job, and they are guaranteed to have the most up-to-date manuals available.
