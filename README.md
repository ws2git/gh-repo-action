# gh Repo Action

This GitHub Action allows you to execute `gh repo` commands (such as `archive`, `unarchive`, `create`, etc.) on any repository your token has access to.  
It is built as a composite action for easy reuse and extensibility.

---

## Features

- Supports any `gh repo` command by passing parameters directly.
- Easily extensible for future `gh repo` subcommands (start with archive/unarchive, supports create, etc.).
- Uses the official [GitHub CLI](https://cli.github.com/) for robust repository management.
- Simple integration in any GitHub Actions workflow.


## Requirements

- **GitHub CLI (`gh`)**:  
  The action requires the GitHub CLI to be available in the runner environment.  
  All official GitHub-hosted Ubuntu runners (`ubuntu-latest`) include `gh` by default.

- **Authentication Token**:  
  The action uses the GitHub CLI, which expects an authentication token via the `GH_TOKEN` environment variable.  
  In most cases, you should use the built-in `${{ github.token }}` or `${{ secrets.GITHUB_TOKEN }}` in your workflow step.

  Example:
  ```yaml
  env:
    GH_TOKEN: ${{ github.token }}
  ```

- **Permissions**:  
  The token must have permission to perform the requested action on the target repository (admin for archive/unarchive, push/create for create, etc.).

---

## Inputs

| Name        | Required | Description                                 |
|-------------|----------|---------------------------------------------|
| `action`    | Yes      | The `gh repo` action to perform (e.g., `archive`, `unarchive`, `create`) |
| `owner`     | Yes      | The repository owner (user or organization) |
| `repo_name` | Yes      | The repository name                         |


## Usage Example

```yaml
- uses: ws2git/gh-repo-action@v1
  env:
    GH_TOKEN: ${{ github.token }}
  with:
    action: "archive"
    owner: "my-org"
    repo_name: "my-repo"
```

You may also use `"unarchive"` or any other supported subcommand:

```yaml
- uses: ws2git/gh-repo-action@v1
  env:
    GH_TOKEN: ${{ github.token }}
  with:
    action: "unarchive"
    owner: "my-org"
    repo_name: "my-repo"
```

---

## How it Works

The action calls a shell script (`repo-action.sh`) that constructs the full repository identifier from the provided `owner` and `repo_name`, then passes your chosen action directly to the `gh repo` command with the appropriate parameters.


## Limitations

- The action does **not** validate whether the action is supported by the GitHub CLI or if the repository exists; errors from `gh` will cause the workflow step to fail.
- Both `owner` and `repo_name` must be provided for all actions that require a repository identifier (e.g., `archive`, `unarchive`). For actions that do **not** require a repository (such as `gh repo create`), you may ignore or adjust accordingly.
- The GitHub token used must have sufficient permissions for the requested operation.
- The action does **not** check if the repository is already archived/unarchived/etc. before executing.
- Output and errors from the CLI are directly passed to the workflow logs.

---

## Notes

- This action is intended for automation and batch operations where you want to manage repositories programmatically.
- For more information on available `gh repo` commands, see the [GitHub CLI documentation](https://cli.github.com/manual/gh_repo).
