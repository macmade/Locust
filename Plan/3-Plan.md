# Locust Implementation Plan

This plan is based on `Plan/1-Prompt.md` and the answers in `Plan/2-Questions.md`.

## Guiding Decisions

- Build an end-to-end n-gram baseline first, then add transformer components incrementally.
- Keep all language-model behavior in `LocustKit`.
- Keep the `Locust` executable as a thin CLI wrapper.
- Use `swift-argument-parser` for the CLI, since it is already available in the Xcode project.
- Use only the Swift standard library and existing Apple frameworks beyond that existing dependency.
- Use `Double` for model math initially.
- Make `--seed` control all randomized behavior: initialization, shuffling, and sampling.
- Preserve original casing during tokenization.
- Do not preserve whitespace or newline tokens initially.
- Reconstruct output with simple spacing rules.
- Include `<unk>`, `<bos>`, and `<eos>` from the beginning.
- Use fixed-length context windows with default `contextLength = 16`.
- Default REPL generation length is 40 tokens.
- Stop generation early when `<eos>` is produced.
- Saved models must include a magic header, schema version, model type, and enough metadata to reject incompatible files.
- Support JSON for readable/debug serialization and a simple custom binary format for compact/default serialization.
- Current project deployment target is macOS 15.6. Follow the existing project settings unless there is a later reason to change them.

## Proposed Architecture

### Coding Style

- Prefer functional sequence operations such as `forEach`, `map`, `compactMap`, `filter`, `reduce`, and `sorted` over plain `for` loops when transforming or scanning collections.
- Prefer `reduce` or `reduce(into:)` for stateful collection-building logic instead of declaring mutable accumulator variables in the calling function.
- Keep functional code readable. If stateful accumulation is needed, make the state explicit and use focused helper methods rather than dense nested closures.
- Avoid introducing helper state types for small single-use transformations unless they materially improve readability or are reused.
- Define shared configuration values for special tokens and other domain strings. Do not inline magic token values such as `<unk>`, `<bos>`, or `<eos>` in production code or tests.
- Use plain loops only when they make low-level numerical code materially clearer, especially in later `Math` and `Layers` implementations. In those cases, keep the loop local and covered by focused tests.

### Naming Conventions

- Name capability protocols with gerund-style names when that reads naturally, such as `Tokenizing` and `Detokenizing`.
- Name concrete implementations by combining the strategy or scope with the capability, such as `WordTokenizer` and `WordDetokenizer`.
- Keep paired concepts symmetrical. If a tokenizer implementation uses a scope prefix such as `Word`, the corresponding detokenizer implementation should use the same prefix.
- Name test files and test types after the concrete behavior under test, such as `WordTokenizerTests` and `WordDetokenizerTests`.
- Avoid generic concrete names such as `Tokenizer` or `Detokenizer` unless there is intentionally only one implementation and no meaningful strategy distinction.
- Keep protocols in a `Protocols` subdirectory within their domain directory, such as `Text/Protocols/Tokenizing.swift`, so capability contracts are easy to find separately from concrete implementations.
- Keep protocols focused on required behavior, not concrete configuration details. Prefer initializer dependency injection on concrete implementations for strategy-specific rules such as punctuation spacing and special tokens.

### Target Boundaries

`Locust` executable:

- Parse command-line arguments.
- Read corpus files and write model files.
- Invoke training/loading/generation APIs from `LocustKit`.
- Print basic progress: epoch, loss, elapsed time, and final save path.
- Run the interactive prompt when `--model <MODEL_FILE>` is supplied.
- Convert user-facing errors into readable terminal output.

`LocustKit` library:

- Tokenization and detokenization.
- Vocabulary construction and token/id mapping.
- Dataset/window preparation.
- Seeded random number generation.
- Sampling with temperature and top-k.
- N-gram baseline model.
- Future transformer math primitives and layers.
- Training APIs.
- Inference APIs.
- JSON and binary model serialization.

`LocustKitTests`:

- Unit tests for all `LocustKit` production behavior.
- Focus first on tokenizer, vocabulary, dataset generation, serialization round trips, deterministic sampling, and model behavior.
- Add transformer math and gradient tests when transformer components are introduced.

### Source Layout

`LocustKit` should use domain-oriented subdirectories instead of keeping every source file at the target root. Keep the directory names stable and small enough that each group has a clear responsibility:

```text
LocustKit/
  Core/
    LocustError.swift
  Text/
    Protocols/
      Detokenizing.swift
      Tokenizing.swift
    PunctuationSpacing.swift
    SpecialTokens.swift
    Token.swift
    Vocabulary.swift
    WordDetokenizer.swift
    WordTokenizer.swift
  Data/
    Dataset.swift
    TrainingExample.swift
  Random/
    Sampling.swift
    SeededRandomNumberGenerator.swift
  Models/
    LanguageModel.swift
    NGramLanguageModel.swift
    TransformerLanguageModel.swift
  Training/
    Loss.swift
    Optimizer.swift
    TrainingConfiguration.swift
    TrainingProgress.swift
  Serialization/
    BinaryModelSerializer.swift
    JSONModelSerializer.swift
    ModelFile.swift
    ModelSerializer.swift
  Math/
    Math.swift
    Matrix.swift
    Vector.swift
  Layers/
    Embedding.swift
    FeedForward.swift
    LayerNorm.swift
    Linear.swift
    SelfAttention.swift
    Softmax.swift
    TransformerBlock.swift
```

Guidelines:

- `Core` is for shared errors and small cross-cutting primitives only.
- `Text` owns tokenization, detokenization, special token definitions, and vocabulary mapping.
- Domain protocols should live under a `Protocols` subdirectory inside the owning domain, such as `Text/Protocols`.
- `Data` owns conversion from token IDs into supervised training windows.
- `Random` owns deterministic randomness and sampling policies.
- `Models` owns model protocols and concrete language-model implementations.
- `Training` owns training configuration, progress reporting, optimizers, and loss functions.
- `Serialization` owns versioned model file envelopes and format-specific readers/writers.
- `Math` and `Layers` should remain transformer-focused and should not be introduced until the transformer milestones need them.
- Avoid nesting more deeply until a directory becomes genuinely hard to scan.
- Keep Swift file references ordered alphabetically in every Xcode group whenever files are added, renamed, or moved.

Tests should mirror the production layout where practical:

```text
LocustKitTests/
  Text/
    PunctuationSpacingTests.swift
    SpecialTokensTests.swift
    VocabularyTests.swift
    WordDetokenizerTests.swift
    WordTokenizerTests.swift
  Data/
    DatasetTests.swift
  Random/
    SamplingTests.swift
    SeededRandomNumberGeneratorTests.swift
  Models/
    NGramLanguageModelTests.swift
  Serialization/
    JSONModelSerializerTests.swift
    BinaryModelSerializerTests.swift
  Math/
    MatrixTests.swift
    VectorTests.swift
  Layers/
    SelfAttentionTests.swift
```

### Core Protocols

Use small protocols where they clarify boundaries and tests:

```swift
public protocol Tokenizing
{
    func tokenize(_ text: String) -> [String]
}

public protocol Detokenizing
{
    func detokenize(_ tokens: [String]) -> String
}

public protocol LanguageModel
{
    var vocabulary: Vocabulary { get }
    func logits(for context: [Int]) throws -> [Double]
}

public protocol TrainableLanguageModel
{
    associatedtype Configuration
    static func train(
        tokens: [String],
        configuration: Configuration,
        progress: ((TrainingProgress) -> Void)?
    ) throws -> Self
}
```

The exact signatures can evolve during implementation. The important point is to keep tokenization, training, prediction, sampling, and persistence testable independently.

## Tokenization And Vocabulary

### Tokenizer Behavior

The first tokenizer should be word-based:

- Words are tokens.
- Punctuation marks are separate tokens.
- Original casing is preserved.
- Whitespace and newlines are separators, not tokens.
- Special tokens are managed by the vocabulary/training pipeline, not by normal text tokenization.

Example:

```text
Hello, world!
```

Tokenizes as:

```text
["Hello", ",", "world", "!"]
```

### Detokenization

Use simple output reconstruction:

- No space before common closing punctuation: `. , ! ? : ; ) ] }`
- No space after common opening punctuation: `( [ {`
- Use a normal space between other adjacent tokens.
- Do not print `<bos>`.
- Stop before printing `<eos>`.
- Print `<unk>` only if it appears in generated output.
- Keep special tokens in a small configuration value such as `SpecialTokens`.
- Inject special tokens into components that need them, with a default Locust token set for `<unk>`, `<bos>`, and `<eos>`.
- Keep punctuation spacing rules in a small configuration value such as `PunctuationSpacing`.
- Inject punctuation spacing into `WordDetokenizer` through its initializer, with a sensible default for English-like text.

### Vocabulary

Vocabulary construction should:

- Always reserve `<unk>`, `<bos>`, and `<eos>`.
- Count corpus token frequencies.
- Keep every token by default for small corpora.
- Support a configurable maximum vocabulary size.
- Map tokens outside the vocabulary to `<unk>`.
- Provide stable token IDs by sorting primarily by descending frequency, then lexicographically for deterministic tie-breaking.

## Training Pipeline

### Baseline N-Gram Pipeline

The first end-to-end implementation should train an n-gram next-token model.

1. Read the corpus as UTF-8 text.
2. Tokenize using `WordTokenizer`.
3. Build a `Vocabulary`.
4. Convert tokens to IDs.
5. Add sequence markers:
   - Prefix with enough `<bos>` tokens to fill the initial context.
   - Append one `<eos>` token.
6. Produce fixed-length training examples:
   - Input: `contextLength` token IDs.
   - Target: the following token ID.
7. Count next-token occurrences for each context.
8. Store counts/probabilities in `NGramLanguageModel`.
9. Report basic progress.
10. Save the trained model in the selected format.

For the n-gram baseline, "loss" can be reported as average negative log likelihood over the training windows after counts are built. Use smoothing so unseen probabilities do not cause infinities.

### Transformer Pipeline Later

Once the baseline is stable, reuse the same tokenizer, vocabulary, dataset, sampling, and serialization infrastructure.

Transformer training should add:

- Matrix/vector math primitives.
- Parameter initialization controlled by the seed.
- Token embeddings.
- Positional embeddings.
- Multi-head causal self-attention.
- Feed-forward layers.
- Next-token prediction head.
- Cross-entropy loss.
- A simple optimizer, likely SGD first.
- Deterministic shuffling controlled by the seed.

The first transformer should intentionally be tiny:

- `contextLength = 16`
- Small embedding dimension, such as 16 or 32.
- 1 transformer block.
- 1 or 2 attention heads.
- Small feed-forward hidden size.

## Inference And Sampling

Prediction flow:

1. Tokenize the prompt.
2. Map prompt tokens to IDs using the model vocabulary.
3. Left-pad or trim to the model `contextLength`.
4. Ask the model for next-token logits/probabilities.
5. Apply temperature.
6. Apply top-k if `topK > 0`.
7. Sample using the seeded RNG.
8. Append the sampled token to the generated context.
9. Stop after 40 generated tokens by default or when `<eos>` appears.
10. Detokenize generated tokens for display.

Sampling rules:

- `temperature <= 0` should be rejected as invalid.
- `temperature == 1.0` leaves logits/probabilities unchanged.
- Lower temperature sharpens the distribution.
- Higher temperature flattens the distribution.
- `topK == 0` disables top-k filtering.
- `topK >= vocabularySize` should behave like no filtering.

## CLI Design

Use `ArgumentParser` with one top-level command.

Required behavior:

```text
locust --create <TEXT_FILE> [--output <MODEL_FILE>] [--format json|binary] [--seed <INT>] [--temperature <FLOAT>] [--top-k <INT>]
locust --model <MODEL_FILE> [--seed <INT>] [--temperature <FLOAT>] [--top-k <INT>]
locust --help
```

Interpretation:

- `--create` trains and saves only.
- `--model` loads a model and starts the REPL.
- `--output` defaults to `<input_file>.locust`.
- `--format` defaults to `binary`.
- `--seed` defaults to a documented constant if omitted.
- `--temperature` defaults to `1.0`.
- `--top-k` defaults to `0`.
- Reject commands that supply both `--create` and `--model`.
- Reject commands that supply neither `--create` nor `--model`.

REPL behavior:

- Show `>` prompt.
- Accept repeated prompts.
- Generate a completion for each prompt.
- Exit cleanly on `quit` or `exit`.
- Treat empty input as a no-op.

## Serialization Format

### Shared Model Envelope

Both JSON and binary should represent the same logical envelope:

```text
magic: "LOCUST"
schemaVersion: UInt32
modelType: "ngram" | "transformer"
createdWith: optional tool/library version
configuration:
  contextLength
  vocabularyLimit
  specialTokenIDs
vocabulary:
  ordered token list
modelPayload:
  model-specific data
```

Start with `schemaVersion = 1`.

### JSON Format

JSON should optimize for readability:

- Use `Codable` structs.
- Include clear field names.
- Store n-gram contexts and counts in a simple deterministic representation.
- Use pretty-printed output if practical.

This format is useful for tests, debugging, and learning.

### Binary Format

Binary should be simple and explicit:

- Magic bytes: `LOCUST`
- Schema version: little-endian `UInt32`
- Model type length + UTF-8 bytes
- JSON metadata length + UTF-8 JSON metadata bytes
- Payload length + model-specific payload bytes

For the first implementation, the binary payload can encode length-prefixed arrays of integers and doubles using little-endian values. Avoid relying on Swift memory layout.

The binary reader should validate:

- Magic header.
- Supported schema version.
- Supported model type.
- Section lengths.
- Unexpected trailing or truncated data.

## Test-First Milestones

Unit tests should live in focused files named after the production type or behavior they cover, such as `Text/WordTokenizerTests.swift` and `Text/WordDetokenizerTests.swift`. Prefer mirroring the `LocustKit` source directories in `LocustKitTests`; avoid collecting unrelated test suites in a generic shared test file.

Every milestone should update `README.md` as part of completion. Keep the README aligned with the current implementation status, available APIs or CLI behavior, defaults, examples, and any remaining planned work. Update `README.md` during each milestone rather than deferring documentation updates to Milestone 12.

### Milestone 1: Tokenizer And Detokenizer

Tests first:

- Splits words and punctuation.
- Preserves casing.
- Ignores whitespace/newlines.
- Detokenizes common punctuation without awkward spacing.
- Handles empty input.

Implementation:

- Add tokenizer protocol under `Text/Protocols`.
- Add `WordTokenizer`.
- Add detokenizer protocol under `Text/Protocols`.
- Add punctuation spacing configuration for detokenization.
- Add `WordDetokenizer`.

### Milestone 2: Vocabulary

Tests first:

- Reserves `<unk>`, `<bos>`, `<eos>`.
- Produces deterministic IDs.
- Maps unknown tokens to `<unk>`.
- Applies vocabulary limits.
- Round-trips IDs to tokens.

Implementation:

- Add `Vocabulary`.
- Add configuration for optional vocabulary limit.

### Milestone 3: Dataset Windows

Tests first:

- Adds `<bos>` and `<eos>` correctly.
- Produces fixed-length contexts and next-token targets.
- Handles short corpora.
- Uses `contextLength = 16` by default.

Implementation:

- Add dataset/window generation types.

### Milestone 4: Seeded RNG And Sampling

Tests first:

- Same seed produces same sampled sequence.
- Different seeds can produce different sampled sequences.
- Temperature rejects invalid values.
- Top-k restricts candidates.
- Greedy-like behavior emerges at low temperature.

Implementation:

- Add deterministic RNG.
- Add sampling helpers.

### Milestone 5: N-Gram Model

Tests first:

- Training records expected context/target counts.
- Prediction returns expected probabilities for seen contexts.
- Unseen contexts fall back to a sensible distribution.
- Generated output stops on `<eos>`.

Implementation:

- Add `NGramLanguageModel`.
- Add n-gram training configuration.
- Add average negative log likelihood reporting.

### Milestone 6: Serialization

Tests first:

- JSON round-trips a trained n-gram model.
- Binary round-trips the same model.
- Invalid magic/version/model type fails clearly.
- Deterministic model data remains deterministic after load.

Implementation:

- Add model envelope.
- Add JSON serializer.
- Add binary reader/writer.

### Milestone 7: CLI Training

Tests first where practical:

- Argument validation can be tested through parser-level APIs.
- Default output path is `<input_file>.locust`.
- Invalid combinations are rejected.

Implementation:

- Replace placeholder `Locust.test()` call with an `ArgumentParser` command.
- Implement `--create`, `--output`, and `--format`.
- Print basic training progress and save path.

### Milestone 8: CLI REPL

Tests first where practical:

- REPL command handling can be tested with injectable input/output streams.
- `quit` and `exit` terminate.
- Empty input does not generate.

Implementation:

- Implement `--model`.
- Load the model.
- Run interactive completion.
- Apply `--seed`, `--temperature`, and `--top-k`.

### Milestone 9: Transformer Math Primitives

Tests first:

- Vector/matrix shape validation.
- Dot product.
- Matrix multiplication.
- Softmax.
- Cross-entropy.
- Deterministic initialization.

Implementation:

- Add low-level math primitives using explicit readable loops.

### Milestone 10: Transformer Layers

Tests first:

- Embedding lookup shape and values.
- Positional embedding addition.
- Linear layer output.
- Causal attention mask behavior.
- Feed-forward shape.
- Layer normalization sanity checks.

Implementation:

- Add embeddings.
- Add linear layer.
- Add self-attention.
- Add feed-forward layer.
- Add transformer block.

### Milestone 11: Tiny Transformer Training

Tests first:

- Forward pass produces logits with expected shape.
- One training step changes parameters.
- Loss decreases on a tiny repeated corpus.
- Same seed gives reproducible initialization and first-step behavior.

Implementation:

- Add transformer model.
- Add SGD optimizer.
- Add training loop.
- Extend serialization for transformer payloads.

### Milestone 12: Usability Pass

Tests and checks:

- Train a small model from `Data`.
- Save/load both formats.
- Generate from several prompts.
- Confirm deterministic output with the same seed.
- Confirm `--help` is clear.

Implementation:

- Improve error messages.
- Add optional CLI flags only if needed, such as `--context-length`, `--epochs`, `--max-tokens`, or `--verbose`.
- Update README usage examples.

## Initial Defaults

Use these defaults unless implementation work reveals a concrete reason to adjust them:

- `format`: `binary`
- `contextLength`: `16`
- `temperature`: `1.0`
- `topK`: `0`
- `maxGeneratedTokens`: `40`
- `seed`: fixed documented constant when omitted
- `schemaVersion`: `1`
- `modelType`: `ngram` for the first working implementation
- `vocabularyLimit`: unlimited by default, configurable in library first

## Risks And Mitigations

- Transformer implementation is a large surface area. Mitigation: land the n-gram baseline first and reuse the same CLI, tokenizer, vocabulary, dataset, sampling, and serialization pieces.
- Binary serialization can become fragile. Mitigation: keep the format explicit, versioned, little-endian, length-prefixed, and heavily tested.
- Determinism can be accidentally broken. Mitigation: centralize RNG use and test seeded behavior.
- CLI testing can be awkward. Mitigation: keep command parsing and command execution separable, and inject input/output for REPL tests.
- Tokenization choices affect model quality. Mitigation: keep tokenizer behavior simple and well tested, then evolve it intentionally later if needed.
