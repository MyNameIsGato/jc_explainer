# JC Explainer

<p align="center">
  <img alt="Jupiter Coast Logo" src="JupiterCoastHalf.png" />
</p>

_JC Explainer_ is an add-on for Godot 4.5+ which provides a moderately opinionated conditional UI pop-up system, aimed at streamlining tutorial creation.

## Installation

1. Download a copy of the plug-in from GitHub.
1. Copy the `jc_explainer` folder into your project's `addons/` directory.
2. Open **Project → Project Settings → Plugins**.
3. Enable **JC Explainer**.


## Getting Started

1. Add an `ExplainerWatcher` instance to your scene.
6. Add an `Explainer` instance as a child of the `ExplainerWatcher`.
7. Create a `SignalCondition` resource as the trigger for the `ExplainerWatcher` and save it to disk.
8. When you want to trigger the `Explainer`, load the `SignalCondition` and emit from it.
	* `load("path/to/signal/resource.tres").emit()`

## TODO:
1. Debug mode

## Disclaimer
This exists (primarily) as a reusable model for Jupiter Coast use cases, and is infrequently updated/maintained based on internal needs.
