# My Wild Life — web publishing

This repo holds the published version of Laurie's outdoor log. It is generated, not
hand-edited: everything under `docs/` is build output.

## Where things live

| What | Where |
| --- | --- |
| Source of truth (entries, originals, dashboard) | `G:\My Drive\claude_cowork\OUTPUTS\Outdoor Log\` |
| Build script | `<that folder>\build_site.py` |
| This repo (git) | this folder — keep it on the local disk, **not** on `G:` |
| Build output (what Pages serves) | `docs/` inside this folder |
| Live site | https://mywildlife.lauriebryce.com |

The source folder is Google Drive for desktop. A `.git` directory inside a Drive-synced
folder tends to corrupt as Drive syncs its internals mid-operation, so the repo stays
local and only reads from `G:`.

Entries are written in Claude (Cowork) sessions, which update `activities/*.md`,
`photos/<entry-id>/`, and the `LOG` JSON block inside `dashboard.html`. Nothing in this
repo should be edited to change content — fix the source and rebuild.

## Publish

```powershell
.\publish.ps1
```

That rebuilds from the source folder, rewrites `docs/CNAME` and `docs/.nojekyll`,
aborts if the noindex tags are missing, then commits and pushes. GitHub Pages serves
`main` / `docs` and redeploys within a minute or so.
`build_site.py` needs Pillow (`pip install Pillow`).

**`--out` must be `docs`, never `.`** — the script calls `shutil.rmtree(out)`
before rebuilding, so aiming it at the repo root deletes `.git` and this file on every
publish. Everything inside `docs/` is disposable and regenerated; everything outside it
(`.git`, `CLAUDE.md`, `publish.ps1`, `.gitignore`, `.claude/`) is not.

## Constraints — keep these

**Strip EXIF.** `build_site.py` re-encodes every photo through Pillow, which drops all
EXIF including GPS. Several entries were shot at Laurie's house in Stowe and on her own
land. Never copy original files into this repo, and never add an EXIF-preserving path to
the build.

**Keep the page noindex.** `docs/index.html` carries
`<meta name="robots" content="noindex, nofollow, noarchive, noimageindex">` and
`<meta name="referrer" content="no-referrer">`. The site is deliberately unlisted — not
linked from anywhere, not meant to be found — but it is publicly served, because GitHub
Pages is public even from a private repo. The meta tag is the only thing keeping it out
of search results.

**Don't list the path in a root robots.txt.** `robots.txt` here applies to the subdomain
and is fine. But if a redirect from `lauriebryce.com/mywildlife` is ever added, do not
add a `Disallow: /mywildlife/` line to `lauriebryce.com/robots.txt` — that file is
public and would advertise the path to anyone who reads it.

**Photos are web-res only.** 1600px long edge at quality 82, plus a 640px thumbnail
under `photos/<entry-id>/thumb/` used for the gallery grid, with the 1600px version in
the lightbox. Laurie will never print from this. Current build is 85 photos, 42 MB,
down from 243 MB of originals.

**There is no map — don't add one back casually.** The page used to show a Leaflet map
with OpenStreetMap tiles. OSM's tile servers are volunteer-run and their usage policy
disallows this kind of use, especially from a page sending `no-referrer`; it started
returning *403 Access Blocked* intermittently. Removed 2026-09-23 from `dashboard.html`
(Leaflet CDN tags, `#map`, and the marker code in `render()`). A map needs a tile source
that permits it — an API key or a paid basemap — not OSM's public servers.

**Entry coordinates never reach the web.** `build_site.py` drops `lat`/`lng` from the LOG
block when it writes `index.html` (see `strip_coords`). Nothing on the page reads them now
that the map is gone, and publishing ~11 m coordinates for entries shot at the house would
undo the point of stripping photo EXIF. The source `dashboard.html` and the `activities/*.md`
front matter keep them as the private record — only the build loses them, so this self-heals
if new entries arrive carrying coordinates.

## DNS

`mywildlife.lauriebryce.com` is a CNAME to `lauriebryce.github.io`, added at DreamHost.
Pages keeps the domain in `docs/CNAME`. The build script wipes and recreates `docs/`,
so that file must be rewritten after every build — the publish command above does it. The main site
(lauriebryce.com) is static hosting on DreamHost at 64.90.54.5 and is unaffected. A
redirect from `lauriebryce.com/mywildlife` can be added in DreamHost's `.htaccess` if
the original URL is wanted as a front door.
