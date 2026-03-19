import { $, semver } from "bun";
import { parseArgs } from "node:util";

const { values } = parseArgs({
  args: Bun.argv.slice(2),
  strict: true,
  options: {
    flake: {
      type: "string",
    },
    package: {
      type: "string",
    },
  },
});

if (!values.flake) {
  console.error("Flake is required");
  process.exit(1);
}

if (!values.package) {
  console.error("Package is required");
  process.exit(1);
}

const pnpmList = await $`pnpm list --json --prod --no-optional --lockfile-only --long`
  .cwd(`packages/${values.package}`)
  .json();

const t3 = pnpmList[0].dependencies.t3;
const latestVersion = await fetch(`https://registry.npmjs.org/t3/latest`)
  .then((res) => res.json())
  .then((data: any) => data.version as string);

if (latestVersion !== t3.version) {
  console.log(`Updating t3 from ${t3.version} to ${latestVersion}`);
  await $`pnpm add t3@${latestVersion} --ignore-scripts`.cwd(`packages/${values.package}`);
  console.log(
    `nix-update --flake ${values.package} --version ${latestVersion} --override-filename "packages/${values.package}/default.nix"`,
  );
}
