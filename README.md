# Wordcount Bot

<!-- pandoc-book-readme -->
**Wordcount** is a Docker container that auto-generates a compound README from Markdown files within the repository. It looks for all content between two comment tags, then inserts them in a README based on a template. (docker://merovex/pandoc-book-readme:latest)
<!-- /pandoc-book-readme -->

## Configuration

The following Github Action workflow should be added. Your repository name needs to be added


### On Demand Wordcount without Recording 

```

name: Wordcount Books (on Demand)
on: [push]
jobs:
  build:
    if: "contains(toJSON(github.event.commits.*.message), '@verkilo wordcount')"
    name: Wordcount
    runs-on: ubuntu-latest
    steps:
      - name: Get repo
        uses: actions/checkout@main
        with:
          ref: main
      - name: Run wordcount (Docker)
        uses: docker://merovex/verkilo:latest
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          ACTION: wordcount
          FLAGS: "--delta"
```

### Weekly Wordcount with Recording 

```
name: Wordcount Books Cron
on:
  schedule:
    - cron: "30 3 * * 1"
jobs:
  build:
    name: Wordcount
    runs-on: ubuntu-latest
    steps:
      - name: Get repo
        uses: actions/checkout@main
        with:
          ref: main
      - name: Run wordcount (Docker)
        uses: docker://merovex/verkilo:latest
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          ACTION: wordcount
          FLAGS: "--log --delta --offset=-04:00"
      - name: Commit on change
        uses: stefanzweifel/git-auto-commit-action@v4
        with:
          commit_message: "@verkilo updated wordcount"
```

