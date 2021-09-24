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
