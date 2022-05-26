# dependadoc v0.1
Github action that opens a PR against another repo when specified files in current repo are modified.

# What's new
* This is the MVP of this action.

# What does dependadoc do?
In many cases, documentation is best kept close to the code it documents; in a given repo, often documentation is kept in its own folder.

Another common use case is to keep a dedicated documentation repo. This has the advantage of source control and consolidation. Also, there exist many tools (mkdocs is the one that first caught my attention) that can add beauty and searchability to repo-based documentation by rendering it into html.

Dependadoc is an action that allows for what I call the "mirroring" of documentation that is kept _elsewhere_ than the dedicated repo to be automatically copied to the dedicated repo when it is added or updated.

A concrete example will help explain how this works.

## Sample workflow
Let's say we have a repo called `tooling`, and within it, we keep all the docs in a folder called `documentation`. When a PR is merged to main in tooling, if any documentation has been added or updated, we want to mirror that documentation to our other repo, called `alldocs`.

`Alldocs` is a repo set up to be rendered by `mkdocs`, so all the files that are rendered are in a folder called `site`.

Here's the workflow file that we'll add to that repo.

```yaml
# tooling/.github/workflows/main.yml

# we want to trigger our dependadoc job on *closed* PRs
# and only closed repos that were merged (we add this logic below)
on:
  pull_request:
    types: [ closed ]

jobs:
  dependadoc_job:
    # we add this conditional to avoid triggering this job
    # on PRs that are just closed without being merged
    if: github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    name: Mirror 'doc' folder to 'onedocs'
    steps:
      - uses: caljess599/dependadoc@v0.1
        with:
          mirrored-folder: documentation
          docs-repository: ourorg/alldocs
          docs-repository-path: site
          docs-repository-token-variable: ${{ secrets.SOMEONES_PAT }}


```

# Usage details
```yaml
- uses: caljess599/dependadoc@v0.1
  with:
    # The name of the folder in the current (where the workflow is triggered) repo.
    # required; no default
    # e.g., 
    mirrored-folder: documentation
    
    # full name (org and repo) of the where the PR of the `mirrored-folder` will be opened 
    # required; no default
    # e.g., 
    docs-repository: ourorg/alldocs
    
    # path within the someorg/alldocs repo to place mirror-current-repo folder
    # not required; default: '.'
    # e.g.,
    docs-repository-path: site
    
    # token that has proper scope to read and write to someorg/alldocs
    # because the limited scope of the default $GITHUB_TOKEN, 
    # even if you are mirroring documentation between repos
    # IN THE SAME ORGANIZATION, you will need this token for this action to work
    # required; no default
    docs-repository-token-variable: ${{ secrets.SOMEONES_PAT }}
```
