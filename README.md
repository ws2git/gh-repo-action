# gh Repo Action

This GitHub Action allows you to execute `gh repo` commands (such as `archive`, `unarchive`, `create`, `delete`, etc.) on any repository your token has access to. It is built as a composite action for easy reuse and extensibility.

-----

## Features

* **Comprehensive Command Support**: Fully supports `gh repo create`, `gh repo edit`, `gh repo rename`, and `gh repo delete` in addition to `archive`, `unarchive`, and others.
* **Enhanced `create` functionality**: You can specify the `description`, `visibility` (`public`, `private`, `internal`), and a **`team`** to be added to the new repository.
* **Repository Editing**: Supports updating `description`, `homepage`, adding topics (`add_topics`), and removing topics (`remove_topics`).
* **Repository Renaming**: Provides support for `rename` operations using the `new_name` input.
* **Initial Content**: Includes the option to initialize the new repository with a README file via the `add_readme` parameter or to use an existing repository as a `template`.
* **Robust and Extensible**: The `case` statement in the script makes it easy to add support for more `gh repo` subcommands in the future.
* Uses the official [GitHub CLI](https://cli.github.com/) for robust repository management.
* Simple integration in any GitHub Actions workflow.

## Requirements

* **GitHub CLI (`gh`)**:
  The action requires the GitHub CLI to be available in the runner environment.
  All official GitHub-hosted Ubuntu runners (`ubuntu-latest`) include `gh` by default.

* **Authentication Token**:
  The action uses the GitHub CLI, which expects an authentication token via the `GH_TOKEN` environment variable.
  In most cases, you should use the built-in `${{ github.token }}` or `${{ secrets.GITHUB_TOKEN }}` in your workflow step. For operations like creating, editing, renaming, or deleting repositories on behalf of a user or organization, a **Personal Access Token (PAT)** with appropriate scopes is recommended.

  Example:

  ```yaml
  env:
    GH_TOKEN: ${{ github.token }}
  ```

* **Permissions**:
  The token must have sufficient permissions for the requested action on the target repository. This may require `contents: write` or broader `repo` scope permissions. For adding a team, the token must also have permissions to manage team access within the organization.

## Inputs

| Name            | Required | Description                                                                                                         |
| --------------- | -------- | ------------------------------------------------------------------------------------------------------------------- |
| `action`        | Yes      | The `gh repo` action to perform (e.g., `create`, `edit`, `rename`, `delete`, `archive`).                            |
| `owner`         | Yes      | The repository owner (user or organization).                                                                        |
| `repo_name`     | Yes      | The repository name.                                                                                                |
| `description`   | No       | The repository description (for `create` and `edit` actions).                                                       |
| `visibility`    | No       | The repository visibility (`public`, `private`, or `internal`). Default is `public`.                                |
| `team`          | No       | The name of a team to be added to the new repository. The team is granted `read` permission by default.             |
| `add_readme`    | No       | Set to `true` to initialize the new repository with a README.md file (for `create` action only).                    |
| `template`      | No       | The repository to use as a template. Cannot be used with `add_readme` or `team` inputs. (for `create` action only). |
| `new_name`      | No       | The new name for the repository (for `rename` action only).                                                         |
| `homepage`      | No       | The new homepage URL for the repository (for `edit` action only).                                                   |
| `add_topics`    | No       | A comma-separated list of topics to add to the repository (for `edit` action only).                                 |
| `remove_topics` | No       | A comma-separated list of topics to remove from the repository (for `edit` action only).                            |

## Usage Examples

**Example 1: Create a new private repository with a README**

```yaml
- uses: ws2git/gh-repo-action@v2
  with:
    action: "create"
    owner: "my-org"
    repo_name: "my-private-project"
    description: "This is a private project created by an action."
    visibility: "private"
    add_readme: "true"
  env:
    GH_TOKEN: ${{ secrets.ORG_ADMIN_PAT }}
```

**Example 2: Create a new repository and add a team with `read` permission**

```yaml
- uses: ws2git/gh-repo-action@v2
  with:
    action: "create"
    owner: "my-org"
    repo_name: "my-team-project"
    team: "dev-team"
    visibility: "internal"
  env:
    GH_TOKEN: ${{ secrets.ORG_ADMIN_PAT }}
```

**Example 3: Create a repository from a template**

```yaml
- uses: ws2git/gh-repo-action@v2
  with:
    action: "create"
    owner: "my-org"
    repo_name: "my-project-from-template"
    template: "my-org/my-template-repo"
  env:
    GH_TOKEN: ${{ secrets.ORG_ADMIN_PAT }}
```

**Example 4: Edit a repository description, homepage, and topics**

```yaml
- uses: ws2git/gh-repo-action@v2
  with:
    action: "edit"
    owner: "my-org"
    repo_name: "my-project"
    description: "Updated description via GitHub Action"
    homepage: "https://myproject.example.com"
    add_topics: "automation,cli,gh-action"
    remove_topics: "deprecated"
  env:
    GH_TOKEN: ${{ secrets.ORG_ADMIN_PAT }}
```

**Example 5: Rename a repository**

```yaml
- uses: ws2git/gh-repo-action@v2
  with:
    action: "rename"
    owner: "my-org"
    repo_name: "old-repo-name"
    new_name: "new-repo-name"
  env:
    GH_TOKEN: ${{ secrets.ORG_ADMIN_PAT }}
```

**Example 6: Delete a repository**

```yaml
- uses: ws2git/gh-repo-action@v2
  with:
    action: "delete"
    owner: "my-org"
    repo_name: "my-old-project"
  env:
    GH_TOKEN: ${{ secrets.ORG_ADMIN_PAT }}
```

---

## How it Works

The action calls a shell script (`repo-action.sh`) that constructs the full repository identifier from the provided `owner` and `repo_name`, then passes your chosen action directly to the `gh repo` command with the appropriate parameters.
The script uses a `case` statement to handle each command type and its specific arguments.
Options like `template`, `add_readme`, `team`, `homepage`, `add_topics`, and `remove_topics` are handled within the script to ensure they are used correctly based on GitHub CLI limitations.

## Limitations

* The action does **not** validate whether the action is supported by the GitHub CLI or if the repository exists; errors from `gh` will cause the workflow step to fail.
* Both `owner` and `repo_name` must be provided for all actions that require a repository identifier (e.g., `archive`, `unarchive`, `delete`). For the `create` action, only `owner` and `repo_name` are required.
* The GitHub token used must have sufficient permissions for the requested operation.
* The action does **not** check if the repository is already archived/unarchived/etc. before executing.
* The `template` input is mutually exclusive with the `team` and `add_readme` inputs due to GitHub CLI limitations.
* Output and errors from the CLI are directly passed to the workflow logs.

---

## Notes

  - This action is intended for automation and batch operations where you want to manage repositories programmatically.
  - For more information on available `gh repo` commands, see the [GitHub CLI documentation](https://cli.github.com/manual/gh_repo).
