import { $ } from "bun";

const PACKAGES_JSON = process.env.PACKAGES;
if (!PACKAGES_JSON) {
  console.error("PACKAGES is not set");
  process.exit(1);
}

const packages = JSON.parse(PACKAGES_JSON) as Array<{
  name: string;
  update: string;
}>;

const root = (await $`git rev-parse --show-toplevel`.text()).trim();
$.cwd(root);

const flakeInfo = await $`nix flake info --json`.json();
const flakeUrl = flakeInfo.url as string;
if (!flakeUrl) {
  console.error("Failed to get flake URL");
  process.exit(1);
}

// console.log(packages);

for (const pkg of packages) {
  console.log(`Updating ${pkg.name}...`);
  await $`"${pkg.update}" --flake "${flakeUrl}" --package "${pkg.name}"`;
}
