# Illithid Data Backup Runbook

## Purpose

This runbook describes how to make and verify a backup of the live
dgamelaunch and NetHack player data on `illithid`.

It is an informational runbook under `_work/`. It does not install the FLEY
repo-level workflow or authorize unrelated production changes.

## Current Situation

The historical backup command is recorded in `examples/floatingeye.txt`:

```sh
cd /opt/dgl
sudo tar -czf ~/backup/illithid.yyyy-mm-dd.tar.gz dgldir/ mail/ nh370/var/ bones/
```

The console log recorded on June 15, 2026 shows:

- live data under `/opt/dgl`
- approximately 15.5 GB of free space on the root filesystem
- historical archives under `~/backup`
- the newest clearly dated archive as `illithid.2024-10-04.tar.gz`
- placeholder-named archives that should not be treated as current backups

All observed archives are on `illithid`. A backup on the same host protects
against some operator mistakes, but not against host, disk, account, or
provider loss.

## Protected Data

The historical archive includes:

```text
/opt/dgl/dgldir/
/opt/dgl/mail/
/opt/dgl/nh370/var/
/opt/dgl/bones/
```

These paths include dgamelaunch account and user data, ttyrecs, game status,
mail, NetHack saves and playground state, logs, and collected bones.

The archive does not capture the entire host or all of `/opt/dgl`. Runtime
binaries, configuration, system configuration, source checkouts, and other
host state need separate preservation or reproducible deployment procedures.

## Critical Safety Constraints

- Do not remove, overwrite, restore, or change ownership of live data while
  making a backup.
- Do not stop dgamelaunch or NetHack merely to run the immediate backup.
- Do not assume `Users logged in: 0` means nobody is playing. dgamelaunch and
  NetHack processes must be checked separately.
- Do not restore an archive into `/opt/dgl` as a verification test.
- Preserve the existing `nh370` runtime for unfinished games.

The immediate archive procedure below reads live files without intentionally
interrupting games. It is safer than having no current backup, but it is not a
guaranteed point-in-time snapshot. A file, the SQLite database, or active
NetHack playground state could change while `tar` reads it.

## Immediate Live Backup

Connect to `illithid`, then inspect active game processes without changing
them:

```sh
pgrep -af 'dgamelaunch|nh370/nethack|/nethack' || true
```

Create a timestamped archive using a temporary name. Publish the final name
only after `tar` completes and the archive can be read:

```sh
cd /opt/dgl
stamp=$(date +%F-%H%M%S)
tmp="$HOME/backup/illithid.$stamp.tar.gz.partial"
final="$HOME/backup/illithid.$stamp.tar.gz"
sudo tar -czf "$tmp" dgldir/ mail/ nh370/var/ bones/ &&
sudo tar -tzf "$tmp" >/dev/null &&
sudo chown "$USER:$(id -gn)" "$tmp" &&
chmod 600 "$tmp" &&
mv "$tmp" "$final" &&
sha256sum "$final"
```

Record the final archive path and SHA-256 digest. If any command fails, leave
the live data alone and investigate. A `.partial` file is not a verified
backup.

GNU `tar` normally exits unsuccessfully if a file changes while it is being
archived. Treat warnings such as `file changed as we read it` as a failed
consistency check; do not rename that archive as a completed backup.

## Verify Archive Coverage

Confirm the archive is readable and contains all four expected roots:

```sh
tar -tzf "$final" >/dev/null
for path in dgldir mail nh370/var bones; do
    tar -tzf "$final" "$path/" >/dev/null || exit 1
done
ls -lh "$final"
sha256sum "$final"
```

Archive readability and path coverage do not prove that an active game was
captured at one consistent instant. They do prove that the compressed archive
is readable and contains the intended path trees.

## Copy Off Host

After creating the archive, copy it from `illithid` to protected storage on a
different system. Player account data and mail may be sensitive, so restrict
access to the copied archive.

Example from `turnip`, replacing the filename and expected digest:

```sh
umask 077
mkdir -p ~/backups/illithid
scp illithid.floatingeye.net:backup/illithid.YYYY-MM-DD-HHMMSS.tar.gz \
    ~/backups/illithid/
sha256sum ~/backups/illithid/illithid.YYYY-MM-DD-HHMMSS.tar.gz
```

Compare the local digest with the digest recorded on `illithid`.

## Stronger Backup Follow-Up

A robust recurring backup design should be planned separately. It should
address:

- a consistent point-in-time capture while games may be active
- SQLite database consistency
- active NetHack playground and save state
- encrypted off-host storage
- retention and pruning
- automated archive and checksum verification
- periodic restore tests into an isolated temporary location
- preservation of the compatible `nh370` runtime and configuration
- monitoring and notification when a scheduled backup fails

A quiesced backup or provider/filesystem snapshot may provide stronger
consistency, but interrupting or pausing the public service is a production
change and requires a separate reviewed plan.

## References

```text
examples/floatingeye.txt
examples/dgamelaunch.conf
TODO-floatingeye.txt
_work/fley-context.md
_work/console-log.txt
_work/console-log-2.txt
../site-ops/_work/plans/0007-illithid-maintenance.md
```
