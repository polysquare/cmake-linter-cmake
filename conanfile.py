from conans import ConanFile
from conans.tools import download, unzip
import os

VERSION = "0.0.1"


class StyleLintCMakeConan(ConanFile):
    name = "cmake-linter-cmake"
    version = os.environ.get("CONAN_VERSION_OVERRIDE", VERSION)
    generators = "cmake"
    requires = ("cmake-include-guard/master@smspillaz/cmake-include-guard",
                "cmake-forward-arguments/master@smspillaz/cmake-forward-arguments",
                "tooling-find-pkg-util/master@smspillaz/tooling-find-pkg-util",
                "tooling-cmake-util/master@smspillaz/tooling-cmake-util",
                "cmake-unit/master@smspillaz/cmake-unit")
    url = "http://github.com/polysquare/cmake-linter-cmake"
    license = "MIT"

    def source(self):
        zip_name = "cmake-linter-cmake.zip"
        download("https://github.com/polysquare/"
                 "cmake-linter-cmake/archive/{version}.zip"
                 "".format(version="v" + VERSION),
                 zip_name)
        unzip(zip_name)
        os.unlink(zip_name)

    def package(self):
        self.copy(pattern="Find*.cmake",
                  dst="",
                  src="cmake-linter-cmake-" + VERSION,
                  keep_path=True)
        self.copy(pattern="*.cmake",
                  dst="cmake/cmake-linter-cmake",
                  src="cmake-linter-cmake-" + VERSION,
                  keep_path=True)
