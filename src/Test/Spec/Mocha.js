/* global exports, it, describe */

// module Test.Spec.Mocha

if (typeof describe !== "function" || typeof it !== "function") {
  throw new Error("Mocha globals seem to be unavailable!");
}

function itAsync_(only) {
  "use strict";
  return function (name) {
    return function (run) {
      return function () {
        var f = only ? it.only : it;
        f(name, function (done) {
          return run(function () {
            done();
            return function () {};
          })(function (err) {
            done(err);
            return function () {};
          })();
        });
      };
    };
  };
}

export { itAsync_ as itAsync };

export function itPending(name) {
  "use strict";
  return function () {
    it(name);
  };
}

function describe_(only) {
  "use strict";
  return function (name) {
    return function (nested) {
      return function () {
        var f = only ? describe.only : describe;
        f(name, function () {
          nested();
        });
      };
    };
  };
}

export { describe_ as describe };

export function afterAsync(name) {
  "use strict";
  return function (run) {
    return function () {
      after(name, function (done) {
        return run(function () {
          done();
          return function () {};
        })(function (err) {
          done(err);
          return function () {};
        })();
      });
    };
  };
}
