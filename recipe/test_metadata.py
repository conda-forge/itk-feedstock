"""Verify conda ITK exposes its umbrella and component distribution metadata."""

from __future__ import annotations

import sys
from importlib.metadata import distribution


version = sys.argv[1]
expected_dependencies = {
    "itk": {
        f"itk-core=={version}",
        f"itk-numerics=={version}",
        f"itk-io=={version}",
        f"itk-filtering=={version}",
        f"itk-registration=={version}",
        f"itk-segmentation=={version}",
        "numpy",
    },
    "itk-core": {"numpy"},
    "itk-numerics": {f"itk-core=={version}"},
    "itk-io": {f"itk-core=={version}"},
    "itk-filtering": {f"itk-numerics=={version}"},
    "itk-registration": {f"itk-filtering=={version}"},
    "itk-segmentation": {f"itk-filtering=={version}"},
}

for name, dependencies in expected_dependencies.items():
    installed = distribution(name)
    assert installed.version == version, (name, installed.version, version)
    assert set(installed.requires or []) == dependencies, (
        name,
        installed.requires,
        dependencies,
    )
    assert installed.read_text("INSTALLER") == "conda\n", name
    assert installed.read_text("top_level.txt") == "itk\n", name

print(
    f"Validated Python distribution metadata for {len(expected_dependencies)} ITK packages"
)
