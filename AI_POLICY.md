# AI policy

This file expands on the short [AI policy](CONTRIBUTING.md#ai-policy) from the
Contributing Guidelines. If these two disagree, the short one applies and this
one needs to be updated.

## Scope

This policy applies to all code contributions, alongside issues and pull
requests surrounding this codebase. This includes:

- Issue and PR descriptions
- Issue and PR comments
- Code review comments
- Commit messages

## Permitted usage

- Writing or changing code, patches and tests with an LLM, as long as you
  understand every line and can explain it in review.
- Letting an LLM draft a commit message, pull request description or issue
  description, as long as you review it, cut it down and disclose it.
- Translating or shortening a comment you wrote yourself.
- Asking an LLM to review your own change before you submit it.

## Forbidden usage

- Comments in discussions that an LLM wrote for you. You write your comments.
  An LLM may translate or shorten them, nothing more.
- Pull requests, pushes or comments that a tool publishes without you reading
  and approving each one first. This is what we mean by autonomous agents.
- Posting an LLM review of someone else's pull request from your account.
- Hiding or understating how much an LLM was involved.

## Disclosure

Tick the checkbox in the pull request template and say in the description
what the LLM was used for. For example: "The patch and the commit message were
drafted with an LLM, I reviewed both and tested them on my router." You do not
need to name the tool or model. In an issue, say it in the issue description.
What matters is that reviewers can tell at a glance where and how AI was
involved in your contribution.

> [!IMPORTANT]
> Do not add `Co-authored-by:` or other trailers that name a tool, and do not
> link to the chat or agent session. A trailer lists the tool as an author and
> says nothing about how it was used, and only the author can open a session.

## Signed-off-by

Only you add your `Signed-off-by`, never a tool. With it you certify the
[Developer Certificate of Origin](https://openwrt.org/submitting-patches#sign_your_work)
for the whole change, including the parts an LLM wrote. That includes making
sure no code was copied from a source under an incompatible license. The
other [commit rules](CONTRIBUTING.md#commits-in-your-pull-requests-should)
still apply.

## Patches

A patch to the packaged software follows the
[patch rules](CONTRIBUTING.md#patches): a `git am` compatible header, a
description with your `Signed-off-by`, and a note on where it stands upstream.
Send an LLM-written fix upstream where you can, so that the people who know
that code review it, and link the upstream pull request or issue in the patch.

## Testing

An LLM-assisted change needs the same testing as any other change. Build the
package and run it on a device or in a VM, for example x86/64 or armsr/armv8
in QEMU. Say in the pull request where and how you tested. Never claim a test
you did not run.

## Keep it short

Commit messages and pull request descriptions say what changes and why. Leave
out summaries of the diff, long test logs and filler. A reviewer should be able
to read the description in a minute.

## Review bot

The project's own review bot (currently the
[openwrt-ai](https://github.com/openwrt-ai) account) posts automated reviews
on pull requests. Its comments are advisory, and maintainers decide which of
them need to be addressed. The rules above apply to contributors, not to this
bot.

## Enforcement

> [!WARNING]
> If we suspect undisclosed AI usage in a contribution, we will ask for
> disclosure. If you refuse to provide one, we will reject the contribution, and
> close your PR or issue.

We may hide or remove comments that break these rules. The rules apply to
maintainers' contributions too.
