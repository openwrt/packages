# Instructions for coding agents

This file summarizes rules from [CONTRIBUTING.md](CONTRIBUTING.md) and
[AI_POLICY.md](AI_POLICY.md). Those files are the source of truth. Read them
before you change anything.

- Never add a `Signed-off-by` tag, in commits or in patch files. The human
  adds it.
- Never push, open a pull request or post a comment unless the human has read
  and approved it first.
- Never write a comment on an issue or pull request for the human. The human
  writes comments. You may edit, shorten or translate one the human wrote.
- Remind the human to say in the pull request what the LLM was used for. Do
  not add `Co-authored-by:` or other trailers that name a tool, and do not add
  links to the chat or agent session.
- Keep commit messages, pull request and issue descriptions short and in
  proportion to the change: what changes and why. No diff summaries, no long
  logs.
- Keep comments to a reasonable level. Do not overexplain, add comments to or
  remove comments from unrelated parts of the codebase.
- Prefix the commit subject with the package name, for example
  `foopkg: add libzot dependency`.
- Keep the init script, the UCI config and other OpenWrt integration files in
  `files/` next to the Makefile. Never install them from the upstream source
  archive, unless the OpenWrt project hosts that upstream.
- Give every patch you add or change in `<package>/patches/` a `git am`
  compatible header and a description that says where it stands upstream.
  Suggest sending the fix upstream where possible.
- Generate and update patches with
  `make package/<name>/{clean,prepare} QUILT=1` followed by
  `make package/<name>/refresh`, never by hand.
- Build the package and run it on a device or in QEMU before the human
  submits it. Report where it was tested, and never claim a test that did not
  run.
- Never open pull requests in bulk without a build, a runtime test and
  follow-up by the human for each one.
