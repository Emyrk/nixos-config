#!/usr/bin/env -S deno run --allow-env --allow-run --allow-net --allow-read --allow-write --unstable --no-check --ext=ts

// This fetches the latest version of each extension and updates the
// vscode-extensions.json file with the new version and sha256 hash.
//
// This makes it much easier to manage VS Code extensions with Nix.

import { createHash } from "https://deno.land/std@0.108.0/hash/mod.ts";
import * as semver from "https://deno.land/std@0.198.0/semver/mod.ts";
import { parse } from "https://deno.land/std@0.194.0/flags/mod.ts";
import { execSync } from "https://deno.land/std@0.173.0/node/child_process.ts";
import { os } from "https://deno.land/std@0.173.0/node/internal_binding/constants.ts";

interface Extension {
  readonly publisher: string;
  readonly name: string;

  version?: string;
  sha256?: string;
}

interface RemoteExtension {
  readonly displayName: string;
  readonly latestVersion: string;
  readonly vsixDownloadURL: string;
}

const vscodeVersion = execSync("code --version", {})
  .toString()
  .trim()
  .split("\n")[0];

const extensionID = (p: string, n: string) => `${p}.${n}`.toLowerCase();

const fetchExtensions = async (
  toFetch: ReadonlyArray<Extension>
): Promise<Record<string, RemoteExtension>> => {
  const requestUrl = `https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery`;
  const postData = JSON.stringify({
    filters: [
      {
        criteria: toFetch.map((e) => ({
          // Filter type 7 is by ID.
          filterType: 7,
          value: extensionID(e.publisher, e.name),
        })),
      },
    ],
    // See: https://github.com/microsoft/vscode/blob/29736e1ff8aa5ac860b539997c386163f8434bb6/src/vs/platform/extensionManagement/common/extensionGalleryService.ts#L102
    flags: 0x1 | 0x2 | 0x10,
  });
  const result = await fetch(requestUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept-Encoding": "gzip",
      Accept: "application/json;api-version=3.0-preview",
    },
    body: postData,
  });
  const response: {
    results?: [
      {
        extensions: [
          {
            displayName: string;
            extensionName: string;
            publisher: {
              publisherName: string;
            };
            versions: [
              {
                version: string;
                targetPlatform?: "linux-arm64" | "linux-x64";
                properties?: [
                  {
                    key: string;
                    value: string;
                  }
                ];
                files: [
                  {
                    assetType: string;
                    source: string;
                  }
                ];
              }
            ];
          }
        ];
      }
    ];
  } = await result.json();
  if (!response.results || !response.results.length) {
    throw new Error("no results");
  }
  const extensions: Record<string, RemoteExtension> = {};

  response.results[0].extensions.forEach((extension) => {
    const version = extension.versions.filter((v) => {
      if (!v.properties) {
        return false;
      }
      if (
        v.targetPlatform &&
        Deno.build.arch === "x86_64" &&
        v.targetPlatform !== "linux-x64"
      ) {
        return false;
      }
      if (
        v.targetPlatform &&
        Deno.build.arch === "aarch64" &&
        v.targetPlatform !== "linux-arm64"
      ) {
        return false;
      }
      const engine = v.properties.find(
        (p) => p.key === "Microsoft.VisualStudio.Code.Engine"
      );
      if (!engine) {
        return false;
      }
      if (engine.value.startsWith("^")) {
        engine.value = engine.value.slice(1);
      }
      const range = semver.parseRange(`>=` + engine.value);
      return semver.testRange(vscodeVersion, range);
    })[0];
    if (!version) {
      throw new Error("no valid version found for " + extension.extensionName);
    }
    const vsix = version.files.filter(
      (v) => v.assetType === "Microsoft.VisualStudio.Services.VSIXPackage"
    );
    if (!vsix.length) {
      throw new Error("no vsix found for " + extension.extensionName);
    }
    extensions[
      extensionID(extension.publisher.publisherName, extension.extensionName)
    ] = {
      displayName: extension.displayName,
      latestVersion: version.version,
      vsixDownloadURL: vsix[0].source,
    };
  });

  return extensions;
};

// downloadAndDash
const downloadAndHash = async (url: string) => {
  const res = await fetch(url);
  const hash = createHash("sha256");
  hash.update(await res.arrayBuffer());
  const hashInBase64 = btoa(
    String.fromCharCode.apply(null, Array.from(new Uint8Array(hash.digest())))
  );
  return `sha256-${hashInBase64}`;
};

const flags = parse(Deno.args, {
  boolean: ["help", "update", "status-bar", "commit"],
  string: ["install"],
});
if (flags.help) {
  console.error("Usage: nix-vscode-extensions.ts <path-to-manifest>");
  Deno.exit(1);
}

const repoPath = `${Deno.env.get("HOME")}/nixos-config`;

let manifestPath = flags._[0] as string;
if (!manifestPath) {
  manifestPath = `${repoPath}/home/programs/vscode/extensions.json`;
}

const writeManifest = async (extensions: ReadonlyArray<Extension>) => {
  extensions = extensions.toSorted((a, b) =>
    extensionID(a.publisher, a.name) > extensionID(b.publisher, b.name) ? 1 : -1
  );
  await Deno.writeTextFile(
    manifestPath,
    JSON.stringify(extensions, undefined, "  ")
  );
};

const text = await Deno.readTextFile(manifestPath);
const extensions: ReadonlyArray<Extension> = JSON.parse(text);

if (flags.install) {
  const [publisher, name] = flags.install.split(".");
  if (!publisher || !name) {
    console.error("invalid extension ID: should be 'publisher.name'");
    Deno.exit(1);
  }
  const id = extensionID(publisher, name);
  const existing = extensions.find(
    (e) => extensionID(e.publisher, e.name) === id
  );
  if (existing) {
    console.error("extension already installed:", id);
    Deno.exit(1);
  }
  const fetched = await fetchExtensions([{ publisher, name }]);
  if (!fetched[id]) {
    console.error("no extension found for", id);
    Deno.exit(1);
  }
  await writeManifest([
    ...extensions,
    {
      name,
      publisher,
      version: fetched[id].latestVersion,
      sha256: await downloadAndHash(fetched[id].vsixDownloadURL),
    },
  ]);
  console.log(
    `%c${id} v${fetched[id].latestVersion}:%c added to manifest`,
    `font-weight: bold`,
    `font-weight: normal; color: green`
  );
  Deno.exit(0);
}

const remoteExtensions = await fetchExtensions(extensions);
let outdated = 0;

for (const extension of extensions) {
  const fetched = remoteExtensions[extension.publisher + "." + extension.name];
  if (!fetched) {
    console.warn(
      "No remote extension found for",
      extension.publisher,
      extension.name
    );
    continue;
  }
  const id = extension.publisher + "." + extension.name;
  if (extension.version) {
    try {
      const current = semver.parse(extension.version);
      const latest = semver.parse(fetched.latestVersion);
      if (semver.compare(current, latest) >= 0) {
        if (!flags["status-bar"]) {
          console.log(
            `%c${id}:%c up-to-date`,
            `font-weight: bold;`,
            `font-weight: normal;`
          );
        }
        continue;
      }
    } catch {
      // Continue...
    }
  }
  if (flags.update) {
    extension.version = fetched.latestVersion;
    extension.sha256 = await downloadAndHash(fetched.vsixDownloadURL);
  }
  if (flags["status-bar"]) {
    outdated++;
    // Continue so we can print the status bar
    continue;
  }
  console.log(
    `%c${id}:%c ${extension.version || "uninitialized"} => ${
      fetched.latestVersion
    }`,
    "font-weight: bold;",
    "font-weight: regular;"
  );
}

if (flags["status-bar"]) {
  if (outdated === 0) {
    console.log("up to date");
  } else {
    console.log(`${outdated} outdated`);
  }
  Deno.exit(0);
}

await writeManifest(extensions);

if (flags["commit"]) {
  const diff = new Deno.Command("git", {
    args: ["diff", "--exit-code"],
    cwd: repoPath,
  });
  if (diff.outputSync().code === 0) {
    console.log("no changes to commit");
    Deno.exit(0);
  }
  const commit = new Deno.Command("git", {
    args: ["commit", "-m", "Update vscode-extensions.json", manifestPath],
    cwd: repoPath,
  });
  if (commit.outputSync().code !== 0) {
    console.error("failed to commit");
    Deno.exit(1);
  }
  const push = new Deno.Command("git", {
    args: ["push"],
    cwd: repoPath,
  });
  if (push.outputSync().code !== 0) {
    console.error("failed to push");
    Deno.exit(1);
  }
}
