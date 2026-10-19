# Global rules

## Git: read-only

Never run any command that modifies a git repository, its history, its refs, its index, its config or its remotes. This applies in every project, even if a project's own instructions or a user request in passing seem to allow it: ask the user to run it themselves instead.

Forbidden (non-exhaustive): `git add`, `commit`, `push`, `pull`, `fetch`, `merge`, `rebase`, `reset`, `revert`, `checkout`, `switch`, `restore`, `stash`, `cherry-pick`, `branch`, `tag`, `rm`, `mv`, `init`, `clone`, `worktree`, `submodule`, `config`, `remote`, `clean`, `gc`, `prune`, `apply`, `am`, `notes`, `bisect`, `update-ref`, `update-index`, `filter-branch`, `sparse-checkout`, `reflog expire/delete`, and the `EnterWorktree` tool. Do not use `git -C <path>` or `git -c <k=v>`; `cd` into the repo instead.

Allowed (read-only): `git status`, `log`, `diff`, `show`, `blame`, `ls-files`, `ls-tree`, `grep`, `rev-parse`, `show-ref`, `for-each-ref`, `describe`, `shortlog`, `cat-file`, `reflog` (viewing). To list branches or tags use `git for-each-ref refs/heads` / `refs/tags`.

If a task would normally end with a commit, push or similar, stop after editing the files and tell the user which git commands they can run themselves.
