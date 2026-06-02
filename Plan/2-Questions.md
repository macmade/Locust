# Locust Clarifying Questions

Please answer by editing this file. Short answers are fine.

## 1. First Implementation Target

Should the first working model be:

- Option A: a very small statistical baseline, such as an n-gram model, to validate the CLI, tokenizer, training loop, serialization, and REPL quickly.
- Option B: start directly with transformer components, even if it takes longer before end-to-end text generation works.

Answer: Option A. Start with an n-gram baseline first, then build transformer components incrementally once the CLI, tokenizer, serialization, sampling, and REPL are working end to end.

## 2. Educational Scope

How much math should the code expose directly?

- Option A: explicit matrix/vector code with clear loops, even if verbose.
- Option B: small reusable tensor/matrix helpers to keep model code shorter.
- Option C: a hybrid: clear low-level math primitives, then readable model layers built on top.

Answer: Option C. Use clear low-level math primitives, then build readable model layers on top. Prefer explicit implementation over clever abstractions, but avoid duplicating matrix/vector loops throughout the model code.

## 3. Tokenization Details

Should the word tokenizer:

- Preserve original casing, or lowercase all text?
- Preserve whitespace/newline tokens, or reconstruct output with simple spacing rules?
- Include special tokens such as `<unk>`, `<bos>`, and `<eos>`?

Answer: Preserve original casing. Do not preserve whitespace/newline tokens initially; reconstruct output with simple spacing rules. Include `<unk>`, `<bos>`, and `<eos>` special tokens.

## 4. Vocabulary Limits

Should training keep every token found in the corpus, or should there be a configurable vocabulary limit with rare tokens mapped to `<unk>`?

Answer: Use a configurable vocabulary limit. Rare tokens beyond the limit should be mapped to `<unk>`. For small corpora, the default may keep all tokens, but the implementation should support limiting vocabulary size.

## 5. Training Data Format

For supervised next-token prediction, should the dataset use:

- Fixed-length context windows, for example `contextLength = 16`.
- Variable-length examples up to a maximum context length.

Preferred default context length, if any:

Answer: Use fixed-length context windows for training examples. Default to `contextLength = 16` initially, with the value configurable later from the CLI or training configuration.

## 6. Numeric Type

Should the model use `Double` throughout for simpler testing and numerical stability, or `Float` to better match typical ML implementations?

Answer: Use `Double` throughout the initial implementation for simpler tests, clearer numerical behavior, and better stability while learning. Performance is not a priority.

## 7. Randomness

Is deterministic behavior from `--seed` required for:

- Sampling only.
- Training initialization and sampling.
- All randomized behavior, including shuffling.

Answer: The `--seed` value should control all randomized behavior, including model initialization, training data shuffling, and sampling.

## 8. Model File Compatibility

Should saved model files include a format/schema version so future versions can reject or migrate old files cleanly?

Answer: Yes. Saved model files should include a format/schema version so future versions can reject incompatible files or migrate them cleanly.

## 9. Serialization Formats

For `--format binary`, is a simple custom binary format acceptable, or should binary serialization use Swift `Codable` with a binary encoder if available in the project?

Answer: Use a simple custom binary format for `--format binary`, with an explicit magic header, schema version, model type, and length-prefixed sections. JSON should remain available as the human-readable/debug format.

## 10. CLI Behavior

During `--create`, should the executable train and save the model only, or also optionally enter the interactive REPL after training?

Answer: During `--create`, train and save the model only. Starting the interactive REPL should require `--model <MODEL_FILE>`.

## 11. Generation Defaults

What default generation length should the REPL use when completing a prompt?

Should generation stop on `<eos>` if the model produces it?

Answer: Default REPL generation length should be 40 tokens. Generation should stop early if the model produces `<eos>`.

## 12. Progress Reporting

What level of training progress output do you want?

- Minimal: start/end messages only.
- Basic: epoch, loss, and elapsed time.
- Detailed: batch-level progress plus epoch summaries.

Answer: Basic progress reporting: show epoch, loss, elapsed time, and final save path. Avoid batch-level output unless a verbose option is added later.

## 13. Testing Priorities

Are there specific areas where you want especially strong tests first, such as tokenizer behavior, serialization compatibility, deterministic sampling, gradient checks, or CLI argument parsing?

Answer: Prioritize tests for tokenizer behavior, vocabulary construction, dataset/window generation, serialization round trips, deterministic sampling, and CLI argument parsing. When transformer components are added, include focused math tests and gradient checks for low-level primitives and layers.

## 14. Xcode/Swift Constraints

What Swift version and minimum macOS deployment target should the implementation support?

Answer: Use the Swift version required by the existing Xcode project.

## 15. External Dependencies

The prompt excludes external machine-learning frameworks. Are small non-ML dependencies acceptable for argument parsing or binary encoding, or should the project use only the Swift standard library and existing Apple frameworks?

Answer: Use only the Swift standard library and existing Apple frameworks. Avoid adding third-party dependencies. For argument parsing, use swift-argument-pasrer (already available in the project).

