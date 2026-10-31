# Instructions for coding agents

This file summarizes rules from [CONTRIBUTING.md](CONTRIBUTING.md) and
[AI_POLICY.md](AI_POLICY.md). Those files are the source of truth, read them
before you change anything.

- Never add a `Signed-off-by` tag, in commits or in patch files. The human
  adds it.
- Never push, open a pull request or post a comment unless the human has read
  and approved it first.
- Remind the human to say in the pull request what the LLM was used for. Do
  not add `Co-authored-by:` or other trailers that name a tool, and do not add
  links to the chat or agent session.
- Keep commit messages and pull request descriptions short: what changes and
  why. No diff summaries, no long logs.
- Prefix the commit subject with the package name, for example
  `foopkg: add libzot dependency`.
- Give every patch in `<package>/patches/` a `git am` compatible header and a
  description that says where it stands upstream. Suggest sending the fix
  upstream where possible.
- Generate and update patches with `make package/<name>/refresh`, never by
  hand.
- Build the package and run it on a device or in QEMU before the human
  submits it. Report where it was tested, and never claim a test that did not
  run.
