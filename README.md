Locust
======

[![Build Status](https://img.shields.io/github/actions/workflow/status/macmade/Locust/ci-mac.yaml?label=macOS&logo=apple)](https://github.com/macmade/Locust/actions/workflows/ci-mac.yaml)
[![Issues](http://img.shields.io/github/issues/macmade/Locust.svg?logo=github)](https://github.com/macmade/Locust/issues)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg?logo=git)
![License](https://img.shields.io/badge/license-mit-brightgreen.svg?logo=open-source-initiative)  
[![Contact](https://img.shields.io/badge/follow-@macmade-blue.svg?logo=twitter&style=social)](https://twitter.com/macmade)
[![Sponsor](https://img.shields.io/badge/sponsor-macmade-pink.svg?logo=github-sponsors&style=social)](https://github.com/sponsors/macmade)

### About

> Fear not, the dark, my friend.  
> And let the feast begin.

Locust is a Swift/Xcode language-model playground for macOS. The project is structured around a thin `locust` command-line executable and a reusable `LocustKit` library that owns tokenization, vocabulary handling, dataset preparation, deterministic sampling, model training, inference, and serialization.

The first implementation target is an end-to-end n-gram next-token baseline. Transformer components are planned after the baseline CLI, model persistence, and tests are stable.

Status
------

Current implementation:

- `LocustKit` contains the first text-processing pieces: `WordTokenizer`, `WordDetokenizer`, `SpecialTokens`, `PunctuationSpacing`, and the `Tokenizing` and `Detokenizing` protocols.
- `LocustKitTests` contains focused tests for those text components.
- `Locust` is currently a command-line executable target that builds the `locust` product and imports `LocustKit` and `ArgumentParser`.

Planned baseline:

- Train an n-gram next-token model from a UTF-8 text corpus.
- Preserve original casing during tokenization.
- Treat whitespace and newlines as separators.
- Use `<unk>`, `<bos>`, and `<eos>` as the core special tokens.
- Use fixed-length context windows, defaulting to `16` tokens.
- Generate up to `40` tokens by default, stopping early at `<eos>`.
- Make `--seed` control initialization, shuffling, and sampling behavior.
- Save models as readable JSON or a compact custom binary format.

Planned Usage
-------------

Training a model:

```sh
locust --create Data/bloodborne-npc-dialogues.txt
```

Training with explicit output and format:

```sh
locust --create Data/bloodborne-npc-dialogues.txt --output bloodborne.locust --format binary
locust --create Data/bloodborne-npc-dialogues.txt --output bloodborne.json --format json
```

Loading a saved model and starting the REPL:

```sh
locust --model bloodborne.locust
```

Planned options:

```text
--create <TEXT_FILE>       Train and save a model.
--model <MODEL_FILE>       Load a model and start the REPL.
--output <MODEL_FILE>      Save path. Defaults to <input_file>.locust.
--format json|binary       Model format. Defaults to binary.
--seed <INT>               Seed for deterministic behavior.
--temperature <FLOAT>      Sampling temperature. Defaults to 1.0.
--top-k <INT>              Top-k sampling limit. Defaults to 0, meaning disabled.
```

Architecture
------------

The `locust` executable is intended to stay small:

- Parse command-line arguments.
- Read corpus files and write model files.
- Call training, loading, and generation APIs from `LocustKit`.
- Print basic training progress.
- Run the interactive prompt.
- Convert user-facing errors into readable terminal output.

`LocustKit` owns production behavior:

- Text tokenization and detokenization.
- Vocabulary construction and token/id mapping.
- Dataset window generation.
- Seeded random number generation.
- Temperature and top-k sampling.
- N-gram baseline modeling.
- JSON and binary model serialization.
- Future transformer math primitives, layers, training, and inference.

Initial Defaults
----------------

```text
format:             binary
contextLength:      16
temperature:        1.0
topK:               0
maxGeneratedTokens: 40
schemaVersion:      1
modelType:          ngram
vocabularyLimit:    unlimited by default
```

Development Notes
-----------------

- The project currently targets macOS 15.6 through the existing Xcode project settings.
- `swift-argument-parser` is available in the Xcode project and is the planned CLI parser.
- Tests should stay focused on `LocustKit` behavior and mirror the production source layout where practical.
- [Plan/1-Prompt.md](Plan/1-Prompt.md) contains the original project prompt.
- [Plan/2-Questions.md](Plan/2-Questions.md) contains clarifying answers and implementation decisions.
- [Plan/3-Plan.md](Plan/3-Plan.md) contains the implementation plan and milestones.

License
-------

Project is released under the terms of the MIT License.

Repository Infos
----------------

    Owner:          Jean-David Gadina - XS-Labs
    Web:            www.xs-labs.com
    Blog:           www.noxeos.com
    Twitter:        @macmade
    GitHub:         github.com/macmade
    LinkedIn:       ch.linkedin.com/in/macmade/
    StackOverflow:  stackoverflow.com/users/182676/macmade
