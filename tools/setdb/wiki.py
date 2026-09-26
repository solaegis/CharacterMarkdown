"""Polite MediaWiki API client for en.uesp.net.

- Identifies the project in the User-Agent.
- Throttles to at most one request per second.
- Retries transient failures with backoff and honours `maxlag` / Retry-After.
"""

from __future__ import annotations

import http.client
import json
import time
import urllib.error
import urllib.parse
import urllib.request
from collections.abc import Iterator
from typing import Any

API_URL = "https://en.uesp.net/w/api.php"
USER_AGENT = (
    "CharacterMarkdown-setdb/0.1 "
    "(+https://github.com/solaegis/CharacterMarkdown; ESO set database builder)"
)
MIN_INTERVAL_S = 1.0
MAX_RETRIES = 6
BATCH_TITLES = 50  # MediaWiki limit for titles= on anonymous requests


class WikiError(RuntimeError):
    pass


class WikiClient:
    def __init__(self, api_url: str = API_URL, min_interval_s: float = MIN_INTERVAL_S) -> None:
        self.api_url = api_url
        self.min_interval_s = min_interval_s
        self._last_request = 0.0
        self.request_count = 0

    def _throttle(self) -> None:
        wait = self._last_request + self.min_interval_s - time.monotonic()
        if wait > 0:
            time.sleep(wait)
        self._last_request = time.monotonic()

    def call(self, **params: Any) -> dict[str, Any]:
        params = {"format": "json", "formatversion": "2", "maxlag": "5", **params}
        body = urllib.parse.urlencode(params).encode()
        for attempt in range(MAX_RETRIES):
            self._throttle()
            # POST so long expandtemplates payloads don't hit URL length limits
            req = urllib.request.Request(
                self.api_url, data=body, headers={"User-Agent": USER_AGENT}
            )
            try:
                with urllib.request.urlopen(req, timeout=60) as resp:
                    self.request_count += 1
                    data = json.load(resp)
            except urllib.error.HTTPError as e:
                if e.code in (429, 500, 502, 503, 504) and attempt < MAX_RETRIES - 1:
                    time.sleep(float(e.headers.get("Retry-After", 2 ** (attempt + 1))))
                    continue
                raise WikiError(f"HTTP {e.code} for {params.get('action')}") from e
            except (
                urllib.error.URLError,
                http.client.IncompleteRead,
                ConnectionError,
                TimeoutError,
            ) as e:
                if attempt < MAX_RETRIES - 1:
                    time.sleep(min(30, 2 ** (attempt + 1)))
                    continue
                raise WikiError(str(e)) from e

            err = data.get("error")
            if err:
                if err.get("code") == "maxlag" and attempt < MAX_RETRIES - 1:
                    time.sleep(5)
                    continue
                raise WikiError(f"{err.get('code')}: {err.get('info')}")
            return data
        raise WikiError("retries exhausted")

    def query_all(self, list_name: str, **params: Any) -> Iterator[dict[str, Any]]:
        """Iterate a list= query, following `continue` tokens."""
        cont: dict[str, Any] = {}
        while True:
            data = self.call(action="query", list=list_name, **params, **cont)
            yield from data["query"][list_name]
            if "continue" not in data:
                return
            cont = data["continue"]

    def category_members(self, category: str, namespace: int | None = None) -> list[str]:
        params: dict[str, Any] = {"cmtitle": category, "cmlimit": "max"}
        if namespace is not None:
            params["cmnamespace"] = str(namespace)
        return [m["title"] for m in self.query_all("categorymembers", **params)]

    def latest_revids(self, titles: list[str]) -> dict[str, int]:
        """Map title -> latest revision id (missing pages are omitted)."""
        out: dict[str, int] = {}
        for chunk in _chunks(titles, BATCH_TITLES):
            data = self.call(action="query", prop="info", titles="|".join(chunk))
            for page in data["query"]["pages"]:
                if "missing" not in page:
                    out[page["title"]] = page["lastrevid"]
        return out

    def page_contents(self, titles: list[str]) -> list[dict[str, Any]]:
        """Fetch current wikitext + revision metadata for many pages."""
        out: list[dict[str, Any]] = []
        for chunk in _chunks(titles, BATCH_TITLES):
            data = self.call(
                action="query",
                prop="revisions",
                rvprop="content|ids|timestamp",
                rvslots="main",
                titles="|".join(chunk),
            )
            for page in data["query"]["pages"]:
                if "missing" in page or "revisions" not in page:
                    continue
                rev = page["revisions"][0]
                out.append(
                    {
                        "title": page["title"],
                        "pageid": page["pageid"],
                        "revid": rev["revid"],
                        "timestamp": rev["timestamp"],
                        "wikitext": rev["slots"]["main"]["content"],
                    }
                )
        return out

    def expand_templates(self, text: str, title: str = "Online:Sets") -> str:
        data = self.call(action="expandtemplates", text=text, prop="wikitext", title=title)
        return data["expandtemplates"]["wikitext"]


def _chunks(items: list[str], size: int) -> Iterator[list[str]]:
    for i in range(0, len(items), size):
        yield items[i : i + size]
