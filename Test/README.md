# Test Suite (PowerShell 5.1 + Pester 5)

## Structure
- Test/Unit: fast, isolated tests using mocks (one file per cmdlet)
- Test/Integration: local WSL tests (one file per cmdlet)
- Test/TestSetup.ps1: common module import

## Run
- Unit only:
  - ./Tools/Run-Tests.ps1
- Unit + Integration:
  - ./Tools/Run-Tests.ps1 -IncludeIntegration

## Git Hook (pre-push)
- Enable repository hooks:
  - ./Tools/Enable-GitHooks.ps1
- Disable repository hooks:
  - ./Tools/Disable-GitHooks.ps1
- After enabling, when pushing a release tag (v*), pre-push validates tag and manifest version/prerelease alignment.
- If tag/manifest validation passes, Unit tests run only when pushing at least one tag.
- If tests fail, push is blocked.

## Notes
- Integration tests are intended for local execution on a machine with WSL.
- Unit tests mock wrapper/system calls and validate behavior, errors, and pipeline support.
