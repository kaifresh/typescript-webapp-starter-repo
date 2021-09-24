
# Create the files & folders you'll need
mkdir -p src
touch src/app.ts
mkdir .private.environments
echo ENVIRONMENT=development >> .private.environments/.env.development
echo ENVIRONMENT=production >> .private.environments/.env.production
touch .env.example
mkdir tests

# Download a Climate Strike MIT License
curl -k https://raw.githubusercontent.com/climate-strike/license/master/licenses/MIT -o LICENSE.TXT

# Create package.json
yarn init --yes
yarn add json typescript ts-node husky commitlint lint-staged
yarn add chai mocha danger nyc @types/chai @types/mocha eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin --dev

# Set package.json engine to highest supported by host
yarn run json -I -f package.json -e 'this.engines={}'
yarn run json -I -f package.json -e 'this.engines.node=">= 12.0"'

# npm complains if you specify a non-standard licence so this is how to reference
# the Climate-Strike license in LICENSE.txt 
yarn run json -I -f package.json -e 'this.license="SEE LICENSE IN LICENSE.txt"'

# Add some package.json scripts
yarn run json -I -f package.json -e 'this.scripts={}'
yarn run json -I -f package.json -e 'this.scripts["start:ts"]="ts-node src/app.ts"'
yarn run json -I -f package.json -e 'this.scripts.start="node build/app.js"'
yarn run json -I -f package.json -e 'this.scripts.clean="rm -rf build"'
yarn run json -I -f package.json -e 'this.scripts.lint="eslint"'
#yarn run json -I -f package.json -e 'this.scripts.add_config_files_to_build="cp package.json ./build/ && cp .env ./build/"'
yarn run json -I -f package.json -e 'this.scripts.build="yarn clean && tsc"'
yarn run json -I -f package.json -e 'this.scripts.test="mocha -r ts-node/register tests/**/*.test.ts"'
yarn run json -I -f package.json -e 'this.scripts["set-environment"]="cp .private.environments/.env.$ENVIRONMENT .env"'
yarn run json -I -f package.json -e 'this.scripts["use-development"]="ENVIRONMENT=development yarn set-environment"'
yarn run json -I -f package.json -e 'this.scripts["use-staging"]="ENVIRONMENT=staging yarn set-environment"'
yarn run json -I -f package.json -e 'this.scripts["use-production"]="ENVIRONMENT=production yarn set-environment"'

yarn run json -I -f package.json -e 'this.scripts["deploy-generic"]="echo ❌❌❌TODO❌❌❌"'
yarn run json -I -f package.json -e 'this.scripts["deploy-staging"]="ENVIRONMENT=staging yarn deploy-generic"'
yarn run json -I -f package.json -e 'this.scripts["deploy-production"]="ENVIRONMENT=production yarn deploy-generic"'

# configure DangerJS https://danger.systems/js/
yarn run json -I -f package.json -e 'this.scripts.prepush="yarn danger:prepush"'
yarn run json -I -f package.json -e 'this.scripts["prepush:prepush"]="yarn danger local --base develop --dangerfile dangerfile.lite.js"'


#yarn run json -I -f package.json -e 'this.husky={}'
#yarn run json -I -f package.json -e 'this.husky.hooks={}'

# TODO fix these the '-' char fails
# yarn run json -I -f package.json -e 'this.husky.hooks.pre-commit="lint_staged"'
# yarn run json -I -f package.json -e 'this.husky.hooks.commit-msg="commitlint"'
#yarn run json -I -f package.json -e 'this.lint_staged={}'
#yarn run json -I -f package.json -e 'this.lint_staged.'*.ts'=["eslint"]'
#yarn run json -I -f package.json -e 'this.husky.hooks={}'


# Create tsconfig
tsc --init --strict --target ES2019 --outDir "./build"  --noUnusedLocals  --noUnusedParameters --noImplicitReturns --noFallthroughCasesInSwitch  --lib "esnext" --sourceMap

# Create eslintrc (@see https://khalilstemmler.com/blogs/typescript/eslint-for-typescript/)
cat <<EOT >> .eslintrc
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "plugins": [
    "@typescript-eslint"
  ],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/eslint-recommended",
    "plugin:@typescript-eslint/recommended",
		"airbnb-typescript"
  ]
}
EOT

# Create eslintignore
cat <<EOT >> .eslintignore
node_modules
dist
built
EOT

# Set up pre-push rule reminding authors to update CHANGELOG
cat <<EOT >> dangerfile.lite.js
// dangerfile.lite.js
// @ts-check
import { danger, warn } from 'danger';
// Rule: CHANGELOG should be modified if app changes
const changelogWarning = 'Please add a CHANGELOG entry for your changes; or if trivial: mark PR body or title as #trivial';
const hasChangelog = danger.git.modified_files.includes('CHANGELOG.md');
const runningLocally = !danger.github;
if (runningLocally) {
  if (!hasChangelog) {
    warn(changelogWarning);
  }
} else {
  const isTrivial = danger.github.pr.body.includes('#trivial') || danger.github.pr.title.includes('#trivial');
  if (!hasChangelog && !isTrivial) {
    warn(changelogWarning);
  }
}
EOT

# Add a GitHub Pull Request Template
curl -k https://gist.githubusercontent.com/kaifresh/2d610bb8503b2a4944dfaa68105c423e/raw/16a8558406d57c37ffea968b6ca5444ab9d0aaf7/pull_request_template.md -o PULL_REQUEST_TEMPLATE.MD

# Add a .gcloudignore
curl -k https://gist.githubusercontent.com/kaifresh/7f4f6d1bd94f26b06a8bca6a2e345893/raw/781bfb5924a991210443e8d9db2a4febcadbaee2/.gcloudignore -o .gcloudignore

# Add a readme
curl -k https://raw.githubusercontent.com/othneildrew/Best-README-Template/master/BLANK_README.md -o README.MD

git add .
git commit -m 'Initial Repository Setup'