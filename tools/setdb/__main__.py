"""CLI: `uv run python -m tools.setdb <command>`.

Commands:
  fetch     download / refresh cached wiki pages (network)
  import    copy the in-game /cm sets:dump from SavedVariables [path]
  parse     cached pages -> data/sets/*.json + reports (offline)
  validate  check data/sets/*.json against schema.json (offline)
  build     parse + validate + digest
  digest    data/sets/sets.json -> compact LLM digest [--types a,b] [--no-text]
"""

from __future__ import annotations

import sys


def main(argv: list[str]) -> int:
    cmd = argv[0] if argv else "help"
    if cmd == "fetch":
        from . import fetch

        return fetch.run()
    if cmd == "import":
        from . import reconcile

        return reconcile.run_import(argv[1:])
    if cmd == "parse":
        from . import parse

        return parse.run()
    if cmd == "validate":
        from . import validate

        return validate.run()
    if cmd == "build":
        from . import digest, parse, validate

        return parse.run() or validate.run() or digest.run([])
    if cmd == "digest":
        from . import digest

        return digest.run(argv[1:])
    print(__doc__, file=sys.stderr)
    return 0 if cmd in ("help", "-h", "--help") else 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
