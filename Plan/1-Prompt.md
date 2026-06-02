# Locust

I want to explore and better understand LLMs by creating a simple toy language model project in Swift.

The goal is to build a command-line executable that can:

1. Train a language model from a plain-text corpus.
2. Save the trained model to disk.
3. Load a previously trained model.
4. Perform next-token prediction.
5. Generate text interactively through auto-completion.

This project is intended for learning purposes.  
Clarity, simplicity, and testability are more important than performance, scalability, or state-of-the-art results.

I am not interested in reinforcement learning, RLHF, fine-tuning, distributed training, or production-grade optimizations.  
The focus should remain on supervised next-token prediction and text generation.

## Command-Line Interface

The executable should support the following options.  
Additional options may be added if they improve usability.

### Training

* `--create <TEXT_FILE>`  
  Train a new model from the specified text corpus.
* `--output <MODEL_FILE>`  
  Path of the generated model file. Defaults to <input_file>.locust.
* `--format json|binary`  
    Serialization format for saved models. Defaults to binary.

### Generation

* `--model <MODEL_FILE>`  
  Load an existing model and start an interactive generation session.

### Sampling

* `--seed <INT>`  
  Random seed used for deterministic sampling.
* `--temperature <FLOAT>`  
  Sampling temperature. Lower values produce more deterministic output. Defaults to 1.0.
* `--top-k <INT>`  
  Restrict sampling to the k most probable tokens. A value of 0 disables top-k filtering. Defaults to 0.

### General

* `--help`  
  Display usage information.

## Project Structure

The Xcode project already exists and contains three targets:

### Locust

The command-line executable.

#### Responsibilities:

* Argument parsing
* File I/O
* Interactive terminal interface
* Progress reporting

### LocustKit

The language-model library.

#### Responsibilities:

* Tokenization
* Vocabulary management
* Dataset preparation
* Model implementation
* Training
* Inference
* Serialization

### LocustKitTests

Unit tests for all production code contained in LocustKit.

## Architecture Requirements

* All language-model functionality must reside in LocustKit.
* The CLI target should remain a thin wrapper around the library.
* Production code should be designed for testability.
* Test-driven development is preferred.
* The implementation should favor readability over optimization.

## Tokenizer Requirements

* The tokenizer should be word-based.
* Words and punctuation marks must be separate tokens.

## Model Requirements

Eventually implement a small transformer-style language model entirely in Swift.  
Start with the smallest testable components and build up incrementally.  
The implementation should be educational rather than efficient.

The model should include:

* Token embeddings
* Positional embeddings
* Multi-head self-attention
* Feed-forward layers
* Next-token prediction head

## Scope Constraints

To keep the project manageable:

* Use relatively small embedding dimensions.
* Use a small number of transformer blocks.
* Use a small number of attention heads.
* Train entirely on CPU.
* Do not depend on external machine-learning frameworks.
* Favor straightforward implementations over mathematically optimized ones.

## Interactive Generation

When started with --model, the application should enter an interactive REPL.

Example:

```
> The quick brown
fox jumps over the lazy dog

> Once upon a time
there was a small transformer model
```

The user should be able to:

* Enter prompts repeatedly.
* Generate completions from those prompts.
* Exit cleanly using a command such as quit or exit.

## Expected Deliverables

Before implementing anything:

1. Ask any important clarifying questions.
2. Propose the overall architecture.
3. Propose the training pipeline.
4. Propose the serialization format.
5. Produce a detailed implementation plan broken into small incremental milestones.
6. Prefer a test-first approach whenever practical.
