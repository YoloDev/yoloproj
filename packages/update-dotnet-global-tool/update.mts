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

const EVAL_PATH = process.env.EVAL_PATH;
if (!EVAL_PATH) {
  console.error("EVAL_PATH is not set");
  process.exit(1);
}

const root = (await $`git rev-parse --show-toplevel`.text()).trim();
$.cwd(root);

const pkgArg = `let flake = builtins.getFlake "${values.flake}"; in flake.packages.x86_64-linux.${values.package}`;
const info = await $`nix eval --json --file ${EVAL_PATH} --arg pkg "${pkgArg}" info`.json();
//console.log(info);

const packageInfo = await fetch(
  `https://api.nuget.org/v3-flatcontainer/${info.nugetPackage}/index.json`,
).then((res) => res.json() as any);

const versions = packageInfo.versions.filter((v: string) => !/-/.test(v)).sort(semver.order);
const lastVersion = versions.at(-1);
// console.log(lastVersion);

if (lastVersion !== info.nugetVersion) {
  console.log(`Updating ${info.nugetPackage} from ${info.nugetVersion} to ${lastVersion}`);
  await $`nix-update --flake ${values.package}.nupkg --version ${lastVersion} --override-filename "packages/${values.package}/default.nix"`;
}
