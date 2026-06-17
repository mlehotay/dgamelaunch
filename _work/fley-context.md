# Floating Eye dgamelaunch Context

## Purpose

This document records the organizational, repository, development, deployment,
and operational context for the Floating Eye Software (`FLEY`) dgamelaunch
repository.

This repository predates FLEY by many years and has not adopted the FLEY
repo-level workflow. The presence of this document under `_work/` does not
install or imply adoption of that workflow. In particular, this repository
does not currently have repo-local plan and todo dashboards or an `AGENTS.md`
workflow file.

## Governance Layers

FLEY uses three distinct levels of governance:

1. `fley-qms` governs controlled SOPs, work instructions, and regulated work.
2. The `fley-org` organization process governs how FLEY decides what to work on
   next and handles organization-level prioritization and coordination.
3. The repo-level workflow governs how approved work gets done within an
   individual repository.

The canonical repo-level workflow template is:

```text
../fley-org/templates/repo-workflow.md
```

Not all repositories have adopted the repo-level workflow. Legacy repositories
such as `dgamelaunch` must not be assumed to use it. Workflow installation or
adoption should be an explicit, separately scoped decision.

## Repository Roles

### dgamelaunch

Local checkout:

```text
~/projects/dgamelaunch
```

This repository contains the dgamelaunch implementation and supporting
examples. It is currently on the `master` branch.

Relevant operational notes:

```text
examples/avocado.txt
examples/floatingeye.txt
```

### NetHack Variant

Local checkout:

```text
~/projects/nethack
```

This is the NetHack variant used by the Floating Eye public server. It is
currently on the `floatingeye` branch.

Relevant installation notes:

```text
sys/unix/Install.avocado
sys/unix/Install.turnip
```

Relevant build hints:

```text
sys/unix/hints/avocado
sys/unix/hints/floatingeye
```

### site-ops

Local checkout:

```text
~/projects/site-ops
```

`site-ops` owns web-estate operations and contains the current planning surface
for maintenance of the public NetHack host:

```text
_work/plans/0007-illithid-maintenance.md
```

Static deployment of `www.floatingeye.net` is separate from NetHack and
dgamelaunch server maintenance.

### fley-org

Local checkout:

```text
~/projects/fley-org
```

`fley-org` is authoritative for organization-level topology, priorities,
authority boundaries, and coordination. Its organization process decides what
FLEY works on next. Its repo-workflow template describes how repositories may
manage approved work after adopting the workflow.

### fley-qms

`fley-qms` is authoritative for controlled SOPs, work instructions, CAPA,
change control, and regulated process governance. Routine repository work
should not be treated as QMS-controlled work unless the applicable controlled
process says otherwise.

## Systems And Environments

### turnip

`turnip` is the maintainer's laptop and local development system. The active
local checkouts are under:

```text
~/projects/dgamelaunch
~/projects/nethack
```

The NetHack instructions in `sys/unix/Install.turnip` describe both a
single-user local build and a chrooted build intended to resemble the public
server environment.

For a single-user local NetHack build, the instructions use
`sys/unix/hints/avocado`. For a chrooted Floating Eye build, they use
`sys/unix/hints/floatingeye`.

### avocado

`avocado` is the older development and test environment referenced by:

```text
examples/avocado.txt
../nethack/sys/unix/Install.avocado
```

The older checkout layout uses `~/sandbox` rather than `~/projects`.

### illithid / floatingeye.net

`illithid` is the public dgamelaunch and NetHack host for `floatingeye.net`.
The deployed chroot is rooted at:

```text
/opt/dgl
```

The existing NetHack runtime is:

```text
/opt/dgl/nh370
```

The public game service is reachable through the `nethack@floatingeye.net`
account. Deployment and maintenance notes are in
`examples/floatingeye.txt` and the `site-ops` illithid maintenance plan.

## Build And Deployment Model

The local and production notes establish the following general model:

- Build NetHack with `sys/unix/hints/floatingeye` for the dgamelaunch chroot.
- Build dgamelaunch with SQLite and shared-memory support and configure it to
  use `/opt/dgl/etc/dgamelaunch.conf`.
- Use `dgl-create-chroot` when creating the dgamelaunch chroot.
- Use NetHack `make install` for a fresh installation.
- Use NetHack `make update` for an existing deployed runtime when appropriate.
- Test the deployed NetHack binary from inside the chroot.
- Preserve ownership and permissions required by the `games` account and
  dgamelaunch.

These notes are historical operational guidance, not a complete or approved
production change procedure. Commands that delete or replace `/opt/dgl`, or
that update the existing runtime, require a separately reviewed production
plan.

The historical instructions contain a naming inconsistency between
`make fetch-Lua` and `make fetch-lua`. Confirm the valid target in the NetHack
checkout before relying on either spelling.

## Critical Production Constraint

The existing `nh370` runtime and dgamelaunch player state must be preserved.

On May 22, 2026, the live game menu showed an active `nh370` game for user
`iia`, started May 22, 2026 at 13:03:14, on dungeon level 38. This demonstrates
that illithid maintenance is not simply a rebuild or redeployment problem.

Any dgamelaunch, NetHack, operating-system, or host change must preserve:

- active and recoverable player games
- NetHack save compatibility
- required runtime state
- dgamelaunch user and player data
- enough of the existing `nh370` runtime to finish legacy games

Do not wipe `/opt/dgl` or replace the existing `nh370` runtime in a way that
breaks unfinished games.

NetHack 5.0.0 should be introduced side-by-side with `nh370`. Existing games
must continue using the compatible legacy runtime until they end or are
retired, while new games can use a separate NetHack 5.0.0 menu entry and
runtime.

## Work Routing

Use these ownership boundaries when new work is identified:

- Route controlled or regulated process changes to `fley-qms`.
- Route organization priorities, repository authority, and cross-repository
  coordination to `fley-org` and its organization process.
- Keep dgamelaunch implementation work in this repository.
- Keep NetHack variant implementation and build-hint work in `../nethack`.
- Keep public-host inventory and illithid maintenance planning in `site-ops`.
- Keep static `www.floatingeye.net` deployment separate from public NetHack
  host maintenance.

Until this repository explicitly adopts the FLEY repo-level workflow, do not
assume that repo-local dashboards, plan files, wrap-up procedures, or other
workflow surfaces are required here.

## Source References

```text
examples/avocado.txt
examples/floatingeye.txt
../nethack/sys/unix/Install.avocado
../nethack/sys/unix/Install.turnip
../site-ops/_work/plans/0007-illithid-maintenance.md
../fley-org/templates/repo-workflow.md
```
