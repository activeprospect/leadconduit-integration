const _ = require('lodash');
const flat = require('flat');

const excludePatterns = [
  /^timestamp$/,
  /^timeout_seconds$/,
  /^random$/,
  /^flow\./,
  /^source\./,
  /^account\./,
  /^lead\.id/,
  /^recipient\./,
  /^submission\./,
  /\.outcome$/,
  /\.reason$/,
  /\.billable$/
];

// given the `vars` "snowball", this will strip all the data that a user
// wouldn't want delivered as a "lead". used, for example, by email-delivery
module.exports = function(vars, additionalExcludes = []) {

  for (var exclude of additionalExcludes) {
    // \b = word-boundary, so, e.g., "cc" doesn't exclude "accept"
    excludePatterns.push(_.isRegExp(exclude) ? exclude : RegExp(`\\b${exclude}\\b`));
  }

  const stripped = {};
  const flatVars = flat.flatten(vars);
  for (var key in flatVars) {
    if (!excludePatterns.some(val => key.match(val))) {
      // replace attribute, moving "lead." fields up a level
      _.set(stripped, key.replace(/^lead\./, ''), flatVars[key]?.valueOf());
    }
  }

  return stripped;
};
