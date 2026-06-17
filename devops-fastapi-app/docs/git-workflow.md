# GitLab conventions

## Branches

We use short-lived branches created from `main`.

Changes should be small and merged frequently to keep the main branch up to date and stable.

Branches should ideally live less than 1–2 days.

Branch naming:

- `feature/<short-description>` for a new feature
- `fix/<short-description>` for a bug fix
- `docs/<short-description>` for documentation
- `chore/<short-description>` for tooling, cleanup or configuration

Examples:

- `feature/backend-ci`
- `docs/project-analysis`
- `chore/docker-cleanup`
- `fix/frontend-env`

## Main branch

The `main` branch must stay stable and protected.

No direct push on `main`.

Every change must go through a Merge Request.

## Merge Requests

Each Merge Request should:

- have a clear title
- describe what was changed
- mention the related issue when possible
- keep Merge Requests small and focused when possible
- be reviewed by at least one teammate before merge

## Commits

Commit messages should be clear and short.

Optionally, you can follow the Conventional Commits specification:
https://www.conventionalcommits.org/en/v1.0.0/

Examples:

- `feat: add Get users endpoint`
- `fix: correct frontend API URL`
- `chore: change configuration`
- `docs: update project analysis`
- `ci: update gitlab-ci stages`

## Workflow

1. Move the issue to `Doing`
2. Create a branch from the latest `main`
3. Commit the changes
4. Push the branch
5. Open a Merge Request
6. Ask for review
7. Merge after validation
8. Move the issue to `Done`

## Basic Git commands

Common commands used in the workflow:

- Switch to main branch:
    ```
    git switch main 
    ```
- Update main branch:
    ```
    git pull
    ```
- Create a new branch:
    ```
    git switch -c <branch-name>
    ```
- Commit changes:
    ```
    # show updated files (red not added and green added)
    git status

    # add files
    git add <file1> <file2>

    # or add all files
    git add .

    # commit
    git commit -m "your message"

    # show commit history
    git log
    ```
- Push a branch:
    ```
    git push -u origin <branch-name>
    ```

## Notes

This document defines our initial team workflow.
It can be updated later if the team agrees on changes.