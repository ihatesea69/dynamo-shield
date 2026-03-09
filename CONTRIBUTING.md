# Contributing

Thank you for considering contributing to this project!

## Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes and commit: `git commit -m "feat: add your feature"`
4. Push to your fork: `git push origin feature/your-feature-name`
5. Open a Pull Request

## Development Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [pre-commit](https://pre-commit.com/) (optional, for local linting)

## Code Standards

- Run `terraform fmt -recursive` before committing
- Run `terraform validate` on all modules
- Keep modules small and single-purpose
- Document all variables and outputs with `description` fields

## Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation only
- `refactor:` code refactoring
- `chore:` maintenance

## Reporting Issues

Open a GitHub Issue with a clear description, reproduction steps, and expected vs actual behaviour.
